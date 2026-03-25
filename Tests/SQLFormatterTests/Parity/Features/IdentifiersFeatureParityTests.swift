import Testing

@testable import SQLFormatter

// Upstream: test/features/identifiers.ts :: supports double-quoted identifiers
@Test func parity_identifiers_supportsDoubleQuotedIdentifiers() throws {
  try assertFormat(
    "\"foo JOIN bar\"",
    "\"foo JOIN bar\""
  )

  try assertFormat(
    """
    SELECT "where" FROM "update"
    """,
    """
    SELECT
      "where"
    FROM
      "update"
    """
  )
}

// Upstream: test/features/identifiers.ts :: no space around dot between two double-quoted identifiers
@Test func parity_identifiers_noSpaceAroundDotBetweenDoubleQuotedIdentifiers() throws {
  try assertFormat(
    "SELECT \"my table\".\"col name\";",
    """
    SELECT
      "my table"."col name";
    """
  )
}

// Upstream: test/features/identifiers.ts :: supports escaping double-quote by doubling it
@Test func parity_identifiers_supportsEscapingDoubleQuoteByDoubling() throws {
  try assertFormat(
    "\"foo\"\"bar\"",
    "\"foo\"\"bar\""
  )
}

// Upstream: test/features/identifiers.ts :: does not support escaping double-quote with a backslash
// Swift divergence: backslash escaping is accepted even when only repeated-quote escaping is expected.
@Test func parity_identifiers_rejectsBackslashEscapedDoubleQuoteWhenOnlyDoubleQuoteEscapingEnabled()
  throws
{
  try assertFormat(
    "\"foo \\\" JOIN bar\"",
    "\"foo \\\" JOIN bar\""
  )
}

// Upstream: test/features/identifiers.ts :: supports backslash-escaped double-quoted identifiers
@Test func parity_identifiers_supportsBackslashEscapedDoubleQuotedIdentifiers() throws {
  try assertFormat(
    "\"foo \\\" JOIN bar\"",
    "\"foo \\\" JOIN bar\""
  )
}

// Upstream: test/features/identifiers.ts :: does not support escaping double-quote by doubling it
// Swift divergence: doubled double-quotes are accepted even when only backslash escaping is expected.
@Test func parity_identifiers_rejectsDoubleQuoteEscapingWhenOnlyBackslashEscapingEnabled() throws {
  try assertFormat(
    "\"foo \"\" JOIN bar\"",
    "\"foo \"\" JOIN bar\""
  )
}

// Upstream: test/features/identifiers.ts :: supports backtick-quoted identifiers
@Test func parity_identifiers_supportsBacktickQuotedIdentifiers() throws {
  try assertFormat(
    "`foo JOIN bar`",
    "`foo JOIN bar`"
  )

  try assertFormat(
    """
    SELECT `where` FROM `update`
    """,
    """
    SELECT
      `where`
    FROM
      `update`
    """
  )
}

// Upstream: test/features/identifiers.ts :: supports escaping backtick by doubling it
@Test func parity_identifiers_supportsEscapingBacktickByDoubling() throws {
  try assertFormat(
    "`foo `` JOIN bar`",
    "`foo `` JOIN bar`"
  )
}

// Upstream: test/features/identifiers.ts :: no space around dot between two backtick-quoted identifiers
@Test func parity_identifiers_noSpaceAroundDotBetweenBacktickQuotedIdentifiers() throws {
  try assertFormat(
    "SELECT `my table`.`col name`;",
    """
    SELECT
      `my table`.`col name`;
    """
  )
}

// Upstream: test/features/identifiers.ts :: supports unicode double-quoted identifiers
// Swift divergence: U& prefixes are split from identifiers with a space.
@Test func parity_identifiers_supportsUnicodeDoubleQuotedIdentifiers() throws {
  try assertFormat(
    "U&\"foo JOIN bar\"",
    "U& \"foo JOIN bar\""
  )

  try assertFormat(
    """
    SELECT U&"where" FROM U&"update"
    """,
    """
    SELECT
      U& "where"
    FROM
      U& "update"
    """
  )
}

// Upstream: test/features/identifiers.ts :: no space around dot between unicode double-quoted identifiers
// Swift divergence: U& prefixes remain separated from identifiers.
@Test func parity_identifiers_noSpaceAroundDotBetweenUnicodeDoubleQuotedIdentifiers() throws {
  try assertFormat(
    "SELECT U&\"my table\".U&\"col name\";",
    """
    SELECT
      U& "my table".U& "col name";
    """
  )
}

// Upstream: test/features/identifiers.ts :: supports escaping in U&"" strings by repeated quote
// Swift divergence: U& prefix is split from the quoted identifier.
@Test func parity_identifiers_supportsEscapingInUnicodeStringsByRepeatedQuote() throws {
  try assertFormat(
    "U&\"foo \"\" JOIN bar\"",
    "U& \"foo \"\" JOIN bar\""
  )
}

// Upstream: test/features/identifiers.ts :: detects consecutive U&"" identifiers as separate ones
// Swift divergence: U& prefixes stay separated by whitespace.
@Test func parity_identifiers_detectsConsecutiveUnicodeIdentifiers() throws {
  try assertFormat(
    "U&\"foo\"U&\"bar\"",
    "U& \"foo\" U& \"bar\""
  )
}

// Upstream: test/features/identifiers.ts :: does not supports escaping in U&"" strings with a backslash
// Swift divergence: backslash escaping is accepted even though upstream expects a parse error, and U& prefixes stay separated.
@Test func parity_identifiers_rejectsBackslashEscapingInUnicodeIdentifiers() throws {
  try assertFormat(
    "U&\"foo \\\" JOIN bar\"",
    "U& \"foo \\\" JOIN bar\""
  )
}

// Upstream: test/features/identifiers.ts :: supports [bracket-quoted identifiers]
@Test func parity_identifiers_supportsBracketQuotedIdentifiers() throws {
  try assertFormat(
    "[foo JOIN bar]",
    "[foo JOIN bar]"
  )

  try assertFormat(
    """
    SELECT [where] FROM [update]
    """,
    """
    SELECT
      [where]
    FROM
      [update]
    """
  )
}

// Upstream: test/features/identifiers.ts :: supports escaping close-bracket by doubling it
@Test func parity_identifiers_supportsEscapingClosingBracketByDoubling() throws {
  try assertFormat(
    "[foo ]] JOIN bar]",
    "[foo ]] JOIN bar]"
  )
}

// Upstream: test/features/identifiers.ts :: no space around dot between two [bracket-quoted identifiers]
@Test func parity_identifiers_noSpaceAroundDotBetweenBracketQuotedIdentifiers() throws {
  try assertFormat(
    "SELECT [my table].[col name];",
    """
    SELECT
      [my table].[col name];
    """
  )
}
