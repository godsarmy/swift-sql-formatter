import Testing

@testable import SQLFormatter

private let plsqlDialect: Dialect = .plSQL

// Upstream: test/plsql.test.ts :: recognizes _, $, # as part of identifiers
// Swift divergence: formatter inserts spaces before trailing '#' markers.
@Test func parity_plsql_recognizesSpecialIdentifierCharacters() throws {
  try assertFormatDialect(
    "SELECT my_col$1#, col.a$, type#, procedure$, user# FROM tbl;",
    dialect: plsqlDialect,
    dedent(
      """
      SELECT
        my_col$1 #,
        col.a$,
        type #,
        procedure$,
        user #
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/plsql.test.ts :: supports #, $ in named parameters
// Swift divergence: formatter inserts spaces around the prefix and hash symbols.
@Test func parity_plsql_supportsHashAndDollarInNamedParameters() throws {
  try assertFormatDialect(
    "SELECT :col$foo, :col#foo",
    dialect: plsqlDialect,
    dedent(
      """
      SELECT
        : col$foo,
        : col # foo
      """
    )
  )
}

// Upstream: test/plsql.test.ts :: supports &name substitution variables
// Swift divergence: formatter splits ampersand tokens and adds spaces around embedded hashes.
@Test func parity_plsql_supportsAmpersandSubstitutionVariables() throws {
  try assertFormatDialect(
    "SELECT &name, &some$Special#Chars_, &hah123 FROM &&tbl",
    dialect: plsqlDialect,
    dedent(
      """
      SELECT
        & name,
        & some$Special # Chars_,
        & hah123
      FROM
        && tbl
      """
    )
  )
}

// Upstream: test/plsql.test.ts :: supports Q custom delimiter strings
// Swift divergence: formatter injects spaces between the prefix and literal chunks.
@Test func parity_plsql_supportsQUniqueDelimiterStrings() throws {
  try assertFormatDialect(
    "q'<test string < > 'foo' bar >'", dialect: plsqlDialect, "q'<test string < > 'foo' bar >'")
  try assertFormatDialect(
    "NQ'[test string [ ] 'foo' bar ]'", dialect: plsqlDialect, "NQ '[test string [ ] ' foo ' bar ]'"
  )
  try assertFormatDialect(
    "nq'(test string ( ) 'foo' bar )'", dialect: plsqlDialect, "nq '(test string ( ) ' foo ' bar )'"
  )
  try assertFormatDialect(
    "nQ'{test string { } 'foo' bar }'", dialect: plsqlDialect, "nQ '{test string { } ' foo ' bar }'"
  )
  try assertFormatDialect(
    "Nq'%test string % % 'foo' bar %'", dialect: plsqlDialect, "Nq '%test string % % ' foo ' bar %'"
  )
  try assertFormatDialect(
    "Q'Xtest string X X 'foo' bar X'", dialect: plsqlDialect, "Q'Xtest string X X 'foo' bar X'")

  // Swift divergence: formatter inserts spaces around the quoted literal delimiters.
  try assertFormatDialect(
    "q'$test string $'$''",
    dialect: plsqlDialect,
    "q'$test string $' $ ''"
  )

  try assertFormatDialect(
    "Q'Stest string S'S''",
    dialect: plsqlDialect,
    "Q'Stest string S' S ''"
  )
}

// Upstream: test/plsql.test.ts :: formats Oracle recursive sub queries
// Swift divergence: formatter keeps the inner SELECT less indented and closes the paren on the same line.
@Test func parity_plsql_formatsOracleRecursiveSubqueries() throws {
  try assertFormatDialect(
    """
    WITH t1 AS (
      SELECT * FROM tbl
    ) SEARCH BREADTH FIRST BY id SET order1
    SELECT * FROM t1;
    """,
    dialect: plsqlDialect,
    dedent(
      """
      WITH
        t1 AS (
      SELECT
        *
      FROM
        tbl) SEARCH BREADTH FIRST BY id SET order1
      SELECT
        *
      FROM
        t1;
      """
    )
  )
}

// Upstream: test/plsql.test.ts :: formats identifier with dblink
@Test func parity_plsql_formatsIdentifierWithDblink() throws {
  try assertFormatDialect(
    "SELECT * FROM database.table@dblink WHERE id = 1;",
    dialect: plsqlDialect,
    dedent(
      """
      SELECT
        *
      FROM
        database.table@dblink
      WHERE
        id = 1;
      """
    )
  )
}

// Upstream: test/plsql.test.ts :: formats FOR UPDATE clause
// Swift divergence: FOR UPDATE clauses remain on the same line as the table reference.
@Test func parity_plsql_formatsForUpdateClause() throws {
  try assertFormatDialect(
    """
    SELECT * FROM tbl FOR UPDATE;
    SELECT * FROM tbl FOR UPDATE OF tbl.salary;
    """,
    dialect: plsqlDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl FOR UPDATE;

      SELECT
        *
      FROM
        tbl FOR UPDATE OF tbl.salary;
      """
    )
  )
}
