import Testing

@testable import SQLFormatter

// Upstream: test/features/isDistinctFrom.ts :: supports IS [NOT] DISTINCT FROM operator
// Swift divergence: formatter breaks "IS DISTINCT FROM" onto multiple lines with FROM separately.
@Test func parity_isDistinctFrom_supportsIsDistinctFromOperator() throws {
  try assertFormat(
    """
    SELECT x IS DISTINCT FROM y, x IS NOT DISTINCT FROM y
    """,
    """
    SELECT
      x IS DISTINCT
    FROM
      y,
      x IS NOT DISTINCT
    FROM
      y
    """
  )
}
