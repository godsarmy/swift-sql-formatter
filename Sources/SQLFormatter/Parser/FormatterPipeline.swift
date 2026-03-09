struct FormatterPipeline {
  let options: FormatOptions

  func format(tokens: [Token], originalSQL: String) throws -> String {
    var buffer = OutputBuffer(
      indentationUnit: options.useTabs ? "\t" : String(repeating: " ", count: options.tabWidth)
    )
    var clauseIndented = false
    var pendingSpace = false
    var index = 0

    while index < tokens.count {
      let token = tokens[index]

      switch token.type {
      case .whitespace, .newline:
        pendingSpace = !buffer.output.hasSuffix("\n")
      case .comment:
        if clauseIndented {
          buffer.outdent()
          clauseIndented = false
        }
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
          if clauseIndented {
            buffer.outdent()
            clauseIndented = false
          }
          buffer.write(token.text)
        } else {
          if pendingSpace, token.text != ")" {
            buffer.space()
          }
          buffer.write(token.text)
          pendingSpace = token.text != "("
        }
      case .operatorToken:
        buffer.space()
        buffer.write(token.text)
        pendingSpace = true
      case .word, .quoted:
        if let clause = clause(at: index, in: tokens) {
          if clauseIndented {
            buffer.outdent()
          }
          buffer.newline()
          buffer.write(clause.text)
          buffer.newline()
          buffer.indent()
          clauseIndented = true
          pendingSpace = false
          index = clause.endIndex
        } else {
          if pendingSpace {
            buffer.space()
          }
          buffer.write(token.text)
          pendingSpace = true
        }
      }

      index += 1
    }

    if clauseIndented {
      buffer.outdent()
    }

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

    if keyword.hasSuffix("JOIN") {
      return (tokens[index].text, index)
    }

    if ["INNER", "LEFT", "RIGHT", "FULL", "CROSS"].contains(keyword),
      let nextWord = nextWordToken(after: index, in: tokens), nextWord.text.uppercased() == "JOIN"
    {
      return ("\(tokens[index].text) \(nextWord.text)", nextWord.index)
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
}
