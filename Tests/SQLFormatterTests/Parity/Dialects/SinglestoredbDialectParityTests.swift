import Testing

@testable import SQLFormatter

private let singlestoreDialect: Dialect = .singleStoreDB

// Upstream: test/singlestoredb.test.ts :: formats '::' path-operator without spaces
@Test func parity_singlestoredb_formatsDoubleColonPathOperatorWithoutSpaces() throws {
  try assertFormatDialect(
    "SELECT * FROM foo WHERE json_foo::bar = 'foobar'",
    dialect: singlestoreDialect,
    dedent(
      """
      SELECT
        *
      FROM
        foo
      WHERE
        json_foo::bar = 'foobar'
      """
    )
  )
}

// Upstream: test/singlestoredb.test.ts :: formats '::$' conversion path-operator without spaces
@Test func parity_singlestoredb_formatsDoubleColonDollarPathOperatorWithoutSpaces() throws {
  try assertFormatDialect(
    "SELECT * FROM foo WHERE json_foo::$bar = 'foobar'",
    dialect: singlestoreDialect,
    dedent(
      """
      SELECT
        *
      FROM
        foo
      WHERE
        json_foo::$bar = 'foobar'
      """
    )
  )
}

// Upstream: test/singlestoredb.test.ts :: formats '::%' conversion path-operator without spaces
// Swift divergence: formatter introduces spaces before and after the '%' operator.
@Test func parity_singlestoredb_formatsDoubleColonPercentPathOperatorWithoutSpaces() throws {
  try assertFormatDialect(
    "SELECT * FROM foo WHERE json_foo::%bar = 'foobar'",
    dialect: singlestoreDialect,
    dedent(
      """
      SELECT
        *
      FROM
        foo
      WHERE
        json_foo:: % bar = 'foobar'
      """
    )
  )
}
