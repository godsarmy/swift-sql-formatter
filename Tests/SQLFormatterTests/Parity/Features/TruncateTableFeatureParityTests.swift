import Testing

@testable import SQLFormatter

// Upstream: test/features/truncateTable.ts :: formats TRUNCATE TABLE statement
@Test func parity_truncateTable_formatsTruncateTableStatement() throws {
  try assertFormat(
    "TRUNCATE TABLE Customers;",
    """
      TRUNCATE TABLE Customers;
    """
  )
}

// Upstream: test/features/truncateTable.ts :: formats TRUNCATE statement (without TABLE)
@Test func parity_truncateTable_formatsTruncateStatementWithoutTable() throws {
  try assertFormat(
    "TRUNCATE Customers;",
    """
      TRUNCATE Customers;
    """
  )
}
