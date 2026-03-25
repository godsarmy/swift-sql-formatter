import Testing

@testable import SQLFormatter

private let mariaDbDialect: Dialect = .mariaDB

// Upstream: test/mariadb.test.ts :: supports @"name" variables
// Swift divergence: formatter inserts a space between @ and the double-quoted identifier.
@Test func parity_mariadb_supportsDoubleQuotedAtVariables() throws {
  try assertFormatDialect(
    #"SELECT @"foo fo", @"foo\"x", @"foo""y" FROM tbl;"#,
    dialect: mariaDbDialect,
    dedent(
      #"""
      SELECT
        @ "foo fo",
        @ "foo\"x",
        @ "foo""y"
      FROM
        tbl;
      """#
    )
  )
}

// Upstream: test/mariadb.test.ts :: supports @'name' variables
// Swift divergence: formatter inserts a space between @ and the single-quoted identifier.
@Test func parity_mariadb_supportsSingleQuotedAtVariables() throws {
  try assertFormatDialect(
    "SELECT @'bar ar', @'bar\\'x', @'bar''y' FROM tbl;",
    dialect: mariaDbDialect,
    dedent(
      #"""
      SELECT
        @ 'bar ar',
        @ 'bar\'x',
        @ 'bar''y'
      FROM
        tbl;
      """#
    )
  )
}

// Upstream: test/mariadb.test.ts :: formats ALTER TABLE ... ALTER COLUMN
@Test func parity_mariadb_formatsAlterColumn() throws {
  try assertFormatDialect(
    """
      ALTER TABLE t ALTER COLUMN foo SET DEFAULT 10;
      ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;
    """,
    dialect: mariaDbDialect,
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
