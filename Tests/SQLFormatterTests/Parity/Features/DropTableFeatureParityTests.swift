import Testing

@testable import SQLFormatter

// Upstream: test/features/dropTable.ts :: formats DROP TABLE statement
@Test func parity_dropTable_formatsDropTableStatement() throws {
  try assertFormat(
    "DROP TABLE admin_role;",
    """
      DROP TABLE admin_role;
    """
  )
}

// Upstream: test/features/dropTable.ts :: formats DROP TABLE IF EXISTS statement
@Test func parity_dropTable_formatsDropTableIfExistsStatement() throws {
  try assertFormat(
    "DROP TABLE IF EXISTS admin_role;",
    """
      DROP TABLE IF EXISTS admin_role;
    """
  )
}
