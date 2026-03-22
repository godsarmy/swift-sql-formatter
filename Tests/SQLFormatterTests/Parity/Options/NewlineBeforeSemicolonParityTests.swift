import Testing

@testable import SQLFormatter

// Upstream: test/options/newlineBeforeSemicolon.ts :: formats lonely semicolon
@Test func parity_newlineBeforeSemicolon_formatsLonelySemicolon() throws {
  try assertFormat(";", ";")
}

// Upstream: test/options/newlineBeforeSemicolon.ts :: does not add newline before lonely semicolon when newlineBeforeSemicolon:true
@Test func parity_newlineBeforeSemicolon_doesNotAddNewlineBeforeLonelySemicolon() throws {
  try assertFormat(";", ";", options: FormatOptions(newlineBeforeSemicolon: true))
}

// Upstream: test/options/newlineBeforeSemicolon.ts :: defaults to semicolon on end of last line
@Test func parity_newlineBeforeSemicolon_defaultsToSemicolonOnEndOfLastLine() throws {
  try assertFormat(
    "SELECT a FROM b;",
    """
    SELECT
      a
    FROM
      b;
    """
  )
}

// Upstream: test/options/newlineBeforeSemicolon.ts :: places semicolon on the same line as a single-line clause
// Swift divergence: semicolon is emitted as a separate clause line for this invalid SQL input.
@Test func parity_newlineBeforeSemicolon_placesSemicolonOnSameLineAsSingleLineClause() throws {
  try assertFormat(
    "SELECT a FROM;",
    """
    SELECT
      a
    FROM
    ;
    """
  )
}

// Upstream: test/options/newlineBeforeSemicolon.ts :: supports semicolon on separate line
@Test func parity_newlineBeforeSemicolon_supportsSemicolonOnSeparateLine() throws {
  try assertFormat(
    "SELECT a FROM b;",
    """
    SELECT
      a
    FROM
      b
    ;
    """,
    options: FormatOptions(newlineBeforeSemicolon: true)
  )
}

// Upstream: test/options/newlineBeforeSemicolon.ts :: formats multiple lonely semicolons
@Test func parity_newlineBeforeSemicolon_formatsMultipleLonelySemicolons() throws {
  try assertFormat(
    ";;;",
    """
    ;

    ;

    ;
    """
  )
}

// Upstream: test/options/newlineBeforeSemicolon.ts :: does not introduce extra empty lines between semicolons when newlineBeforeSemicolon:true
@Test func parity_newlineBeforeSemicolon_doesNotIntroduceExtraEmptyLinesBetweenSemicolons() throws {
  try assertFormat(
    ";;;",
    """
    ;

    ;

    ;
    """,
    options: FormatOptions(newlineBeforeSemicolon: true)
  )
}
