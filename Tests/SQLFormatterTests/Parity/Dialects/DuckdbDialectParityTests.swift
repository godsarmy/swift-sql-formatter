import Testing

@testable import SQLFormatter

private let duckdbDialect: Dialect = .duckDB

private func duckdbOptions(
  keywordCase: KeywordCase = .preserve,
  dataTypeCase: KeywordCase = .preserve
) -> FormatOptions {
  FormatOptions(
    dialect: duckdbDialect,
    keywordCase: keywordCase,
    dataTypeCase: dataTypeCase
  )
}

// Upstream: test/duckdb.test.ts :: formats prefix aliases
// Swift divergence: formatter inserts spaces around prefix colons.
@Test func parity_duckdb_formatsPrefixAliases() throws {
  try assertFormatDialect(
    "SELECT foo:10, bar:'hello';",
    dialect: duckdbDialect,
    dedent(
      """
      SELECT
        foo : 10,
        bar : 'hello';
      """
    )
  )
}

// Upstream: test/duckdb.test.ts :: formats {} struct literal (string keys)
// Swift divergence: braces keep a leading space around brace contents and add spaces around colons.
@Test func parity_duckdb_formatsStructLiteralWithStringKeys() throws {
  try assertFormatDialect(
    "SELECT {'id':1,'type':'Tarzan'} AS obj;",
    dialect: duckdbDialect,
    dedent(
      """
      SELECT
        { 'id' : 1,
        'type' : 'Tarzan' } AS obj;
      """
    )
  )
}

// Upstream: test/duckdb.test.ts :: formats {} struct literal (identifier keys)
// Swift divergence: identifier keys show the same spacing behavior as string keys.
@Test func parity_duckdb_formatsStructLiteralWithIdentifierKeys() throws {
  try assertFormatDialect(
    "SELECT {id:1,type:'Tarzan'} AS obj;",
    dialect: duckdbDialect,
    dedent(
      """
      SELECT
        {id : 1,
        type : 'Tarzan' } AS obj;
      """
    )
  )
}

// Upstream: test/duckdb.test.ts :: formats {} struct literal (quoted identifier keys)
// Swift divergence: quoted keys mirror the spacing of other struct literals.
@Test func parity_duckdb_formatsStructLiteralWithQuotedIdentifierKeys() throws {
  try assertFormatDialect(
    "SELECT {\"id\":1,\"type\":'Tarzan'} AS obj;",
    dialect: duckdbDialect,
    dedent(
      """
      SELECT
        { "id" : 1,
        "type" : 'Tarzan' } AS obj;
      """
    )
  )
}

// Upstream: test/duckdb.test.ts :: formats large struct and list literals
// Swift divergence: formatter produces a compact, less-indented layout for nested literals.
@Test func parity_duckdb_formatsLargeStructAndListLiterals() throws {
  try assertFormatDialect(
    """
    INSERT INTO heroes (KEY, VALUE) VALUES ('123', {'id': 1, 'type': 'Tarzan',
    'array': [123456789, 123456789, 123456789, 123456789, 123456789], 'hello': 'world'});
    """,
    dialect: duckdbDialect,
    dedent(
      """
      INSERT INTO heroes(KEY,
      VALUE) VALUES('123',
      { 'id' : 1,
      'type' : 'Tarzan',
      'array' : [123456789,
      123456789,
      123456789,
      123456789,
      123456789],
      'hello' : 'world' });
      """
    )
  )
}

// Upstream: test/duckdb.test.ts :: formats JSON data type
// Swift divergence: types remain lowercase and parentheses stay glued to the table name.
@Test func parity_duckdb_formatsJsonDataType() throws {
  try assertFormatDialect(
    "CREATE TABLE foo (bar json, baz json);",
    dialect: duckdbDialect,
    "CREATE TABLE foo(bar json,\nbaz json);",
    options: duckdbOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/duckdb.test.ts :: capitalizes IS NOT NULL
// Swift divergence: keywords are preserved in lowercase despite the upper keyword case.
@Test func parity_duckdb_capitalizesIsNotNull() throws {
  try assertFormatDialect(
    "SELECT 1 is not null;",
    dialect: duckdbDialect,
    dedent(
      """
      SELECT
        1 is not null;
      """
    ),
    options: duckdbOptions(keywordCase: .upper)
  )
}
