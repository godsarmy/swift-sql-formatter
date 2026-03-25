import Testing

@testable import SQLFormatter

// Upstream: test/sqlite.test.ts :: supports REPLACE INTO syntax
// Swift divergence: TABLE name stays on same line as REPLACE INTO
@Test func parity_sqliteFormatter_supportsReplaceIntoSyntax() throws {
  try assertFormatDialect(
    "REPLACE INTO tbl VALUES (1,'Leopard'),(2,'Dog');",
    dialect: .sqlite,
    """
    REPLACE INTO tbl
    VALUES
      (1,
      'Leopard'),
      (2,
      'Dog');
    """
  )
}

// Upstream: test/sqlite.test.ts :: supports ON CONFLICT .. DO UPDATE syntax
// Swift divergence: ON and CONFLICT DO UPDATE tokens split across lines
@Test func parity_sqliteFormatter_supportsOnConflictDoUpdateSyntax() throws {
  try assertFormatDialect(
    "INSERT INTO tbl VALUES (1,'Leopard') ON CONFLICT DO UPDATE SET foo=1;",
    dialect: .sqlite,
    """
    INSERT INTO tbl
    VALUES
      (1,
      'Leopard')
    ON
      CONFLICT DO
    UPDATE
    SET
      foo = 1;
    """
  )
}
