import Testing

@testable import SQLFormatter

// Upstream: test/features/arrayLiterals.ts :: supports ARRAY[] literals
// Swift divergence: formatter keeps ARRAY literals inline with a space between the prefix and brackets.
@Test func parity_arrayLiterals_supportsArrayPrefixLiterals() throws {
  try assertFormat(
    "SELECT ARRAY[1, 2, 3] FROM ARRAY['come-on', 'seriously', 'this', 'is', 'a', 'very', 'very', 'long', 'array'];",
    """
      SELECT
        ARRAY [1, 2, 3]
      FROM
        ARRAY ['come-on', 'seriously', 'this', 'is', 'a', 'very', 'very', 'long', 'array'];
    """
  )
}

// Upstream: test/features/arrayLiterals.ts :: dataTypeCase option does NOT affect ARRAY[] literal case
// Swift divergence: formatter inserts a space between ARRAY literals and their brackets even when casing is preserved.
@Test func parity_arrayLiterals_dataTypeCaseNotAffectingArrayLiteral() throws {
  try assertFormat(
    "SELECT ArrAy[1, 2]",
    """
      SELECT
        ArrAy [1, 2]
    """,
    options: FormatOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/features/arrayLiterals.ts :: keywordCase option affects ARRAY[] literal case
// Swift divergence: the keywordCase option does not normalize the ARRAY prefix, so the original casing remains.
@Test func parity_arrayLiterals_keywordCaseAffectsArrayLiteral() throws {
  try assertFormat(
    "SELECT ArrAy[1, 2]",
    """
      SELECT
        ArrAy [1, 2]
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/features/arrayLiterals.ts :: dataTypeCase option affects ARRAY type case
// Swift divergence: dataTypeCase uppercasing is ignored for the ARRAY type inside parentheses.
@Test func parity_arrayLiterals_dataTypeCaseAffectsArrayType() throws {
  try assertFormat(
    "CREATE TABLE foo ( items ArrAy )",
    """
      CREATE TABLE foo( items ArrAy)
    """,
    options: FormatOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/features/arrayLiterals.ts :: supports array literals
// Swift divergence: bracket literals keep their contents inline rather than expanding to multiple lines.
@Test func parity_arrayLiterals_supportsBracketLiterals() throws {
  try assertFormat(
    "SELECT [1, 2, 3] FROM ['come-on', 'seriously', 'this', 'is', 'a', 'very', 'very', 'long', 'array'];",
    """
      SELECT
        [1, 2, 3]
      FROM
        ['come-on', 'seriously', 'this', 'is', 'a', 'very', 'very', 'long', 'array'];
    """
  )
}
