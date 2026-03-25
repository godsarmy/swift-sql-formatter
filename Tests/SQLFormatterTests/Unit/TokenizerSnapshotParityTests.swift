import Testing

@testable import SQLFormatter

@Test
func snapshot_tokenizer_singleLine() throws {
  let sql = try loadFixtureSQL(named: "single_line_tokens.sql", directory: "Tokenizer")
  let snapshots = fixtureTokenSnapshots(from: try tokenizeFixtureSQL(sql))
  let expected: [FixtureTokenSnapshot] = [
    .init(type: .word, text: "SELECT"),
    .init(type: .whitespace, text: " "),
    .init(type: .operatorToken, text: "*"),
    .init(type: .whitespace, text: " "),
    .init(type: .word, text: "FROM"),
    .init(type: .whitespace, text: " "),
    .init(type: .word, text: "foo"),
    .init(type: .whitespace, text: " "),
    .init(type: .word, text: "WHERE"),
    .init(type: .whitespace, text: " "),
    .init(type: .word, text: "id"),
    .init(type: .whitespace, text: " "),
    .init(type: .operatorToken, text: "="),
    .init(type: .whitespace, text: " "),
    .init(type: .word, text: "1"),
    .init(type: .punctuation, text: ";"),
    .init(type: .newline, text: "\n"),
  ]
  #expect(snapshots == expected)
}

@Test
func snapshot_tokenizer_multiLine() throws {
  let sql = try loadFixtureSQL(named: "multi_line_tokens.sql", directory: "Tokenizer")
  let snapshots = fixtureTokenSnapshots(from: try tokenizeFixtureSQL(sql))
  let expected: [FixtureTokenSnapshot] = [
    .init(type: .word, text: "SELECT"),
    .init(type: .whitespace, text: " "),
    .init(type: .quoted, text: "\"multi\nline\""),
    .init(type: .whitespace, text: " "),
    .init(type: .comment, text: "/* comment */"),
    .init(type: .newline, text: "\n"),
    .init(type: .word, text: "FROM"),
    .init(type: .whitespace, text: " "),
    .init(type: .word, text: "foo"),
    .init(type: .punctuation, text: ";"),
    .init(type: .newline, text: "\n"),
  ]
  #expect(snapshots == expected)
}
