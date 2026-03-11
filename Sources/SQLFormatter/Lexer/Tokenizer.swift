struct Tokenizer {
  let dialect: Dialect

  func tokenize(_ sql: String) throws -> [Token] {
    var tokens: [Token] = []
    var index = sql.startIndex

    while index < sql.endIndex {
      let character = sql[index]

      if isLineBreakCharacter(character) {
        let start = index
        tokens.append(Token(type: .newline, text: "\n", location: location(in: sql, at: start)))
        index = sql.index(after: index)
        continue
      }

      if character.isWhitespace {
        let start = index
        index = advanceWhile(in: sql, from: index) { $0.isWhitespace && !isLineBreakCharacter($0) }
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

      if let prefixedQuote = prefixedQuotedTokenStart(in: sql, at: index) {
        let start = index
        index = try consumeQuotedToken(
          in: sql,
          from: prefixedQuote.quoteStartIndex,
          openingDelimiter: prefixedQuote.openingDelimiter,
          tokenStart: start
        )
        tokens.append(
          Token(
            type: .quoted, text: String(sql[start..<index]), location: location(in: sql, at: start))
        )
        continue
      }

      if quotedTokenDelimiter(for: character) != nil {
        let start = index
        index = try consumeQuotedToken(
          in: sql,
          from: index,
          openingDelimiter: character,
          tokenStart: start
        )
        tokens.append(
          Token(
            type: .quoted, text: String(sql[start..<index]), location: location(in: sql, at: start))
        )
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
      if isLineBreakCharacter(character) {
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
      offset += character.unicodeScalars.count

      if isLineBreakCharacter(character) {
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
    dialect.quotedIdentifierDelimiters[character]
  }

  private func prefixedQuotedTokenStart(in sql: String, at index: String.Index) -> (
    quoteStartIndex: String.Index, openingDelimiter: Character
  )? {
    let character = sql[index]
    guard ["N", "E", "B", "X", "R", "U"].contains(character.uppercased()),
      let nextIndex = optionalIndex(after: index, in: sql), nextIndex < sql.endIndex,
      sql[nextIndex] == "'"
    else {
      return nil
    }

    return (quoteStartIndex: nextIndex, openingDelimiter: "'")
  }

  private func consumeQuotedToken(
    in sql: String,
    from openingIndex: String.Index,
    openingDelimiter: Character,
    tokenStart: String.Index
  ) throws -> String.Index {
    guard let closingDelimiter = quotedTokenDelimiter(for: openingDelimiter) else {
      throw FormatError.unterminatedQuotedToken(at: location(in: sql, at: tokenStart))
    }

    var currentIndex = sql.index(after: openingIndex)

    while currentIndex < sql.endIndex {
      let current = sql[currentIndex]

      if current == "\\", let escapedIndex = optionalIndex(after: currentIndex, in: sql) {
        currentIndex = sql.index(after: escapedIndex)
        continue
      }

      if current == closingDelimiter {
        if let nextIndex = optionalIndex(after: currentIndex, in: sql), nextIndex < sql.endIndex,
          sql[nextIndex] == closingDelimiter
        {
          currentIndex = sql.index(after: nextIndex)
          continue
        }

        return sql.index(after: currentIndex)
      }

      currentIndex = sql.index(after: currentIndex)
    }

    throw FormatError.unterminatedQuotedToken(at: location(in: sql, at: tokenStart))
  }

  private func optionalIndex(after index: String.Index, in sql: String) -> String.Index? {
    let nextIndex = sql.index(after: index)
    return nextIndex <= sql.endIndex ? nextIndex : nil
  }

  private func isPunctuation(_ character: Character) -> Bool {
    dialect.punctuationCharacters.contains(character)
  }

  private func isOperator(_ character: Character) -> Bool {
    dialect.operatorCharacters.contains(character)
  }

  private func isLineBreakCharacter(_ character: Character) -> Bool {
    character.unicodeScalars.contains { scalar in
      scalar == "\n" || scalar == "\r"
    }
  }
}
