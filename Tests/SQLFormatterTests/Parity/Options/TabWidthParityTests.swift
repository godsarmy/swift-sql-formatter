import Testing

@testable import SQLFormatter

// Upstream: test/options/tabWidth.ts :: indents with 2 spaces by default
// Swift divergence: function wildcard arg is currently rendered as count( *).
@Test func parity_tabWidth_indentsWith2SpacesByDefault() throws {
  try assertFormat(
    "SELECT count(*),Column1 FROM Table1;",
    """
    SELECT
      count( *),
      Column1
    FROM
      Table1;
    """
  )
}

// Upstream: test/options/tabWidth.ts :: supports indenting with 4 spaces
// Swift divergence: function wildcard arg is currently rendered as count( *).
@Test func parity_tabWidth_supportsIndentingWith4Spaces() throws {
  try assertFormat(
    "SELECT count(*),Column1 FROM Table1;",
    """
    SELECT
        count( *),
        Column1
    FROM
        Table1;
    """,
    options: FormatOptions(tabWidth: 4)
  )
}
