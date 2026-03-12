import Foundation

struct FormatterPipeline {
  let options: FormatOptions

  private struct IndentationState {
    private enum Scope {
      case clause
      case block
    }

    private var scopes: [Scope] = []

    var hasOpenClause: Bool {
      scopes.last == .clause
    }

    mutating func beginClause(using buffer: inout OutputBuffer) {
      scopes.append(.clause)
      buffer.indent()
    }

    mutating func beginBlock(using buffer: inout OutputBuffer) {
      scopes.append(.block)
      buffer.indent()
    }

    mutating func endClauseIfNeeded(using buffer: inout OutputBuffer) {
      guard hasOpenClause else {
        return
      }

      scopes.removeLast()
      buffer.outdent()
    }

    mutating func endBlockIfNeeded(using buffer: inout OutputBuffer) {
      guard scopes.last == .block else {
        return
      }

      scopes.removeLast()
      buffer.outdent()
    }

    mutating func endTrailingBlocks(using buffer: inout OutputBuffer) {
      while scopes.last == .block {
        scopes.removeLast()
        buffer.outdent()
      }
    }

    mutating func endAll(using buffer: inout OutputBuffer) {
      while !scopes.isEmpty {
        scopes.removeLast()
        buffer.outdent()
      }
    }
  }

  func format(tokens: [Token], originalSQL: String) throws -> String {
    var buffer = OutputBuffer(
      indentationUnit: options.useTabs ? "\t" : String(repeating: " ", count: options.tabWidth)
    )
    var indentationState = IndentationState()
    var pendingSpace = false
    var formattingDisabled = false
    var positionalPlaceholderIndex = 0
    var parenthesizedExpressionDepth = 0
    var index = 0

    while index < tokens.count {
      let token = tokens[index]
      let resolvedPlaceholder = resolvePlaceholderText(
        at: index,
        in: tokens,
        positionalIndex: &positionalPlaceholderIndex
      )
      let resolvedTokenText = resolvedPlaceholder.text

      if formattingDisabled {
        buffer.writeVerbatim(resolvedTokenText)
        if token.type == .comment, isFormatterEnableDirective(token.text) {
          formattingDisabled = false
        }
        index += resolvedPlaceholder.consumedTokenCount
        continue
      }

      switch token.type {
      case .whitespace, .newline:
        pendingSpace = shouldInsertPendingSpaceAfterWhitespace(buffer: buffer)
      case .comment:
        if isFormatterDisableDirective(token.text) {
          indentationState.endClauseIfNeeded(using: &buffer)
          buffer.newline()
          buffer.writeVerbatim(token.text)
          pendingSpace = false
          formattingDisabled = true
          index += resolvedPlaceholder.consumedTokenCount
          continue
        }

        indentationState.endClauseIfNeeded(using: &buffer)
        buffer.newline()
        buffer.write(resolvedTokenText)
        buffer.newline()
        pendingSpace = false
      case .punctuation:
        if resolvedTokenText == "," {
          buffer.write(resolvedTokenText)
          buffer.newline()
        } else if resolvedTokenText == "." {
          buffer.write(resolvedTokenText)
          pendingSpace = false
        } else if resolvedTokenText == ";" {
          indentationState.endClauseIfNeeded(using: &buffer)
          if options.newlineBeforeSemicolon {
            buffer.newline()
          }
          buffer.write(resolvedTokenText)
          if hasNextStatementToken(after: index, in: tokens) {
            buffer.newline(count: max(1, options.linesBetweenQueries + 1))
          }
          pendingSpace = false
        } else {
          if resolvedTokenText == ")" {
            parenthesizedExpressionDepth = max(0, parenthesizedExpressionDepth - 1)
          }

          if pendingSpace, resolvedTokenText != ")",
            !shouldOmitSpaceBeforePunctuation(resolvedTokenText, at: index, in: tokens)
          {
            buffer.space()
          }
          buffer.write(resolvedTokenText)
          pendingSpace = resolvedTokenText != "("

          if resolvedTokenText == "(" {
            parenthesizedExpressionDepth += 1
          }
        }
      case .operatorToken:
        writeOperatorToken(
          resolvedTokenText,
          buffer: &buffer,
          indentationState: indentationState,
          parenthesizedExpressionDepth: parenthesizedExpressionDepth,
          pendingSpace: &pendingSpace
        )
      case .word, .quoted:
        if token.type == .word,
          handleTransactSQLControlWord(
            token.text,
            at: index,
            in: tokens,
            buffer: &buffer,
            indentationState: &indentationState,
            pendingSpace: &pendingSpace
          )
        {
          index += resolvedPlaceholder.consumedTokenCount
          continue
        }

        if let clause = clause(at: index, in: tokens) {
          indentationState.endClauseIfNeeded(using: &buffer)
          buffer.newline()
          buffer.write(formatClauseKeyword(clause.text))
          if shouldKeepClauseInline(clause.text) {
            if shouldInsertSpaceAfterInlineClause(endingAt: clause.endIndex, in: tokens) {
              buffer.space()
            }
            pendingSpace = false
          } else {
            buffer.newline()
            indentationState.beginClause(using: &buffer)
            pendingSpace = false
          }
          index = clause.endIndex
        } else {
          let tokenText: String
          if token.type == .word {
            tokenText = formatWordToken(
              resolvedTokenText,
              originalTokenText: token.text,
              at: index,
              in: tokens
            )
          } else {
            tokenText = resolvedTokenText
          }

          if token.type == .word, isLogicalOperator(token.text) {
            writeLogicalOperator(
              tokenText,
              buffer: &buffer,
              indentationState: indentationState,
              parenthesizedExpressionDepth: parenthesizedExpressionDepth,
              pendingSpace: &pendingSpace
            )
          } else {
            writeExpressionToken(
              tokenText,
              requiresLeadingSpace: pendingSpace,
              buffer: &buffer,
              indentationState: indentationState,
              parenthesizedExpressionDepth: parenthesizedExpressionDepth
            )
            pendingSpace = true
          }
        }
      }

      index += resolvedPlaceholder.consumedTokenCount
    }

    indentationState.endAll(using: &buffer)

    return buffer.rendered()
  }

