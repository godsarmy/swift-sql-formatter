import Testing

@testable import SQLFormatter

private let clickhouseDialect: Dialect = .clickHouse

// Upstream: test/clickhouse.test.ts :: supports map literals
// Swift divergence: Swift inserts spaces before colons and keeps no space after the colon for literal entries.
@Test func parity_clickhouse_formatsMapLiterals() throws {
  try assertFormatDialect(
    "SELECT {'foo':1,'bar':10,'baz':2,'zap':8};",
    dialect: clickhouseDialect,
    dedent(
      """
      SELECT
        { 'foo' :1,
        'bar' :10,
        'baz' :2,
        'zap' :8};
      """
    )
  )
}

// Upstream: test/clickhouse.test.ts :: supports the ternary operator
// Swift divergence: spaces around the `?` and the colon are omitted in Swift's formatting.
@Test func parity_clickhouse_formatsTernaryOperator() throws {
  try assertFormatDialect(
    "SELECT foo?bar: baz;",
    dialect: clickhouseDialect,
    dedent(
      """
      SELECT
        foo?bar: baz;
      """
    )
  )
}

// Upstream: test/clickhouse.test.ts :: supports the lambda creation operator
// Swift divergence: the array literal argument is wrapped onto the next line without indentation.
@Test func parity_clickhouse_formatsLambdaCreationOperator() throws {
  try assertFormatDialect(
    "SELECT arrayMap(x->2*x, [1,2,3,4]) AS result;",
    dialect: clickhouseDialect,
    dedent(
      """
      SELECT
        arrayMap(x -> 2 * x,
        [1,2,3,4]) AS result;
      """
    )
  )
}

// Upstream: test/clickhouse.test.ts :: formats WITH clause after INSERT INTO
// Swift divergence: the CTE closing parenthesis stays on the same line as `numbers(10)` instead of being on its own line.
@Test func parity_clickhouse_formatsInsertWithClauseFollowingSelect() throws {
  try assertFormatDialect(
    "INSERT INTO x WITH y AS (SELECT * FROM numbers(10)) SELECT * FROM y;",
    dialect: clickhouseDialect,
    dedent(
      """
      INSERT INTO x
      WITH
        y AS (
      SELECT
        *
      FROM
        numbers(10))
      SELECT
        *
      FROM
        y;
      """
    )
  )
}

// Upstream: test/clickhouse.test.ts :: formats DROP multiple tables
// Swift divergence: the formatter does not indent continuation lines for the additional table names.
@Test func parity_clickhouse_formatsDropMultipleTables() throws {
  try assertFormatDialect(
    "DROP TABLE mydb.tab1, mydb.tab2;",
    dialect: clickhouseDialect,
    dedent(
      """
      DROP TABLE mydb.tab1,
      mydb.tab2;
      """
    )
  )
}

// Upstream: test/clickhouse.test.ts :: formats ALTER TABLE ... RENAME COLUMN statement
// Swift divergence: Swift leaves the entire statement on one line instead of splitting keywords across multiple lines.
@Test func parity_clickhouse_formatsRenameColumnStatement() throws {
  try assertFormatDialect(
    "ALTER TABLE supplier RENAME COLUMN supplier_id TO id;",
    dialect: clickhouseDialect,
    dedent(
      """
      ALTER TABLE supplier RENAME COLUMN supplier_id TO id;
      """
    )
  )
}
