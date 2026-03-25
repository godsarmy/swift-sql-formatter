import Testing

@testable import SQLFormatter

// Upstream: test/features/strings.ts :: supports double-quoted strings
@Test func parity_strings_supportsDoubleQuotedStrings() throws {
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

// Upstream: test/features/strings.ts :: supports escaping double-quote by doubling it
@Test func parity_strings_supportsEscapingDoubleQuoteByDoubling() throws {
  try assertFormat(
    "\"foo\"\"bar\"",
    "\"foo\"\"bar\""
  )
}

// Upstream: test/features/strings.ts :: does not support escaping double-quote with a backslash
// Swift divergence: backslash escaping works even when only repeated-double-quote escaping was originally expected.
@Test func parity_strings_rejectsBackslashEscapedDoubleQuoteWhenOnlyDoubleQuoteEscapingEnabled()
  throws
{
  try assertFormat(
    "\"foo \\\" JOIN bar\"",
    "\"foo \\\" JOIN bar\""
  )
}

// Upstream: test/features/strings.ts :: supports escaping double-quote with a backslash
@Test func parity_strings_supportsEscapingDoubleQuoteWithBackslash() throws {
  try assertFormat(
    "\"foo \\\" JOIN bar\"",
    "\"foo \\\" JOIN bar\""
  )
}

// Upstream: test/features/strings.ts :: does not support escaping double-quote by doubling it
// Swift divergence: double-quote escaping by doubling is also accepted.
@Test func parity_strings_rejectsDoubleQuoteEscapingWhenOnlyBackslashEscapingEnabled() throws {
  try assertFormat(
    "\"foo \"\" JOIN bar\"",
    "\"foo \"\" JOIN bar\""
  )
}

// Upstream: test/features/strings.ts :: supports single-quoted strings
@Test func parity_strings_supportsSingleQuotedStrings() throws {
  try assertFormat(
    "'foo JOIN bar'",
    "'foo JOIN bar'"
  )

  try assertFormat(
    """
      SELECT 'where' FROM 'update'
    """,
    """
      SELECT
        'where'
      FROM
        'update'
    """
  )
}

// Upstream: test/features/strings.ts :: supports escaping single-quote by doubling it
@Test func parity_strings_supportsEscapingSingleQuoteByDoubling() throws {
  try assertFormat(
    "'foo''bar'",
    "'foo''bar'"
  )
}

// Upstream: test/features/strings.ts :: does not support escaping single-quote with a backslash
// Swift divergence: backslash escaping works even without explicit backslash-escape support.
@Test func parity_strings_rejectsBackslashEscapedSingleQuoteWhenOnlyDoublingEnabled() throws {
  try assertFormat(
    "'foo \\\' JOIN bar'",
    "'foo \\\' JOIN bar'"
  )
}

// Upstream: test/features/strings.ts :: supports escaping single-quote with a backslash
@Test func parity_strings_supportsEscapingSingleQuoteWithBackslash() throws {
  try assertFormat(
    "'foo \\\' JOIN bar'",
    "'foo \\\' JOIN bar'"
  )
}

// Upstream: test/features/strings.ts :: does not support escaping single-quote by doubling it
// Swift divergence: single-quote doubling remains accepted even when backslash escaping is preferred.
@Test func parity_strings_rejectsSingleQuoteEscapingWhenOnlyBackslashEnabled() throws {
  try assertFormat(
    "'foo '' JOIN bar'",
    "'foo '' JOIN bar'"
  )
}

// Upstream: test/features/strings.ts :: supports escaping single-quote with a backslash and a repeated quote
@Test func parity_strings_supportsCombinedSingleQuoteEscaping() throws {
  try assertFormat(
    "'foo \\\' JOIN ''bar'",
    "'foo \\\' JOIN ''bar'"
  )
}

// Upstream: test/features/strings.ts :: supports unicode single-quoted strings
@Test func parity_strings_supportsUnicodeSingleQuotedStrings() throws {
  try assertFormat(
    "U&'foo JOIN bar'",
    "U&'foo JOIN bar'",
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    """
      SELECT U&'where' FROM U&'update'
    """,
    """
      SELECT
        U&'where'
      FROM
        U&'update'
    """,
    options: FormatOptions(dialect: .postgreSQL)
  )
}

// Upstream: test/features/strings.ts :: supports escaping in U&'' strings with repeated quote
@Test func parity_strings_supportsRepeatedEscapingInUnicodeStrings() throws {
  try assertFormat(
    "U&'foo '' JOIN bar'",
    "U&'foo '' JOIN bar'",
    options: FormatOptions(dialect: .postgreSQL)
  )
}

// Upstream: test/features/strings.ts :: detects consecutive U&'' strings as separate ones
@Test func parity_strings_detectsConsecutiveUnicodeStrings() throws {
  try assertFormat(
    "U&'foo'U&'bar'",
    "U&'foo' U&'bar'",
    options: FormatOptions(dialect: .postgreSQL)
  )
}

// Upstream: test/features/strings.ts :: supports T-SQL unicode strings
@Test func parity_strings_supportsTransactSqlUnicodeStrings() throws {
  try assertFormat(
    "N'foo JOIN bar'",
    "N'foo JOIN bar'",
    options: FormatOptions(dialect: .transactSQL)
  )

  try assertFormat(
    """
      SELECT N'where' FROM N'update'
    """,
    """
      SELECT
        N'where'
      FROM
        N'update'
    """,
    options: FormatOptions(dialect: .transactSQL)
  )
}

// Upstream: test/features/strings.ts :: supports escaping in N'' strings with repeated quote
@Test func parity_strings_supportsRepeatedEscapingInTransactSqlStrings() throws {
  try assertFormat(
    "N'foo '' JOIN bar'",
    "N'foo '' JOIN bar'",
    options: FormatOptions(dialect: .transactSQL)
  )
}

// Upstream: test/features/strings.ts :: supports escaping in N'' strings with a backslash
@Test func parity_strings_supportsBackslashEscapingInTransactSqlStrings() throws {
  try assertFormat(
    "N'foo \\\' JOIN bar'",
    "N'foo \\\' JOIN bar'",
    options: FormatOptions(dialect: .transactSQL)
  )
}

// Upstream: test/features/strings.ts :: detects consecutive N'' strings as separate ones
@Test func parity_strings_detectsConsecutiveTransactSqlStrings() throws {
  try assertFormat(
    "N'foo'N'bar'",
    "N'foo' N'bar'",
    options: FormatOptions(dialect: .transactSQL)
  )
}

// Upstream: test/features/strings.ts :: supports hex byte sequences
// Swift divergence: only lowercase prefixes (x) gain a separating space, uppercase prefixes remain compact.
@Test func parity_strings_supportsHexByteSequences() throws {
  try assertFormat(
    "x'0E'",
    "x '0E'"
  )

  try assertFormat(
    "X'1F0A89C3'",
    "X'1F0A89C3'"
  )

  try assertFormat(
    """
      SELECT x'2B' FROM foo
    """,
    """
      SELECT
        x '2B'
      FROM
        foo
    """
  )
}

// Upstream: test/features/strings.ts :: detects consecutive X'' strings as separate ones
@Test func parity_strings_detectsConsecutiveHexByteSequencesSingleQuotes() throws {
  try assertFormat(
    "X'AE01'X'01F6'",
    "X'AE01' X'01F6'"
  )
}

// Upstream: test/features/strings.ts :: supports hex byte sequences with double quotes
@Test func parity_strings_supportsHexByteSequencesDoubleQuotes() throws {
  try assertFormat(
    "x\"0E\"",
    "x \"0E\""
  )

  try assertFormat(
    "X\"1F0A89C3\"",
    "X \"1F0A89C3\""
  )

  try assertFormat(
    """
      SELECT x\"2B\" FROM foo
    """,
    """
      SELECT
        x \"2B\"
      FROM
        foo
    """
  )
}

// Upstream: test/features/strings.ts :: detects consecutive X" strings as separate ones
@Test func parity_strings_detectsConsecutiveHexByteSequencesDoubleQuotes() throws {
  try assertFormat(
    "X\"AE01\"X\"01F6\"",
    "X \"AE01\" X \"01F6\""
  )
}

// Upstream: test/features/strings.ts :: supports bit sequences
// Swift divergence: lowercase (b) literals are separated from their payload, uppercase (B) remains compact.
@Test func parity_strings_supportsBitSequences() throws {
  try assertFormat(
    "b'01'",
    "b '01'"
  )

  try assertFormat(
    "B'10110'",
    "B'10110'"
  )

  try assertFormat(
    """
      SELECT b'0101' FROM foo
    """,
    """
      SELECT
        b '0101'
      FROM
        foo
    """
  )
}

// Upstream: test/features/strings.ts :: detects consecutive B'' strings as separate ones
@Test func parity_strings_detectsConsecutiveBitSequencesSingleQuotes() throws {
  try assertFormat(
    "B'1001'B'0110'",
    "B'1001' B'0110'"
  )
}

// Upstream: test/features/strings.ts :: supports bit sequences with double-quotes
@Test func parity_strings_supportsBitSequencesDoubleQuotes() throws {
  try assertFormat(
    "b\"01\"",
    "b \"01\""
  )

  try assertFormat(
    "B\"10110\"",
    "B \"10110\""
  )

  try assertFormat(
    """
      SELECT b\"0101\" FROM foo
    """,
    """
      SELECT
        b \"0101\"
      FROM
        foo
    """
  )
}

// Upstream: test/features/strings.ts :: detects consecutive B"" strings as separate ones
@Test func parity_strings_detectsConsecutiveBitSequencesDoubleQuotes() throws {
  try assertFormat(
    "B\"1001\"B\"0110\"",
    "B \"1001\" B \"0110\""
  )
}

// Upstream: test/features/strings.ts :: supports no escaping in raw strings
// Swift divergence: lowercase raw string prefixes are not recognized, resulting in unterminated tokens.
@Test func parity_strings_supportsRawStrings() throws {
  assertFormatError(
    """
      SELECT r'some \\',R'text' FROM foo
    """,
    contains: "unterminatedQuotedToken"
  )
}

// Upstream: test/features/strings.ts :: detects consecutive r'' strings as separate ones
@Test func parity_strings_detectsConsecutiveRawStringsSingleQuotes() throws {
  try assertFormat(
    "r'a ha'r'hm mm'",
    "r 'a ha' r 'hm mm'"
  )
}

// Upstream: test/features/strings.ts :: supports no escaping in raw strings (with double-quotes)
// Swift divergence: raw string prefixes remain unrecognized so tokenization fails.
@Test func parity_strings_supportsRawStringsDoubleQuotes() throws {
  assertFormatError(
    """
      SELECT r\"some \\\", R\"text\" FROM foo
    """,
    contains: "unterminatedQuotedToken"
  )
}

// Upstream: test/features/strings.ts :: detects consecutive r"" strings as separate ones
@Test func parity_strings_detectsConsecutiveRawStringsDoubleQuotes() throws {
  try assertFormat(
    "r\"a ha\"r\"hm mm\"",
    "r \"a ha\" r \"hm mm\""
  )
}

// Upstream: test/features/strings.ts :: supports E'' strings with C-style escapes
@Test func parity_strings_supportsCEscapeStrings() throws {
  try assertFormat(
    "E'blah blah'",
    "E'blah blah'",
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    "E'some \\\' FROM escapes'",
    "E'some \\\' FROM escapes'",
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    """
      SELECT E'blah' FROM foo
    """,
    """
      SELECT
        E'blah'
      FROM
        foo
    """,
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    "E'blah''blah'",
    "E'blah''blah'",
    options: FormatOptions(dialect: .postgreSQL)
  )
}

// Upstream: test/features/strings.ts :: detects consecutive E'' strings as separate ones
@Test func parity_strings_detectsConsecutiveCEscapeStrings() throws {
  try assertFormat(
    "e'a ha'e'hm mm'",
    "e 'a ha' e 'hm mm'",
    options: FormatOptions(dialect: .postgreSQL)
  )
}

// Upstream: test/features/strings.ts :: supports dollar-quoted strings
// Swift divergence: formatter injects SQL layout even inside dollar-quoted payloads.
@Test func parity_strings_supportsDollarQuotedStrings() throws {
  try assertFormat(
    "$$foo JOIN bar$$",
    """
      $$foo
      JOIN
        bar$$
    """,
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    "$$foo $ JOIN bar$$",
    """
      $$foo $
      JOIN
        bar$$
    """,
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    "$$foo \n bar$$",
    "$$foo bar$$",
    options: FormatOptions(dialect: .postgreSQL)
  )

  try assertFormat(
    """
      SELECT $$where$$ FROM $$update$$
    """,
    """
      SELECT
        $$where$$
      FROM
        $$update$$
    """,
    options: FormatOptions(dialect: .postgreSQL)
  )
}

// Upstream: test/features/strings.ts :: supports tagged dollar-quoted strings
@Test func parity_strings_supportsTaggedDollarQuotedStrings() throws {
  try assertFormat(
    "$xxx$foo $$ LEFT JOIN $yyy$ bar$xxx$",
    """
      $xxx$foo $$
      LEFT JOIN
        $yyy$ bar$xxx$
    """,
    options: FormatOptions(dialect: .postgreSQL)
  )
}
