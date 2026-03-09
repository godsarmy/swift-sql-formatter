struct Tokenizer {
  let dialect: Dialect

  func tokenize(_ sql: String) throws -> [Token] {
    guard !sql.isEmpty else {
      return []
    }

    return [Token(type: .word, text: sql)]
  }
}
