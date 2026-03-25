import Testing

@testable import SQLFormatter

private func tokenize(
  _ sql: String,
  dialect: Dialect = .standardSQL
) throws -> [Token] {
  try Tokenizer(dialect: dialect).tokenize(sql)
}

private struct TokenSnapshot: Equatable {
  let type: TokenType
  let text: String
}

private func tokenSnapshots(from tokens: [Token]) -> [TokenSnapshot] {
  tokens.map { TokenSnapshot(type: $0.type, text: $0.text) }
}

// Upstream: test/unit/Tokenizer.test.ts :: tokenizes whitespace to empty array
// Swift divergence: Swift tokenizer exposes whitespace/newline tokens instead of filtering them out.
@Test func parity_tokenizer_emitsWhitespaceTokens() throws {
  let tokens = try tokenize(" \t\n \n\r ")
  let snapshots = tokenSnapshots(from: tokens)
  let expected = [
    TokenSnapshot(type: .whitespace, text: " \t"),
    TokenSnapshot(type: .newline, text: "\n"),
    TokenSnapshot(type: .whitespace, text: " "),
    TokenSnapshot(type: .newline, text: "\n"),
    TokenSnapshot(type: .newline, text: "\n"),
    TokenSnapshot(type: .whitespace, text: " "),
  ]
  #expect(snapshots == expected)
}

// Upstream: test/unit/Tokenizer.test.ts :: tokenizes single line SQL tokens
@Test func parity_tokenizer_singleLineTokens() throws {
  let tokens = try tokenize("SELECT * FROM foo;")
  let snapshots = tokenSnapshots(from: tokens)
  let expected = [
    TokenSnapshot(type: .word, text: "SELECT"),
    TokenSnapshot(type: .whitespace, text: " "),
    TokenSnapshot(type: .operatorToken, text: "*"),
    TokenSnapshot(type: .whitespace, text: " "),
    TokenSnapshot(type: .word, text: "FROM"),
    TokenSnapshot(type: .whitespace, text: " "),
    TokenSnapshot(type: .word, text: "foo"),
    TokenSnapshot(type: .punctuation, text: ";"),
  ]
  #expect(snapshots == expected)
}

// Upstream: test/unit/Tokenizer.test.ts :: tokenizes multiline SQL tokens
@Test func parity_tokenizer_multilineTokens() throws {
  let sql = "SELECT \"foo\n bar\" /* \n\n\n */;"
  let tokens = try tokenize(sql)
  let snapshots = tokenSnapshots(from: tokens)
  let expected = [
    TokenSnapshot(type: .word, text: "SELECT"),
    TokenSnapshot(type: .whitespace, text: " "),
    TokenSnapshot(type: .quoted, text: "\"foo\n bar\""),
    TokenSnapshot(type: .whitespace, text: " "),
    TokenSnapshot(type: .comment, text: "/* \n\n\n */"),
    TokenSnapshot(type: .punctuation, text: ";"),
  ]
  #expect(snapshots == expected)
}
