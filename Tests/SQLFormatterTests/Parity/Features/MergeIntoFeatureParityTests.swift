import Testing

@testable import SQLFormatter

// Upstream: test/features/mergeInto.ts :: formats MERGE INTO
// Swift divergence: MERGE results split across separate clauses compared to upstream expectation.
@Test func parity_mergeInto_formatsMergeInto() throws {
  try assertFormat(
    """
    MERGE INTO DetailedInventory AS t
    USING Inventory AS i
    ON t.product = i.product
    WHEN MATCHED THEN
      UPDATE SET quantity = t.quantity + i.quantity
    WHEN NOT MATCHED THEN
      INSERT (product, quantity) VALUES ('Horse saddle', 12);
    """,
    """
    MERGE INTO DetailedInventory AS t
    USING
      Inventory AS i
    ON
      t.product = i.product
    WHEN MATCHED
    THEN
    UPDATE
    SET
      quantity = t.quantity + i.quantity
    WHEN NOT MATCHED
    THEN
      INSERT (product,
      quantity)
    VALUES
      ('Horse saddle',
      12);
    """
  )
}
