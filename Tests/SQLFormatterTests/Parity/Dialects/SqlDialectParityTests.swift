import Testing

@testable import SQLFormatter

// Upstream: test/sql.test.ts :: throws error when encountering characters or operators it does not recognize
// Swift divergence: Swift formatter currently accepts those characters and treats them as identifiers instead of throwing.
@Test func parity_sqlDialect_handlesUnknownCharactersGracefully() throws {
  try assertFormat(
    "SELECT @name, :bar FROM foo;",
    """
      SELECT
        @name,
        :bar
      FROM
        foo;
    """
  )
}

// Upstream: test/sql.test.ts :: crashes when encountering unsupported curly braces
// Swift divergence: braces are treated as part of the identifier and format succeeds.
@Test func parity_sqlDialect_formatsUnsupportedCurlyBracesAsIdentifiers() throws {
  try assertFormat(
    "SELECT\n  {foo};",
    """
      SELECT
        {foo};
    """
  )
}

// Upstream: test/sql.test.ts :: treats ASC and DESC as reserved keywords
@Test func parity_sqlDialect_respectsAscDescAsReservedKeywords() throws {
  try assertFormat(
    "SELECT foo FROM bar ORDER BY foo asc, zap desc",
    """
      SELECT
        foo
      FROM
        bar
      ORDER BY
        foo ASC,
        zap DESC
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/sql.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: ALTER COLUMN clauses remain on one line, and SET/RESTART value parts wrap differently.
@Test func parity_sqlDialect_formatsAlterColumn() throws {
  try assertFormat(
    """
      ALTER TABLE t ALTER COLUMN foo SET DEFAULT 5;
      ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;
      ALTER TABLE t ALTER COLUMN foo DROP SCOPE CASCADE;
      ALTER TABLE t ALTER COLUMN foo RESTART WITH 10;
    """,
    """
      ALTER TABLE t ALTER COLUMN foo
      SET
        DEFAULT 5;

      ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;

      ALTER TABLE t ALTER COLUMN foo DROP SCOPE CASCADE;

      ALTER TABLE t ALTER COLUMN foo RESTART
      WITH
        10;
    """
  )
}
