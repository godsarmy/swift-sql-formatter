import Testing

@testable import SQLFormatter

// Upstream: test/features/insertInto.ts :: formats simple INSERT INTO
// Swift divergence: columns stay inline without spacing and break individually instead of the upstream layout.
@Test func parity_insertInto_formatsSimpleInsertInto() throws {
  try assertFormat(
    "INSERT INTO Customers (ID, MoneyBalance, Address, City) VALUES (12,-123.4, 'Skagen 2111','Stv');",
    """
    INSERT INTO Customers(ID,
    MoneyBalance,
    Address,
    City)
    VALUES
      (12,
      - 123.4,
      'Skagen 2111',
      'Stv');
    """
  )
}

// Upstream: test/features/insertInto.ts :: formats INSERT without INTO
// Swift divergence: Swift keeps the column list inline and splits items across lines inside the parentheses.
@Test func parity_insertInto_formatsInsertWithoutInto() throws {
  try assertFormat(
    "INSERT Customers (ID, MoneyBalance, Address, City) VALUES (12,-123.4, 'Skagen 2111','Stv');",
    """
    INSERT Customers(ID,
    MoneyBalance,
    Address,
    City)
    VALUES
      (12,
      - 123.4,
      'Skagen 2111',
      'Stv');
    """
  )
}
