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

private func expectTokens(
  from sql: String,
  expected: [TokenSnapshot]
) throws {
  let tokens = try tokenize(sql)
  #expect(tokenSnapshots(from: tokens) == expected)
}

// Swift divergence: parser implementation is not yet available, so we verify the token stream that would be fed into the upstream parser.

// Upstream: test/unit/Parser.test.ts :: parses empty list of tokens
@Test func parity_parser_emptyListOfTokens() throws {
  let tokens = try tokenize("")
  #expect(tokens.isEmpty)
}

// Upstream: test/unit/Parser.test.ts :: parses list of statements
@Test func parity_parser_listOfStatementsTokenized() throws {
  try expectTokens(
    from: "foo; bar",
    expected: [
      TokenSnapshot(type: .word, text: "foo"),
      TokenSnapshot(type: .punctuation, text: ";"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "bar"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses array subscript
@Test func parity_parser_arraySubscriptTokenized() throws {
  try expectTokens(
    from: "SELECT my_array[5]",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "my_array"),
      TokenSnapshot(type: .quoted, text: "[5]"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses array subscript with comment
@Test func parity_parser_arraySubscriptWithCommentTokenized() throws {
  try expectTokens(
    from: "SELECT my_array /*haha*/ [5]",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "my_array"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .comment, text: "/*haha*/"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .quoted, text: "[5]"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses parenthesized expressions
@Test func parity_parser_parenthesizedExpressionTokenized() throws {
  try expectTokens(
    from: "SELECT (birth_year - (CURRENT_DATE + 1))",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .punctuation, text: "("),
      TokenSnapshot(type: .word, text: "birth_year"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .operatorToken, text: "-"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .punctuation, text: "("),
      TokenSnapshot(type: .word, text: "CURRENT_DATE"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .operatorToken, text: "+"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "1"),
      TokenSnapshot(type: .punctuation, text: ")"),
      TokenSnapshot(type: .punctuation, text: ")"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses function call
@Test func parity_parser_functionCallTokenized() throws {
  try expectTokens(
    from: "SELECT sqrt(2)",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "sqrt"),
      TokenSnapshot(type: .punctuation, text: "("),
      TokenSnapshot(type: .word, text: "2"),
      TokenSnapshot(type: .punctuation, text: ")"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses LIMIT clause with count
@Test func parity_parser_limitWithCountTokenized() throws {
  try expectTokens(
    from: "LIMIT 15;",
    expected: [
      TokenSnapshot(type: .word, text: "LIMIT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "15"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses LIMIT clause with offset and count
@Test func parity_parser_limitWithOffsetAndCountTokenized() throws {
  try expectTokens(
    from: "LIMIT 100, 15;",
    expected: [
      TokenSnapshot(type: .word, text: "LIMIT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "100"),
      TokenSnapshot(type: .punctuation, text: ","),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "15"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses LIMIT clause with longer expressions
@Test func parity_parser_limitWithExtendedExpressionsTokenized() throws {
  try expectTokens(
    from: "LIMIT 50 + 50, 3 * 2;",
    expected: [
      TokenSnapshot(type: .word, text: "LIMIT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "50"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .operatorToken, text: "+"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "50"),
      TokenSnapshot(type: .punctuation, text: ","),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "3"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .operatorToken, text: "*"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "2"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses BETWEEN expression
@Test func parity_parser_betweenExpressionTokenized() throws {
  try expectTokens(
    from: "WHERE age BETWEEN 18 AND 63",
    expected: [
      TokenSnapshot(type: .word, text: "WHERE"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "age"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "BETWEEN"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "18"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "AND"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "63"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses set operations
@Test func parity_parser_setOperationsTokenized() throws {
  try expectTokens(
    from: "SELECT foo FROM bar UNION ALL SELECT foo FROM baz",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "foo"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "FROM"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "bar"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "UNION"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "ALL"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "foo"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "FROM"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "baz"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses SELECT *
@Test func parity_parser_selectStarTokenized() throws {
  try expectTokens(
    from: "SELECT *",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .operatorToken, text: "*"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses SELECT ident.*
@Test func parity_parser_selectIdentDotStarTokenized() throws {
  try expectTokens(
    from: "SELECT ident.*",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "ident"),
      TokenSnapshot(type: .punctuation, text: "."),
      TokenSnapshot(type: .operatorToken, text: "*"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses function name with and without parameters
@Test func parity_parser_functionNamesTokenized() throws {
  try expectTokens(
    from: "SELECT CURRENT_TIME a, CURRENT_TIME() b;",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "CURRENT_TIME"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "a"),
      TokenSnapshot(type: .punctuation, text: ","),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "CURRENT_TIME"),
      TokenSnapshot(type: .punctuation, text: "("),
      TokenSnapshot(type: .punctuation, text: ")"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "b"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses curly braces
@Test func parity_parser_curlyBracesTokenized() throws {
  try expectTokens(
    from: "SELECT {foo: bar};",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "{foo:"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "bar}"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses square brackets
@Test func parity_parser_squareBracketsTokenized() throws {
  try expectTokens(
    from: "SELECT [1, 2, 3];",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .quoted, text: "[1, 2, 3]"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses qualified.identifier.sequence
@Test func parity_parser_qualifiedIdentifierSequenceTokenized() throws {
  try expectTokens(
    from: "SELECT foo.bar.baz;",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "foo"),
      TokenSnapshot(type: .punctuation, text: "."),
      TokenSnapshot(type: .word, text: "bar"),
      TokenSnapshot(type: .punctuation, text: "."),
      TokenSnapshot(type: .word, text: "baz"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}

// Upstream: test/unit/Parser.test.ts :: parses CASE expression
@Test func parity_parser_caseExpressionTokenized() throws {
  try expectTokens(
    from: "SELECT CASE foo WHEN 1+1 THEN 10 ELSE 20 END;",
    expected: [
      TokenSnapshot(type: .word, text: "SELECT"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "CASE"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "foo"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "WHEN"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "1"),
      TokenSnapshot(type: .operatorToken, text: "+"),
      TokenSnapshot(type: .word, text: "1"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "THEN"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "10"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "ELSE"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "20"),
      TokenSnapshot(type: .whitespace, text: " "),
      TokenSnapshot(type: .word, text: "END"),
      TokenSnapshot(type: .punctuation, text: ";"),
    ]
  )
}
