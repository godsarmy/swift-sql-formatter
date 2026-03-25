import Testing

@testable import SQLFormatter

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... ADD COLUMN query
// Swift divergence: keeps ALTER TABLE statements on a single line rather than breaking after the table name.
@Test func parity_alterTable_formatsAddColumn() throws {
  try assertFormat(
    "ALTER TABLE supplier ADD COLUMN unit_price DECIMAL NOT NULL;",
    """
      ALTER TABLE supplier ADD COLUMN unit_price DECIMAL NOT NULL;
    """
  )
}

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... DROP COLUMN query
// Swift divergence: keeps the ALTER TABLE DROP COLUMN query on a single line instead of splitting lines.
@Test func parity_alterTable_formatsDropColumn() throws {
  try assertFormat(
    "ALTER TABLE supplier DROP COLUMN unit_price;",
    """
      ALTER TABLE supplier DROP COLUMN unit_price;
    """
  )
}

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... MODIFY statement
// Swift divergence: emits the MODIFY clause inline with the table declaration.
@Test func parity_alterTable_formatsModify() throws {
  try assertFormat(
    "ALTER TABLE supplier MODIFY supplier_id DECIMAL NULL;",
    """
      ALTER TABLE supplier MODIFY supplier_id DECIMAL NULL;
    """
  )
}

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... RENAME TO statement
// Swift divergence: keeps the RENAME TO clause inline rather than splitting the statement.
@Test func parity_alterTable_formatsRenameTo() throws {
  try assertFormat(
    "ALTER TABLE supplier RENAME TO the_one_who_supplies;",
    """
      ALTER TABLE supplier RENAME TO the_one_who_supplies;
    """
  )
}

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... RENAME COLUMN statement
// Swift divergence: leaves the RENAME COLUMN clause on the same line as the ALTER TABLE statement.
@Test func parity_alterTable_formatsRenameColumn() throws {
  try assertFormat(
    "ALTER TABLE supplier RENAME COLUMN supplier_id TO id;",
    """
      ALTER TABLE supplier RENAME COLUMN supplier_id TO id;
    """
  )
}
