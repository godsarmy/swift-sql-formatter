import Testing

@testable import SQLFormatter

// Upstream: test/features/schema.ts :: formats simple SET SCHEMA statements
// Swift divergence: splits the SET keyword and schema identifier onto separate lines with SCHEMA indented.
@Test func parity_schema_formatsSimpleSetSchemaStatements() throws {
  try assertFormat(
    "SET SCHEMA schema1;",
    """
      SET
        SCHEMA schema1;
    """
  )
}
