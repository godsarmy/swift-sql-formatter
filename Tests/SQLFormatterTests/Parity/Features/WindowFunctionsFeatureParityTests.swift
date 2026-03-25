import Testing

@testable import SQLFormatter

// Upstream: test/features/windowFunctions.ts :: supports ROWS BETWEEN in window functions
// Swift divergence: OVER clause and PARTITION BY remain inline instead of newline across parentheses
@Test func parity_windowFunctions_supportsRowsBetween() throws {
  try assertFormat(
    """
    SELECT
      RANK() OVER (
        PARTITION BY explosion
        ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
      ) AS amount
    FROM
      tbl
    """,
    """
    SELECT
      RANK() OVER( PARTITION BY explosion
    ORDER BY
      day ROWS BETWEEN 6 PRECEDING
      AND CURRENT ROW) AS amount
    FROM
      tbl
    """
  )
}
