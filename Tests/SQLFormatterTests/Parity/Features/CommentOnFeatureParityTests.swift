import Testing

@testable import SQLFormatter

// Upstream: test/features/commentOn.ts :: formats COMMENT ON TABLE ...
// Swift divergence: breaks COMMENT ON clauses onto separate lines with clause keywords stacked.
@Test func parity_commentOn_formatsTableComment() throws {
  try assertFormat(
    "COMMENT ON TABLE my_table IS 'This is an awesome table.';",
    """
    COMMENT
    ON
      TABLE my_table IS 'This is an awesome table.';
    """
  )
}

// Upstream: test/features/commentOn.ts :: formats COMMENT ON COLUMN ...
// Swift divergence: clause keywords are emitted on separate lines before the object identifier line.
@Test func parity_commentOn_formatsColumnComment() throws {
  try assertFormat(
    "COMMENT ON COLUMN my_table.ssn IS 'Social Security Number';",
    """
    COMMENT
    ON
      COLUMN my_table.ssn IS 'Social Security Number';
    """
  )
}
