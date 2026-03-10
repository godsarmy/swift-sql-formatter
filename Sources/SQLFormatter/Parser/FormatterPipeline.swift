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
    var index = 0

    while index < tokens.count {
      let token = tokens[index]

      switch token.type {
      case .whitespace, .newline:
        pendingSpace = !buffer.output.hasSuffix("\n")
      case .comment:
        indentationState.endClauseIfNeeded(using: &buffer)
        buffer.newline()
        buffer.write(token.text)
        buffer.newline()
        pendingSpace = false
      case .punctuation:
        if token.text == "," {
          buffer.write(token.text)
          buffer.newline()
        } else if token.text == "." {
          buffer.write(token.text)
          pendingSpace = false
        } else if token.text == ";" {
          indentationState.endClauseIfNeeded(using: &buffer)
          buffer.write(token.text)
          if hasNextStatementToken(after: index, in: tokens) {
            buffer.newline(count: max(1, options.linesBetweenQueries + 1))
          }
          pendingSpace = false
        } else {
          if pendingSpace, token.text != ")" {
            buffer.space()
          }
          buffer.write(token.text)
          pendingSpace = token.text != "("
        }
      case .operatorToken:
        writeExpressionToken(
          token.text,
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
            tokenText = formatKeyword(token.text)
          } else {
            tokenText = token.text
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

      index += 1
    }

    indentationState.endAll(using: &buffer)

    return buffer.rendered()
  }

  private func clause(at index: Int, in tokens: [Token]) -> (text: String, endIndex: Int)? {
    guard tokens[index].type == .word else {
      return nil
    }

    let keyword = tokens[index].text.uppercased()

    if ["SELECT", "FROM", "WHERE", "LIMIT", "HAVING", "ON"].contains(keyword) {
      return (tokens[index].text, index)
    }

    if ["GROUP", "ORDER"].contains(keyword),
      let nextWord = nextWordToken(after: index, in: tokens), nextWord.text.uppercased() == "BY"
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
    }

    if keyword == "JOIN" || keyword.hasSuffix("JOIN") {
      return (tokens[index].text, index)
    }

    if ["INNER", "CROSS", "NATURAL", "STRAIGHT"].contains(keyword),
      let nextWord = nextWordToken(after: index, in: tokens), nextWord.text.uppercased() == "JOIN"
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
    }

    if ["LEFT", "RIGHT", "FULL"].contains(keyword),
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
    [
      "SELECT", "FROM", "WHERE", "LIMIT", "HAVING", "ON", "GROUP", "BY", "ORDER",
      "JOIN", "INNER", "LEFT", "RIGHT", "FULL", "CROSS", "NATURAL", "STRAIGHT", "OUTER",
    ].contains(text.uppercased())
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
