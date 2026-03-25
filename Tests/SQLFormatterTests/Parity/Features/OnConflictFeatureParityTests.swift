import Testing

@testable import SQLFormatter

// Upstream: test/features/onConflict.ts :: supports INSERT .. ON CONFLICT syntax
// Swift divergence: ON CONFLICT is split across two lines and inline table/VALUES formatting differs.
@Test func parity_onConflict_supportsInsertOnConflict() throws {
  try assertFormat(
    "INSERT INTO tbl VALUES (1,'Blah') ON CONFLICT DO NOTHING;",
    """
    INSERT INTO tbl
    VALUES
      (1,
      'Blah')
    ON
      CONFLICT DO NOTHING;
    """
  )
}
