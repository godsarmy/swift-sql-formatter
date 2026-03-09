struct Tokenizer {
  let dialect: Dialect

  func tokenize(_ sql: String) throws -> [Token] {
    var tokens: [Token] = []
    var index = sql.startIndex

    while index < sql.endIndex {
      let character = sql[index]

      if character == "\n" || character == "\r" {
        let start = index
        if character == "\r" {
          let nextIndex = sql.index(after: index)
          if nextIndex < sql.endIndex, sql[nextIndex] == "\n" {
            index = nextIndex
          }
        }

        tokens.append(Token(type: .newline, text: "\n", location: location(in: sql, at: start)))
        index = sql.index(after: index)
        continue
      }

      if character.isWhitespace {
        let start = index
        index = advanceWhile(in: sql, from: index) { $0.isWhitespace && $0 != "\n" && $0 != "\r" }
        tokens.append(
          Token(
            type: .whitespace,
            text: String(sql[start..<index]),
            location: location(in: sql, at: start)
          ))
        continue
      }

      if character == "-", hasPrefix("--", in: sql, at: index) {
        let start = index
        index = advanceUntilLineBreak(in: sql, from: index)
        tokens.append(
          Token(
            type: .comment, text: String(sql[start..<index]), location: location(in: sql, at: start)
          )
        )
        continue
      }

      if character == "/", hasPrefix("/*", in: sql, at: index) {
        let start = index
        index = sql.index(index, offsetBy: 2)

        while index < sql.endIndex {
          if hasPrefix("*/", in: sql, at: index) {
            index = sql.index(index, offsetBy: 2)
            tokens.append(
              Token(
                type: .comment,
                text: String(sql[start..<index]),
                location: location(in: sql, at: start)
              ))
            break
          }
          index = sql.index(after: index)
        }

        if tokens.last?.type != .comment || tokens.last?.text != String(sql[start..<index]) {
          throw FormatError.unterminatedBlockComment(at: location(in: sql, at: start))
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
            tokens.append(
              Token(
                type: .quoted, text: String(sql[start..<index]),
                location: location(in: sql, at: start))
            )
            break
          }
          index = sql.index(after: index)
        }

        if tokens.last?.text != String(sql[start..<index]) {
          throw FormatError.unterminatedQuotedToken(at: location(in: sql, at: start))
        }
        continue
      }

      if isPunctuation(character) {
        tokens.append(
          Token(type: .punctuation, text: String(character), location: location(in: sql, at: index))
        )
        index = sql.index(after: index)
        continue
      }

      if isOperator(character) {
        let start = index
        index = advanceWhile(in: sql, from: index, matching: isOperator)
        tokens.append(
          Token(
            type: .operatorToken,
            text: String(sql[start..<index]),
            location: location(in: sql, at: start)
          ))
        continue
      }

      let start = index
      index = advanceWhile(in: sql, from: index) { current in
        !current.isWhitespace && !isPunctuation(current) && !isOperator(current)
          && quotedTokenDelimiter(for: current) == nil
      }
      tokens.append(
        Token(type: .word, text: String(sql[start..<index]), location: location(in: sql, at: start))
      )
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

  private func location(in sql: String, at targetIndex: String.Index) -> SourceLocation {
    var line = 1
    var column = 1
    var offset = 0
    var index = sql.startIndex

    while index < targetIndex {
      let character = sql[index]
      offset += 1

      if character == "\n" {
        line += 1
        column = 1
      } else if character == "\r" {
        let nextIndex = sql.index(after: index)
        if nextIndex < targetIndex, sql[nextIndex] == "\n" {
          index = nextIndex
          offset += 1
        }
        line += 1
        column = 1
      } else {
        column += 1
      }

      index = sql.index(after: index)
    }

    return SourceLocation(line: line, column: column, offset: offset)
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
