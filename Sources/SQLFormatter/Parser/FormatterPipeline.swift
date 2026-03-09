struct FormatterPipeline {
  let options: FormatOptions

  func format(tokens: [Token], originalSQL: String) throws -> String {
    var buffer = OutputBuffer(
      indentationUnit: options.useTabs ? "\t" : String(repeating: " ", count: options.tabWidth)
    )
    var clauseIndented = false
    var pendingSpace = false

    for token in tokens {
      switch token.type {
      case .whitespace, .newline:
        pendingSpace = !buffer.output.hasSuffix("\n")
      case .punctuation:
        if token.text == "," {
          buffer.write(token.text)
          buffer.newline()
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
        }
        pendingSpace = token.text == ")"
      case .operatorToken:
        buffer.space()
        buffer.write(token.text)
        pendingSpace = true
      case .word, .quoted:
        if isClauseKeyword(token) {
          if clauseIndented {
            buffer.outdent()
          }
          buffer.newline()
          buffer.write(token.text)
          buffer.newline()
          buffer.indent()
          clauseIndented = true
          pendingSpace = false
        } else {
          if pendingSpace {
            buffer.space()
          }
          buffer.write(token.text)
          pendingSpace = true
        }
      }
    }

    if clauseIndented {
      buffer.outdent()
    }

    return buffer.rendered()
  }

  private func isClauseKeyword(_ token: Token) -> Bool {
    guard token.type == .word else {
      return false
    }

    switch token.text.uppercased() {
    case "SELECT", "FROM", "WHERE":
      return true
    default:
      return false
    }
  }
}