  private func clause(at index: Int, in tokens: [Token]) -> (text: String, endIndex: Int)? {
    guard tokens[index].type == .word else {
      return nil
    }

    let keyword = tokens[index].text.uppercased()
    let statementKeyword = statementLeadingKeyword(containing: index, in: tokens)

    if ["GRANT", "REVOKE"].contains(statementKeyword), isPrivilegeKeyword(keyword) {
      return nil
    }

    if statementKeyword == "GRANT", keyword == "TO" {
      return (tokens[index].text, index)
    }

    if let mergeClause = mergeClause(
      at: index,
      in: tokens,
      statementKeyword: statementKeyword
    ) {
      return mergeClause
    }

    if options.dialect.name == "transactsql" {
      if let specialClause = transactSQLClause(at: index, in: tokens) {
        return specialClause
      }
    }

    if let specialClause = genericClause(at: index, in: tokens) {
      return specialClause
    }

    if let possibleSuffixes = options.dialect.compoundClauseKeywords[keyword],
      let nextWord = nextWordToken(after: index, in: tokens),
      possibleSuffixes.contains(nextWord.text.uppercased())
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
    }

    if options.dialect.clauseKeywords.contains(keyword) {
      return (tokens[index].text, index)
    }

    if keyword == "JOIN" || keyword.hasSuffix("JOIN") {
      return (tokens[index].text, index)
    }

