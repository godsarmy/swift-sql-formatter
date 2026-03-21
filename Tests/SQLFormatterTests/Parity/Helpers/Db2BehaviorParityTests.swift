import Testing

@testable import SQLFormatter

private func assertDb2Like(
  _ sql: String,
  _ expected: String,
  options: FormatOptions = .default
) throws {
  try assertFormatDialect(sql, dialect: .db2, expected, options: options)
  try assertFormatDialect(sql, dialect: .db2i, expected, options: options)
}

// Upstream: test/behavesLikeDb2Formatter.ts :: formats only -- as a line comment
// Swift divergence: comment line is not indented under FROM.
@Test func parity_db2_formatsOnlyDashDashAsLineComment() throws {
  try assertDb2Like(
    """
      SELECT col FROM
      -- This is a comment
      MyTable;
    """,
    """
      SELECT
        col
      FROM
      -- This is a comment
      MyTable;
      """
  )
}

// Upstream: test/behavesLikeDb2Formatter.ts :: supports strings with G, GX, BX, UX prefixes
// Swift divergence: prefixed string literals are tokenized with a space after prefix.
@Test func parity_db2_supportsPrefixedStringLiterals() throws {
  try assertDb2Like(
    "SELECT G'blah blah', GX'01AC', BX'0101', UX'CCF239' FROM foo",
    """
      SELECT
        G 'blah blah',
        GX '01AC',
        BX '0101',
        UX 'CCF239'
      FROM
        foo
      """
  )
}

// Upstream: test/behavesLikeDb2Formatter.ts :: supports @, #, $ characters anywhere inside identifiers
@Test func parity_db2_supportsSpecialCharactersInIdentifiers() throws {
  try assertDb2Like(
    "SELECT @foo, #bar, $zap, fo@o, ba#2, za$3",
    """
      SELECT
        @foo,
        #bar,
        $zap,
        fo@o,
        ba#2,
        za$3
      """
  )
}

// Upstream: test/behavesLikeDb2Formatter.ts :: supports @, #, $ characters in named parameters
@Test func parity_db2_supportsSpecialCharactersInNamedParameters() throws {
  try assertDb2Like(
    "SELECT :foo@bar, :foo#bar, :foo$bar, :@zip, :#zap, :$zop",
    """
      SELECT
        :foo@bar,
        :foo#bar,
        :foo$bar,
        :@zip,
        :#zap,
        :$zop
      """
  )
}

// Upstream: test/behavesLikeDb2Formatter.ts :: supports WITH isolation level modifiers for UPDATE statement
// Swift divergence: WITH and isolation level are separated on distinct lines.
@Test func parity_db2_supportsUpdateWithIsolationModifier() throws {
  try assertDb2Like(
    "UPDATE foo SET x = 10 WITH CS",
    """
      UPDATE foo
      SET
        x = 10
      WITH
        CS
      """
  )
}

// Upstream: test/behavesLikeDb2Formatter.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: ALTER COLUMN remains on same line; SET is split.
@Test func parity_db2_formatsAlterTableAlterColumn() throws {
  try assertDb2Like(
    """
    ALTER TABLE t ALTER COLUMN foo SET DATA TYPE VARCHAR;
    ALTER TABLE t ALTER COLUMN foo SET NOT NULL;
    """,
    """
      ALTER TABLE t ALTER COLUMN foo
      SET
        DATA TYPE VARCHAR;

      ALTER TABLE t ALTER COLUMN foo
      SET
        NOT NULL;
      """
  )
}
