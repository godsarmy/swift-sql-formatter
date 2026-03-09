import Testing

@testable import SQLFormatter

@Test func formatsBasicSelectFromWhereQuery() async throws {
  let sql = "SELECT id, name FROM people WHERE active = 1"
  let expected = """
    SELECT
      id,
      name
    FROM
      people
    WHERE
      active = 1
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func tokenizerSplitsWordsOperatorsAndPunctuation() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT name, age FROM people WHERE active = 1")

  let expectedTypes: [TokenType] = [
    .word, .whitespace, .word, .punctuation, .whitespace, .word, .whitespace,
    .word, .whitespace, .word, .whitespace, .word, .whitespace, .word,
    .whitespace, .operatorToken, .whitespace, .word,
  ]

  #expect(tokens.map(\.type) == expectedTypes)
  #expect(
    tokens.map(\.text) == [
      "SELECT", " ", "name", ",", " ", "age", " ", "FROM", " ", "people", " ",
      "WHERE", " ", "active", " ", "=", " ", "1",
    ])
}

@Test func tokenizerKeepsQuotedTokensTogether() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT 'hello world', [user] FROM people")

  let expectedTypes: [TokenType] = [
    .word, .whitespace, .quoted, .punctuation, .whitespace, .quoted, .whitespace, .word,
    .whitespace, .word,
  ]

  #expect(tokens.map(\.type) == expectedTypes)
  #expect(tokens[2].text == "'hello world'")
  #expect(tokens[5].text == "[user]")
}

@Test func defaultDialectIsStandardSQL() async throws {
  let options = FormatOptions.default

  #expect(options.dialect == .standardSQL)
  #expect(options.tabWidth == 2)
  #expect(options.useTabs == false)
  #expect(options.linesBetweenQueries == 1)
}
