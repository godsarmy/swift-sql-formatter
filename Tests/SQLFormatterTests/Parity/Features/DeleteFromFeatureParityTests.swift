import Testing

@testable import SQLFormatter

// Upstream: test/features/deleteFrom.ts :: formats DELETE FROM statement
@Test func parity_deleteFrom_formatsDeleteFromStatement() throws {
  try assertFormat(
    "DELETE FROM Customers WHERE CustomerName='Alfred' AND Phone=5002132;",
    """
      DELETE FROM Customers
      WHERE
        CustomerName = 'Alfred'
        AND Phone = 5002132;
    """
  )
}

// Upstream: test/features/deleteFrom.ts :: formats DELETE statement (without FROM)
@Test func parity_deleteFrom_formatsDeleteStatementWithoutFrom() throws {
  try assertFormat(
    "DELETE Customers WHERE CustomerName='Alfred';",
    """
      DELETE Customers
      WHERE
        CustomerName = 'Alfred';
    """
  )
}
