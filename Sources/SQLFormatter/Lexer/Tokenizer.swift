struct Tokenizer {
  let dialect: Dialect

  func tokenize(_ sql: String) throws -> [Token] {
    var tokens: [Token] = []
    var index = sql.startIndex

    while index < sql.endIndex {
      let character = sql[index]

      if character == "\n" || character == "\r" {
        if character == "\r" {
          let nextIndex = sql.index(after: index)
          if nextIndex < sql.endIndex, sql[nextIndex] == "\n" {
            index = nextIndex
          }
        }

        tokens.append(Token(type: .newline, text: "\n"))
        index = sql.index(after: index)
        continue
      }

      if character.isWhitespace {
        let start = index
        index = advanceWhile(in: sql, from: index) { $0.isWhitespace && $0 != "\n" && $0 != "\r" }
        tokens.append(Token(type: .whitespace, text: String(sql[start..<index])))
        continue
      }

      if character == "-", hasPrefix("--", in: sql, at: index) {
        let start = index
        index = advanceUntilLineBreak(in: sql, from: index)
        tokens.append(Token(type: .comment, text: String(sql[start..<index])))
        continue
      }

      if character == "/", hasPrefix("/*", in: sql, at: index) {
        let start = index
        index = sql.index(index, offsetBy: 2)

        while index < sql.endIndex {
          if hasPrefix("*/", in: sql, at: index) {
            index = sql.index(index, offsetBy: 2)
            tokens.append(Token(type: .comment, text: String(sql[start..<index])))
            break
          }
          index = sql.index(after: index)
        }

        if tokens.last?.type != .comment || tokens.last?.text != String(sql[start..<index]) {
          throw FormatError.unterminatedBlockComment
        }
        continue
      }

      if let closingDelimiter = quotedTokenDelimiter(for: character) {
        let start = index
        index = sql.index(after: index)

        while index < sql.endIndex {
          let current = sql[index]
          if current == closingDelimiter {
            index = sql.index(after: index)
            tokens.append(Token(type: .quoted, text: String(sql[start..<index])))
            break
          }
          index = sql.index(after: index)
        }

        if tokens.last?.text != String(sql[start..<index]) {
          throw FormatError.unterminatedQuotedToken
        }
        continue
      }

      if isPunctuation(character) {
        tokens.append(Token(type: .punctuation, text: String(character)))
        index = sql.index(after: index)
        continue
      }

      if isOperator(character) {
        let start = index
        index = advanceWhile(in: sql, from: index, matching: isOperator)
        tokens.append(Token(type: .operatorToken, text: String(sql[start..<index])))
        continue
      }

      let start = index
      index = advanceWhile(in: sql, from: index) { current in
        !current.isWhitespace && !isPunctuation(current) && !isOperator(current)
          && quotedTokenDelimiter(for: current) == nil
      }
      tokens.append(Token(type: .word, text: String(sql[start..<index])))
    }

    return tokens
  }

  private func advanceWhile(
    in sql: String,
    from index: String.Index,
    matching predicate: (Character) -> Bool
  ) -> String.Index {
    var currentIndex = index
    while currentIndex < sql.endIndex, predicate(sql[currentIndex]) {
      currentIndex = sql.index(after: currentIndex)
    }
    return currentIndex
  }

  private func advanceUntilLineBreak(in sql: String, from index: String.Index) -> String.Index {
    var currentIndex = index
    while currentIndex < sql.endIndex {
      let character = sql[currentIndex]
      if character == "\n" || character == "\r" {
        break
      }
      currentIndex = sql.index(after: currentIndex)
    }
    return currentIndex
  }

  private func hasPrefix(_ prefix: String, in sql: String, at index: String.Index) -> Bool {
    sql[index...].hasPrefix(prefix)
  }

  private func quotedTokenDelimiter(for character: Character) -> Character? {
    switch character {
    case "'", "\"", "`":
      return character
    case "[":
      return "]"
    default:
      return nil
    }
  }

  private func isPunctuation(_ character: Character) -> Bool {
    [",", "(", ")", ";", "."].contains(character)
  }

  private func isOperator(_ character: Character) -> Bool {
    ["=", ">", "<", "!", "+", "-", "*", "/", "%"].contains(character)
  }
}
