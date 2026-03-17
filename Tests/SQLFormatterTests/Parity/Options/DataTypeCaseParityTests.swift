import Testing

@testable import SQLFormatter

// Upstream: test/options/dataTypeCase.ts :: preserves data type keyword case by default
// Swift divergence: Different formatting for CREATE TABLE columns (space after paren, different line breaks)
@Test func parity_dataTypeCase_preservesDataTypeKeywordCaseByDefault() throws {
  try assertFormat(
    "CREATE TABLE users ( user_id iNt PRIMARY KEY, total_earnings Decimal(5, 2) NOT NULL )",
    """
      CREATE TABLE users( user_id iNt PRIMARY KEY,
      total_earnings Decimal(5,
      2) NOT NULL)
      """
  )
}

// Upstream: test/options/dataTypeCase.ts :: converts data type keyword case to uppercase
// Swift divergence: Different formatting for CREATE TABLE columns (space after paren, different line breaks)
@Test func parity_dataTypeCase_convertsDataTypeKeywordCaseToUppercase() throws {
  try assertFormat(
    "CREATE TABLE users ( user_id iNt PRIMARY KEY, total_earnings Decimal(5, 2) NOT NULL )",
    """
      CREATE TABLE users( user_id INT PRIMARY KEY,
      total_earnings DECIMAL(5,
      2) NOT NULL)
      """,
    options: FormatOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/options/dataTypeCase.ts :: converts data type keyword case to lowercase
// Swift divergence: Different formatting for CREATE TABLE columns (space after paren, different line breaks)
@Test func parity_dataTypeCase_convertsDataTypeKeywordCaseToLowercase() throws {
  try assertFormat(
    "CREATE TABLE users ( user_id iNt PRIMARY KEY, total_earnings Decimal(5, 2) NOT NULL )",
    """
      CREATE TABLE users( user_id int PRIMARY KEY,
      total_earnings decimal(5,
      2) NOT NULL)
      """,
    options: FormatOptions(dataTypeCase: .lower)
  )
}
