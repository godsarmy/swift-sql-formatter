import Testing

@testable import SQLFormatter

// Upstream: test/mysql.test.ts :: supports @"name" variables
// Swift divergence: formatter inserts a space between `@` and the quoted identifier.
@Test func parity_mysql_supportsAtDoubleQuotedVariables() throws {
  try assertFormatDialect(
    "SELECT @\"foo fo\", @\"foo\\\"x\", @\"foo\"\"y\" FROM tbl;",
    dialect: .mySQL,
    dedent(
      """
      SELECT
        @ "foo fo",
        @ "foo\\\"x",
        @ "foo""y"
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/mysql.test.ts :: supports @'name' variables
// Swift divergence: formatter inserts a space between `@` and the quoted identifier.
@Test func parity_mysql_supportsAtSingleQuotedVariables() throws {
  try assertFormatDialect(
    "SELECT @'bar ar', @'bar\\'x', @'bar''y' FROM tbl;",
    dialect: .mySQL,
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

// Upstream: test/mysql.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: SET DEFAULT and DROP DEFAULT clauses stay on the same line as ALTER COLUMN.
@Test func parity_mysql_formatsAlterColumnClauses() throws {
  try assertFormatDialect(
    "ALTER TABLE t ALTER COLUMN foo SET DEFAULT 10;\nALTER TABLE t ALTER COLUMN foo DROP DEFAULT;",
    dialect: .mySQL,
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
