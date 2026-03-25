import Testing

@testable import SQLFormatter

private let tidbDialect: Dialect = .tiDB

// Upstream: test/tidb.test.ts :: supports @"name" variables
// Swift divergence: formatter inserts a space between @ and quoted identifiers.
@Test func parity_tidb_supportsAtDoubleQuotedNameVariables() throws {
  try assertFormatDialect(
    "SELECT @\"foo fo\", @\"foo\\\"x\", @\"foo\"\"y\" FROM tbl;",
    dialect: tidbDialect,
    dedent(
      """
      SELECT
        @ "foo fo",
        @ "foo\\"x",
        @ "foo""y"
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/tidb.test.ts :: supports @'name' variables
// Swift divergence: formatter inserts a space between @ and quoted identifiers.
@Test func parity_tidb_supportsAtSingleQuotedNameVariables() throws {
  try assertFormatDialect(
    "SELECT @'bar ar', @'bar\\'x', @'bar''y' FROM tbl;",
    dialect: tidbDialect,
    dedent(
      """
      SELECT
        @ 'bar ar',
        @ 'bar\\'x',
        @ 'bar''y'
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/tidb.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: SET DEFAULT clause stays on the same line and column clauses are inline.
@Test func parity_tidb_formatsAlterTableAlterColumn() throws {
  try assertFormatDialect(
    """
    ALTER TABLE t ALTER COLUMN foo SET DEFAULT 10;
     ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;
    """,
    dialect: tidbDialect,
    dedent(
      """
      ALTER TABLE t ALTER COLUMN foo
      SET
        DEFAULT 10;

      ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;
      """
    )
  )
}
