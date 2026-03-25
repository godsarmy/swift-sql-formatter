import Testing

@testable import SQLFormatter

private let db2Dialect: Dialect = .db2

// Upstream: test/db2.test.ts :: supports non-standard FOR clause
// Swift divergence: DB2 FOR clause keywords break across lines instead of staying grouped after FROM.
@Test func parity_db2_supportsNonStandardForClause() throws {
  try assertFormatDialect(
    "SELECT * FROM tbl FOR UPDATE OF other_tbl FOR RS USE AND KEEP EXCLUSIVE LOCKS",
    dialect: db2Dialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl FOR
      UPDATE OF other_tbl FOR RS USE
      AND KEEP EXCLUSIVE LOCKS
      """
    )
  )
}
