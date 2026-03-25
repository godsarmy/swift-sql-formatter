import Testing

@testable import SQLFormatter

// Swift divergence: Parser AST snapshots are approximated via deterministic tokenizer sequences.
private func assertParserSnapshot(
  fixture name: String,
  directory: String = "Parser",
  expected: [FixtureTokenSnapshot]
) throws {
  let sql = try loadFixtureSQL(named: name, directory: directory)
  let snapshots = fixtureTokenSnapshots(from: try tokenizeFixtureSQL(sql))
  #expect(snapshots == expected)
}

@Test
func snapshot_parser_statementList() throws {
  try assertParserSnapshot(
    fixture: "statement_list.sql",
    expected: [
      .init(type: .word, text: "foo"),
      .init(type: .punctuation, text: ";"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "bar"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_setOperations() throws {
  try assertParserSnapshot(
    fixture: "set_operations.sql",
    expected: [
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "foo"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "FROM"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "bar"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "UNION"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "ALL"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "foo"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "FROM"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "baz"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_selectProjections() throws {
  try assertParserSnapshot(
    fixture: "select_projections.sql",
    expected: [
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .operatorToken, text: "*"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "foo"),
      .init(type: .punctuation, text: "."),
      .init(type: .word, text: "bar"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "AS"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "alias"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "CURRENT_TIME"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "a"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "CURRENT_TIME"),
      .init(type: .punctuation, text: "("),
      .init(type: .punctuation, text: ")"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "b"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_betweenCase() throws {
  try assertParserSnapshot(
    fixture: "between_case.sql",
    expected: [
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "CASE"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "foo"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "WHEN"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "1"),
      .init(type: .whitespace, text: " "),
      .init(type: .operatorToken, text: "+"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "1"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "THEN"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "10"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "ELSE"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "20"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "END"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "WHERE"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "age"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "BETWEEN"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "18"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "AND"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "63"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_limitVariants() throws {
  try assertParserSnapshot(
    fixture: "limit_variants.sql",
    expected: [
      .init(type: .word, text: "LIMIT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "15"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),

      .init(type: .word, text: "LIMIT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "100"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "15"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),

      .init(type: .word, text: "LIMIT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "50"),
      .init(type: .whitespace, text: " "),
      .init(type: .operatorToken, text: "+"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "50"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "3"),
      .init(type: .whitespace, text: " "),
      .init(type: .operatorToken, text: "*"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "2"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_arrayPropertyAccess() throws {
  try assertParserSnapshot(
    fixture: "array_property_access.sql",
    expected: [
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "my_array"),
      .init(type: .quoted, text: "[5]"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "foo"),
      .init(type: .punctuation, text: "."),
      .init(type: .word, text: "bar"),
      .init(type: .punctuation, text: "."),
      .init(type: .word, text: "baz"),
      .init(type: .quoted, text: "[1]"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_bracesParenthesesBrackets() throws {
  try assertParserSnapshot(
    fixture: "braces_parentheses_brackets.sql",
    expected: [
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "{foo:"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "bar}"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .punctuation, text: "("),
      .init(type: .word, text: "birth_year"),
      .init(type: .whitespace, text: " "),
      .init(type: .operatorToken, text: "-"),
      .init(type: .whitespace, text: " "),
      .init(type: .punctuation, text: "("),
      .init(type: .word, text: "CURRENT_DATE"),
      .init(type: .whitespace, text: " "),
      .init(type: .operatorToken, text: "+"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "1"),
      .init(type: .punctuation, text: ")"),
      .init(type: .punctuation, text: ")"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .quoted, text: "[1, 2, 3]"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}

@Test
func snapshot_parser_functionCalls() throws {
  try assertParserSnapshot(
    fixture: "function_calls.sql",
    expected: [
      .init(type: .word, text: "SELECT"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "sqrt"),
      .init(type: .punctuation, text: "("),
      .init(type: .word, text: "2"),
      .init(type: .punctuation, text: ")"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "CURRENT_TIME"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "a"),
      .init(type: .punctuation, text: ","),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "CURRENT_DATE"),
      .init(type: .punctuation, text: "("),
      .init(type: .punctuation, text: ")"),
      .init(type: .whitespace, text: " "),
      .init(type: .word, text: "b"),
      .init(type: .punctuation, text: ";"),
      .init(type: .newline, text: "\n"),
    ]
  )
}
