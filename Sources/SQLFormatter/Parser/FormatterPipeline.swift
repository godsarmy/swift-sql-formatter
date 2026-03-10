import Foundation

struct FormatterPipeline {
  let options: FormatOptions

  private struct IndentationState {
    private enum Scope {
      case clause
    }

    private var scopes: [Scope] = []

    var hasOpenClause: Bool {
      scopes.last == .clause
    }

    mutating func beginClause(using buffer: inout OutputBuffer) {
      scopes.append(.clause)
      buffer.indent()
    }

    mutating func endClauseIfNeeded(using buffer: inout OutputBuffer) {
      guard hasOpenClause else {
        return
      }

      scopes.removeLast()
      buffer.outdent()
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
        pendingSpace = !buffer.output.hasSuffix("\n")
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
          buffer.write(resolvedTokenText)
          if hasNextStatementToken(after: index, in: tokens) {
            buffer.newline(count: max(1, options.linesBetweenQueries + 1))
          }
          pendingSpace = false
        } else {
          if pendingSpace, resolvedTokenText != ")" {
            buffer.space()
          }
          buffer.write(resolvedTokenText)
          pendingSpace = resolvedTokenText != "("
        }
      case .operatorToken:
        writeExpressionToken(
          resolvedTokenText,
          requiresLeadingSpace: true,
          buffer: &buffer,
          indentationState: indentationState
        )
        pendingSpace = true
      case .word, .quoted:
        if let clause = clause(at: index, in: tokens) {
          indentationState.endClauseIfNeeded(using: &buffer)
          buffer.newline()
          buffer.write(formatClauseKeyword(clause.text))
          buffer.newline()
          indentationState.beginClause(using: &buffer)
          pendingSpace = false
          index = clause.endIndex
        } else {
          let tokenText: String
          if token.type == .word, isKeyword(token.text) {
            tokenText = formatKeyword(resolvedTokenText)
          } else {
            tokenText = resolvedTokenText
          }

          writeExpressionToken(
            tokenText,
            requiresLeadingSpace: pendingSpace,
            buffer: &buffer,
            indentationState: indentationState
          )
          pendingSpace = true
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

    if options.dialect.clauseKeywords.contains(keyword) {
      return (tokens[index].text, index)
    }

    if let possibleSuffixes = options.dialect.compoundClauseKeywords[keyword],
      let nextWord = nextWordToken(after: index, in: tokens),
      possibleSuffixes.contains(nextWord.text.uppercased())
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
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

  private func formatKeyword(_ text: String) -> String {
    switch options.keywordCase {
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

  private func writeExpressionToken(
    _ text: String,
    requiresLeadingSpace: Bool,
    buffer: inout OutputBuffer,
    indentationState: IndentationState
  ) {
    if shouldWrapExpressionToken(
      text,
      requiresLeadingSpace: requiresLeadingSpace,
      buffer: buffer,
      indentationState: indentationState
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
    indentationState: IndentationState
  ) -> Bool {
    guard let width = options.expressionWidth, width > 0, indentationState.hasOpenClause,
      buffer.currentLineLength > 0
    else {
      return false
    }

    let additionalLength = (requiresLeadingSpace ? 1 : 0) + text.count
    return buffer.currentLineLength + additionalLength > width
  }
}
