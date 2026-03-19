import Testing

@testable import SQLFormatter

// Upstream: test/options/logicalOperatorNewline.ts :: by default adds newline before logical operator
@Test func parity_logicalOperatorNewline_defaultsToNewlineBeforeOperator() throws {
  try assertFormat(
    "SELECT a WHERE true AND false;",
    """
      SELECT
        a
      WHERE
        true
        AND false;
      """
  )
}

// Upstream: test/options/logicalOperatorNewline.ts :: supports newline after logical operator
@Test func parity_logicalOperatorNewline_supportsNewlineAfterOperator() throws {
  try assertFormat(
    "SELECT a WHERE true AND false;",
    """
      SELECT
        a
      WHERE
        true AND
        false;
      """,
    options: FormatOptions(logicalOperatorNewline: .after)
  )
}
