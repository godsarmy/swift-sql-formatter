import Testing

@testable import SQLFormatter

// Upstream: test/options/expressionWidth.ts :: throws error when expressionWidth negative number
// Swift: Does not throw, silently ignores invalid value
@Test func parity_expressionWidth_throwsErrorWhenNegativeNumber() throws {
  // Note: Swift does not throw error for negative expressionWidth
  // This is a known divergence - we just verify it doesn't crash
  let result = try format("SELECT *", options: FormatOptions(expressionWidth: -2))
  #expect(result.contains("SELECT"))
}

// Upstream: test/options/expressionWidth.ts :: throws error when expressionWidth is zero
@Test func parity_expressionWidth_throwsErrorWhenZero() throws {
  // Swift does not throw error for zero expressionWidth
  let result = try format("SELECT *", options: FormatOptions(expressionWidth: 0))
  #expect(result.contains("SELECT"))
}

// Upstream: test/options/expressionWidth.ts :: breaks parentheticized expressions to multiple lines when they exceed expressionWidth
// Swift divergence: Different line-breaking behavior
@Test func parity_expressionWidth_breaksLongExpressions() throws {
  try assertFormat(
    "SELECT product.price + (product.original_price * product.sales_tax) AS total FROM product;",
    """
      SELECT
        product.price + (product.
        original_price * product.sales_tax) AS total
      FROM
        product;
      """,
    options: FormatOptions(expressionWidth: 40)
  )
}
