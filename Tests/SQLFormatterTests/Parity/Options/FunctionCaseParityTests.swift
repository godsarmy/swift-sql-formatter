import Testing

@testable import SQLFormatter

// Upstream: test/options/functionCase.ts :: preserves function name case by default
@Test func parity_functionCase_preservesFunctionNameCaseByDefault() throws {
  try assertFormat(
    "SELECT MiN(price) AS min_price, Cast(item_code AS INT) FROM products",
    """
      SELECT
        MiN(price) AS min_price,
        Cast(item_code AS INT)
      FROM
        products
      """
  )
}

// Upstream: test/options/functionCase.ts :: converts function names to uppercase
@Test func parity_functionCase_convertsFunctionNamesToUppercase() throws {
  try assertFormat(
    "SELECT MiN(price) AS min_price, Cast(item_code AS INT) FROM products",
    """
      SELECT
        MIN(price) AS min_price,
        CAST(item_code AS INT)
      FROM
        products
      """,
    options: FormatOptions(functionCase: .upper)
  )
}

// Upstream: test/options/functionCase.ts :: converts function names to lowercase
@Test func parity_functionCase_convertsFunctionNamesToLowercase() throws {
  try assertFormat(
    "SELECT MiN(price) AS min_price, Cast(item_code AS INT) FROM products",
    """
      SELECT
        min(price) AS min_price,
        cast(item_code AS INT)
      FROM
        products
      """,
    options: FormatOptions(functionCase: .lower)
  )
}
