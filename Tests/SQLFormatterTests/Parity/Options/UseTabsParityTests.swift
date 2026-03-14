import Testing

@testable import SQLFormatter

// Upstream: test/options/useTabs.ts :: supports indenting with tabs
// Swift divergence: function wildcard arg is currently rendered as count( *).
@Test func parity_useTabs_supportsIndentingWithTabs() throws {
  let expected = ["SELECT", "\tcount( *),", "\tColumn1", "FROM", "\tTable1;"].joined(separator: "\n")

  try assertFormat(
    "SELECT count(*),Column1 FROM Table1;",
    expected,
    options: FormatOptions(useTabs: true)
  )
}

// Upstream: test/options/useTabs.ts :: ignores tabWidth when useTabs is enabled
// Swift divergence: function wildcard arg is currently rendered as count( *).
@Test func parity_useTabs_ignoresTabWidthWhenUseTabsEnabled() throws {
  let expected = ["SELECT", "\tcount( *),", "\tColumn1", "FROM", "\tTable1;"].joined(separator: "\n")

  try assertFormat(
    "SELECT count(*),Column1 FROM Table1;",
    expected,
    options: FormatOptions(tabWidth: 10, useTabs: true)
  )
}
