import Testing

@testable import SQLFormatter

// Upstream: test/features/update.ts :: formats simple UPDATE statement
@Test func parity_update_formatsSimpleUpdateStatement() throws {
  try assertFormat(
    "UPDATE Customers SET ContactName='Alfred Schmidt', City='Hamburg' WHERE CustomerName='Alfreds Futterkiste';",
    """
      UPDATE Customers
      SET
        ContactName = 'Alfred Schmidt',
        City = 'Hamburg'
      WHERE
        CustomerName = 'Alfreds Futterkiste';
    """
  )
}

// Upstream: test/features/update.ts :: formats UPDATE statement with AS part
// Swift divergence: parenthesized query body stays unindented
@Test func parity_update_formatsUpdateStatementWithAsPart() throws {
  try assertFormat(
    "UPDATE customers SET total_orders = order_summary.total  FROM ( SELECT * FROM bank) AS order_summary",
    """
      UPDATE customers
      SET
        total_orders = order_summary.total
      FROM
        (
      SELECT
        *
      FROM
        bank) AS order_summary
    """
  )
}

// Upstream: test/features/update.ts :: formats UPDATE statement with cursor position
// Swift divergence: CURRENT OF clause breaks onto its own line after WHERE
@Test func parity_update_formatsUpdateStatementWithCursorPosition() throws {
  try assertFormat(
    "UPDATE Customers SET Name='John' WHERE CURRENT OF my_cursor;",
    """
      UPDATE Customers
      SET
        Name = 'John'
      WHERE
        CURRENT OF my_cursor;
    """
  )
}