    if options.dialect.joinModifierKeywords.contains(keyword),
      let nextWord = nextWordToken(after: index, in: tokens), nextWord.text.uppercased() == "JOIN"
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
    }

    if options.dialect.outerJoinModifierKeywords.contains(keyword),
      let nextWord = nextWordToken(after: index, in: tokens)
    {
      let nextKeyword = nextWord.text.uppercased()
      if nextKeyword == "JOIN" {
        return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
      }

      if nextKeyword == "OUTER",
        let joinWord = nextWordToken(after: nextWord.index, in: tokens),
        joinWord.text.uppercased() == "JOIN"
      {
        return (
          "\(tokens[index].text) \(nextWord.text) \(joinWord.text)",
          joinWord.index
        )
      }
    }

    return nil
  }

  private func nextWordToken(after index: Int, in tokens: [Token]) -> (text: String, index: Int)? {
    var nextIndex = index + 1
    while nextIndex < tokens.count {
      let token = tokens[nextIndex]
      switch token.type {
      case .whitespace, .newline:
        nextIndex += 1
      case .word:
        return (token.text, nextIndex)
      default:
        return nil
      }
    }
    return nil
  }

  private func statementLeadingKeyword(containing index: Int, in tokens: [Token]) -> String? {
    var currentIndex = index
    var words: [(String, Int)] = []

    while currentIndex >= 0 {
      let token = tokens[currentIndex]
      if token.type == .punctuation, token.text == ";" {
        break
      }
      if token.type == .word {
        words.append((token.text.uppercased(), currentIndex))
      }
      currentIndex -= 1
    }

    return words.last?.0
  }

  private func isPrivilegeKeyword(_ keyword: String) -> Bool {
    [
      "SELECT", "INSERT", "UPDATE", "DELETE", "ALTER", "CREATE", "DROP", "TRUNCATE",
      "USAGE", "ROLE",
    ].contains(keyword)
  }

  private func hasNextStatementToken(after index: Int, in tokens: [Token]) -> Bool {
    var nextIndex = index + 1
    while nextIndex < tokens.count {
      let token = tokens[nextIndex]
      switch token.type {
      case .whitespace, .newline:
        nextIndex += 1
      default:
        return true
      }
    }

    return false
  }

  private func formatClauseKeyword(_ text: String) -> String {
    text
      .split(separator: " ")
      .map { formatKeyword(String($0)) }
      .joined(separator: " ")
  }

  private func shouldKeepClauseInline(_ text: String) -> Bool {
    let normalizedText = text.uppercased()
    return [
      "BREAK", "CREATE MATERIALIZED VIEW", "CREATE OR REPLACE VIEW", "CREATE TABLE",
      "CREATE VIEW", "DELETE FROM",
      "IF", "INSERT INTO", "MERGE INTO", "SET NOCOUNT OFF", "SET NOCOUNT ON",
      "TRUNCATE", "TRUNCATE TABLE", "UPDATE",
      "WHILE",
      "ELSE IF", "RETURN",
      "CREATE PROCEDURE", "ALTER PROCEDURE", "CREATE OR ALTER PROCEDURE",
    ].contains(normalizedText)
  }

  private func mergeClause(
    at index: Int,
    in tokens: [Token],
    statementKeyword: String?
  ) -> (text: String, endIndex: Int)? {
    guard statementKeyword == "MERGE" else {
      return nil
    }

    let keyword = tokens[index].text.uppercased()

    if keyword == "MERGE",
      let nextWord = nextWordToken(after: index, in: tokens),
      nextWord.text.uppercased() == "INTO"
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
    }

    if keyword == "USING" || keyword == "THEN" {
      return (tokens[index].text, index)
    }

    if keyword != "WHEN" {
      return nil
    }

    guard let secondWord = nextWordToken(after: index, in: tokens) else {
      return (tokens[index].text, index)
    }

    let secondKeyword = secondWord.text.uppercased()
    if secondKeyword == "MATCHED" {
      if let thirdWord = nextWordToken(after: secondWord.index, in: tokens),
        thirdWord.text.uppercased() == "BY",
        let fourthWord = nextWordToken(after: thirdWord.index, in: tokens),
        ["SOURCE", "TARGET"].contains(fourthWord.text.uppercased())
      {
        return (
          "\(tokens[index].text) \(secondWord.text) \(thirdWord.text) \(fourthWord.text)",
          fourthWord.index
        )
      }

      return ("\(tokens[index].text) \(secondWord.text)", secondWord.index)
    }

    if secondKeyword == "NOT",
      let thirdWord = nextWordToken(after: secondWord.index, in: tokens),
      thirdWord.text.uppercased() == "MATCHED"
    {
      if let fourthWord = nextWordToken(after: thirdWord.index, in: tokens),
        fourthWord.text.uppercased() == "BY",
        let fifthWord = nextWordToken(after: fourthWord.index, in: tokens),
        ["SOURCE", "TARGET"].contains(fifthWord.text.uppercased())
      {
        return (
          "\(tokens[index].text) \(secondWord.text) \(thirdWord.text) \(fourthWord.text) \(fifthWord.text)",
          fifthWord.index
        )
      }

      return ("\(tokens[index].text) \(secondWord.text) \(thirdWord.text)", thirdWord.index)
    }

    return (tokens[index].text, index)
  }

  private func genericClause(at index: Int, in tokens: [Token]) -> (text: String, endIndex: Int)? {
    let keyword = tokens[index].text.uppercased()

    if keyword == "CREATE",
      let secondWord = nextWordToken(after: index, in: tokens),
      secondWord.text.uppercased() == "MATERIALIZED",
      let thirdWord = nextWordToken(after: secondWord.index, in: tokens),
      thirdWord.text.uppercased() == "VIEW"
    {
      return (
        "\(tokens[index].text) \(secondWord.text) \(thirdWord.text)",
        thirdWord.index
      )
    }

    if keyword == "CREATE",
      let secondWord = nextWordToken(after: index, in: tokens),
      secondWord.text.uppercased() == "OR",
      let thirdWord = nextWordToken(after: secondWord.index, in: tokens),
      thirdWord.text.uppercased() == "REPLACE",
      let fourthWord = nextWordToken(after: thirdWord.index, in: tokens),
      fourthWord.text.uppercased() == "VIEW"
    {
      return (
        "\(tokens[index].text) \(secondWord.text) \(thirdWord.text) \(fourthWord.text)",
        fourthWord.index
      )
    }

    return nil
  }

  private func shouldInsertSpaceAfterInlineClause(endingAt endIndex: Int, in tokens: [Token])
    -> Bool
  {
    guard let nextToken = nextNonWhitespaceToken(after: endIndex, in: tokens) else {
      return false
    }

    return !(nextToken.type == .punctuation && nextToken.text == ";")
  }

  private func transactSQLClause(at index: Int, in tokens: [Token]) -> (
    text: String, endIndex: Int
  )? {
    let keyword = tokens[index].text.uppercased()

    if keyword == "SET",
      let secondWord = nextWordToken(after: index, in: tokens),
      secondWord.text.uppercased() == "NOCOUNT",
      let thirdWord = nextWordToken(after: secondWord.index, in: tokens),
      ["ON", "OFF"].contains(thirdWord.text.uppercased())
    {
      return ("\(tokens[index].text) \(secondWord.text) \(thirdWord.text)", thirdWord.index)
    }

    if ["CREATE", "ALTER"].contains(keyword),
      let secondWord = nextWordToken(after: index, in: tokens)
    {
      let secondKeyword = secondWord.text.uppercased()
      if secondKeyword == "PROCEDURE" {
        return ("\(tokens[index].text) \(secondWord.text)", secondWord.index)
      }

      if keyword == "CREATE", secondKeyword == "OR",
        let thirdWord = nextWordToken(after: secondWord.index, in: tokens),
        thirdWord.text.uppercased() == "ALTER",
        let fourthWord = nextWordToken(after: thirdWord.index, in: tokens),
        fourthWord.text.uppercased() == "PROCEDURE"
      {
        return (
          "\(tokens[index].text) \(secondWord.text) \(thirdWord.text) \(fourthWord.text)",
          fourthWord.index
        )
      }
    }

    return nil
  }

  private func handleTransactSQLControlWord(
    _ text: String,
    at index: Int,
    in tokens: [Token],
    buffer: inout OutputBuffer,
    indentationState: inout IndentationState,
    pendingSpace: inout Bool
  ) -> Bool {
    guard options.dialect.name == "transactsql" else {
      return false
    }

    switch text.uppercased() {
    case "BEGIN":
      indentationState.endClauseIfNeeded(using: &buffer)
      if !buffer.output.isEmpty, !buffer.output.hasSuffix("\n") {
        buffer.space()
      }
      buffer.write(formatKeyword(text))
      indentationState.beginBlock(using: &buffer)
      pendingSpace = true
      return true
    case "END":
      indentationState.endClauseIfNeeded(using: &buffer)
      indentationState.endBlockIfNeeded(using: &buffer)
      if !buffer.output.isEmpty, !buffer.output.hasSuffix("\n") {
        buffer.newline()
      }
      buffer.write(formatKeyword(text))
      pendingSpace = true
      return true
    case "ELSE":
      if let nextWord = nextWordToken(after: index, in: tokens), nextWord.text.uppercased() == "IF"
      {
        return false
      }
      indentationState.endClauseIfNeeded(using: &buffer)
      indentationState.endTrailingBlocks(using: &buffer)
      if !buffer.output.isEmpty, !buffer.output.hasSuffix("\n") {
        buffer.newline()
      }
      buffer.write(formatKeyword(text))
      pendingSpace = true
      return true
    case "GO":
      indentationState.endAll(using: &buffer)
      if !buffer.output.isEmpty, !buffer.output.hasSuffix("\n") {
        buffer.newline(count: 2)
      }
      buffer.write(formatKeyword(text))
      pendingSpace = false
      return true
    case "RETURN":
      indentationState.endClauseIfNeeded(using: &buffer)
      if !buffer.output.isEmpty, !buffer.output.hasSuffix("\n") {
        buffer.newline()
      }
      buffer.write(formatKeyword(text))
      pendingSpace = true
      return true
    default:
      return false
    }
  }

  private func formatKeyword(_ text: String) -> String {
    formatCasedText(text, using: options.keywordCase)
  }

  private func formatFunctionName(_ text: String) -> String {
    formatCasedText(text, using: options.functionCase)
  }

  private func formatDataType(_ text: String) -> String {
    formatCasedText(text, using: options.dataTypeCase)
  }

  private func formatIdentifier(_ text: String) -> String {
    formatCasedText(text, using: options.identifierCase)
  }

  private func formatCasedText(_ text: String, using rule: KeywordCase) -> String {
    switch rule {
    case .preserve:
      return text
    case .upper:
      return text.uppercased()
    case .lower:
      return text.lowercased()
    }
  }

  private func isKeyword(_ text: String) -> Bool {
    options.dialect.reservedWords.contains(text.uppercased())
  }

  private func isLogicalOperator(_ text: String) -> Bool {
    ["AND", "OR", "XOR"].contains(text.uppercased())
  }

  private func isDataType(_ text: String) -> Bool {
    [
      "BIGINT", "BOOL", "BOOLEAN", "CHAR", "DATE", "DATETIME", "DECIMAL", "DOUBLE", "FLOAT",
      "INT", "INTEGER", "NUMERIC", "REAL", "SMALLINT", "TEXT", "TIME", "TIMESTAMP", "UUID",
      "VARCHAR",
    ].contains(text.uppercased())
  }

  private func isFunctionName(at index: Int, in tokens: [Token], text: String) -> Bool {
    guard !isKeyword(text), !isLogicalOperator(text), !isDataType(text),
      let nextToken = nextNonWhitespaceToken(after: index, in: tokens)
    else {
      return false
    }

    return nextToken.type == .punctuation && nextToken.text == "("
  }

  private func nextNonWhitespaceToken(after index: Int, in tokens: [Token]) -> Token? {
    var nextIndex = index + 1
    while nextIndex < tokens.count {
      let token = tokens[nextIndex]
      switch token.type {
      case .whitespace, .newline:
        nextIndex += 1
      default:
        return token
      }
    }

    return nil
  }

  private func formatWordToken(
    _ resolvedText: String,
    originalTokenText: String,
    at index: Int,
    in tokens: [Token]
  ) -> String {
    guard resolvedText == originalTokenText else {
      return resolvedText
    }

    if isKeyword(originalTokenText) || isLogicalOperator(originalTokenText) {
      return formatKeyword(resolvedText)
    }

    if isDataType(originalTokenText) {
      return formatDataType(resolvedText)
    }

    if isFunctionName(at: index, in: tokens, text: originalTokenText) {
      return formatFunctionName(resolvedText)
    }

    return formatIdentifier(resolvedText)
  }

  private func shouldInsertPendingSpaceAfterWhitespace(buffer: OutputBuffer) -> Bool {
    guard !buffer.output.hasSuffix("\n") else {
      return false
    }

    guard options.denseOperators, let lastCharacter = buffer.output.last else {
      return true
    }

    return !options.dialect.operatorCharacters.contains(lastCharacter) && lastCharacter != "("
  }

  private func shouldOmitSpaceBeforePunctuation(
    _ punctuation: String,
    at index: Int,
    in tokens: [Token]
  ) -> Bool {
    guard punctuation == "(",
      let previousIndex = previousNonWhitespaceTokenIndex(before: index, in: tokens)
    else {
      return false
    }

    let previousToken = tokens[previousIndex]

    switch previousToken.type {
    case .word, .quoted:
      if previousToken.type == .word {
        return isDataType(previousToken.text)
          || isFunctionName(at: previousIndex, in: tokens, text: previousToken.text)
      }

      return false
    default:
      return false
    }
  }

  private func previousNonWhitespaceTokenIndex(before index: Int, in tokens: [Token]) -> Int? {
    var previousIndex = index - 1
    while previousIndex >= 0 {
      let token = tokens[previousIndex]
      switch token.type {
      case .whitespace, .newline:
        previousIndex -= 1
      default:
        return previousIndex
      }
    }

    return nil
  }

  private func resolvePlaceholderText(
    at index: Int,
    in tokens: [Token],
    positionalIndex: inout Int
  ) -> (text: String, consumedTokenCount: Int) {
    let token = tokens[index]

    if let resolvedValue = prefixedPlaceholderValue(at: index, in: tokens) {
      return resolvedValue
    }

    guard token.type == .word else {
      return (token.text, 1)
    }

    if options.resolvedParamTypes.positional, token.text == "?" {
      let positionalParams = options.resolvedPositionalParams
      guard positionalIndex < positionalParams.count else {
        return (token.text, 1)
      }

      let value = positionalParams[positionalIndex]
      positionalIndex += 1
      return (value, 1)
    }

    if let value = numberedPlaceholderValue(for: token.text) {
      return (value, 1)
    }

    if let value = namedPlaceholderValue(for: token.text) {
      return (value, 1)
    }

    if let value = customPlaceholderValue(for: token.text) {
      return (value, 1)
    }

    return (token.text, 1)
  }

  private func numberedPlaceholderValue(for tokenText: String) -> String? {
    let paramTypes = options.resolvedParamTypes

    for prefix in paramTypes.numbered {
      guard tokenText.first == prefix.rawValue else {
        continue
      }

      let key = String(tokenText.dropFirst())
      guard !key.isEmpty, key.allSatisfy(\.isNumber) else {
        continue
      }

      return options.resolvedNamedParams[key]
    }

    return nil
  }

  private func namedPlaceholderValue(for tokenText: String) -> String? {
    let paramTypes = options.resolvedParamTypes

    for prefix in paramTypes.named {
      guard tokenText.first == prefix.rawValue else {
        continue
      }

      let key = String(tokenText.dropFirst())
      guard !key.isEmpty else {
        continue
      }

      return options.resolvedNamedParams[key]
    }

    return nil
  }

  private func quotedPlaceholderValue(at index: Int, in tokens: [Token]) -> String? {
    let paramTypes = options.resolvedParamTypes
    guard index + 1 < tokens.count else {
      return nil
    }

    let prefixToken = tokens[index]
    let quotedToken = tokens[index + 1]

    guard prefixToken.type == .word, quotedToken.type == .quoted,
      prefixToken.text.count == 1,
      let prefixCharacter = prefixToken.text.first,
      let prefix = ParameterPrefix(rawValue: prefixCharacter), paramTypes.quoted.contains(prefix)
    else {
      return nil
    }

    return options.resolvedNamedParams[unquotePlaceholderKey(quotedToken.text)]
  }

  private func prefixedPlaceholderValue(
    at index: Int,
    in tokens: [Token]
  ) -> (text: String, consumedTokenCount: Int)? {
    guard index + 1 < tokens.count else {
      return nil
    }

    let prefixToken = tokens[index]
    let valueToken = tokens[index + 1]
    let supportedPrefixTypes: Set<TokenType> = [.word, .operatorToken]

    guard supportedPrefixTypes.contains(prefixToken.type), prefixToken.text.count == 1,
      let prefixCharacter = prefixToken.text.first,
      let prefix = ParameterPrefix(rawValue: prefixCharacter)
    else {
      return nil
    }

    if valueToken.type == .quoted, options.resolvedParamTypes.quoted.contains(prefix) {
      if let value = quotedPlaceholderValue(at: index, in: tokens) {
        return (value, 2)
      }
    }

    guard valueToken.type == .word else {
      return nil
    }

    if options.resolvedParamTypes.numbered.contains(prefix), valueToken.text.allSatisfy(\.isNumber),
      let value = options.resolvedNamedParams[valueToken.text]
    {
      return (value, 2)
    }

    if options.resolvedParamTypes.named.contains(prefix),
      let value = options.resolvedNamedParams[valueToken.text]
    {
      return (value, 2)
    }

    return nil
  }

  private func customPlaceholderValue(for tokenText: String) -> String? {
    for customType in options.resolvedParamTypes.custom {
      guard let regex = try? NSRegularExpression(pattern: customType.regex) else {
        continue
      }

      let range = NSRange(tokenText.startIndex..<tokenText.endIndex, in: tokenText)
      guard let match = regex.firstMatch(in: tokenText, range: range), match.range == range else {
        continue
      }

      let key = customType.key?(tokenText) ?? tokenText
      return options.resolvedNamedParams[key]
    }

    return nil
  }

  private func unquotePlaceholderKey(_ text: String) -> String {
    guard text.count >= 2 else {
      return text
    }

    return String(text.dropFirst().dropLast())
  }

  private func isFormatterDisableDirective(_ commentText: String) -> Bool {
    commentText.lowercased().contains("sql-formatter-disable")
  }

  private func isFormatterEnableDirective(_ commentText: String) -> Bool {
    commentText.lowercased().contains("sql-formatter-enable")
  }

  private func writeLogicalOperator(
    _ text: String,
    buffer: inout OutputBuffer,
    indentationState: IndentationState,
    parenthesizedExpressionDepth: Int,
    pendingSpace: inout Bool
  ) {
    switch options.logicalOperatorNewline {
    case .before:
      buffer.newline()
      buffer.write(text)
      pendingSpace = true
    case .after:
      writeExpressionToken(
        text,
        requiresLeadingSpace: pendingSpace,
        buffer: &buffer,
        indentationState: indentationState,
        parenthesizedExpressionDepth: parenthesizedExpressionDepth
      )
      buffer.newline()
      pendingSpace = false
    }
  }

  private func writeOperatorToken(
    _ text: String,
    buffer: inout OutputBuffer,
    indentationState: IndentationState,
    parenthesizedExpressionDepth: Int,
    pendingSpace: inout Bool
  ) {
    if options.denseOperators {
      if shouldWrapExpressionToken(
        text,
        requiresLeadingSpace: false,
        buffer: buffer,
        indentationState: indentationState,
        parenthesizedExpressionDepth: parenthesizedExpressionDepth
      ) {
        buffer.newline()
      }
      buffer.write(text)
      pendingSpace = false
      return
    }

    writeExpressionToken(
      text,
      requiresLeadingSpace: true,
      buffer: &buffer,
      indentationState: indentationState,
      parenthesizedExpressionDepth: parenthesizedExpressionDepth
    )
    pendingSpace = true
  }

  private func writeExpressionToken(
    _ text: String,
    requiresLeadingSpace: Bool,
    buffer: inout OutputBuffer,
    indentationState: IndentationState,
    parenthesizedExpressionDepth: Int
  ) {
    if shouldWrapExpressionToken(
      text,
      requiresLeadingSpace: requiresLeadingSpace,
      buffer: buffer,
      indentationState: indentationState,
      parenthesizedExpressionDepth: parenthesizedExpressionDepth
    ) {
      buffer.newline()
      buffer.write(text)
      return
    }

    if requiresLeadingSpace {
      buffer.space()
    }
    buffer.write(text)
  }

  private func shouldWrapExpressionToken(
    _ text: String,
    requiresLeadingSpace: Bool,
    buffer: OutputBuffer,
    indentationState: IndentationState,
    parenthesizedExpressionDepth: Int
  ) -> Bool {
    guard let width = options.expressionWidth, width > 0, indentationState.hasOpenClause,
      parenthesizedExpressionDepth > 0,
      buffer.currentLineLength > 0
    else {
      return false
    }

    let additionalLength = (requiresLeadingSpace ? 1 : 0) + text.count
    return buffer.currentLineLength + additionalLength > width
  }
}
