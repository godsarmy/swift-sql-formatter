import Testing

@testable import SQLFormatter

private let transactsqlDialect: Dialect = .transactSQL

// Upstream: test/transactsql.test.ts :: recognizes @, $, # as part of identifiers
@Test func parity_transactsql_recognizesSpecialIdentifierCharacters() throws {
  try assertFormatDialect(
    "SELECT from@bar, where#to, join$me FROM tbl;",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        from@bar,
        where#to,
        join$me
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: allows @ and # at the start of identifiers
@Test func parity_transactsql_allowsSpecialPrefixIdentifiers() throws {
  try assertFormatDialect(
    "SELECT @bar, #baz, @@some, ##flam FROM tbl;",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        @bar,
        #baz,
        @@some,
        ##flam
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats scope resolution operator without spaces
// Swift divergence: scope resolution spacing is preserved around `::` and parentheses stay attached.
@Test func parity_transactsql_formatsScopeResolutionOperator() throws {
  try assertFormatDialect(
    "SELECT hierarchyid :: GetRoot();",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        hierarchyid :: GetRoot();
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats .. shorthand for database.schema.table
@Test func parity_transactsql_formatsDoubleDotSyntax() throws {
  try assertFormatDialect(
    "SELECT x FROM db..tbl",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        x
      FROM
        db..tbl
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: ALTER keywords break into their own lines before the table and column names.
@Test func parity_transactsql_formatsAlterTableAlterColumn() throws {
  try assertFormatDialect(
    "ALTER TABLE t ALTER COLUMN foo INT NOT NULL DEFAULT 5;",
    dialect: transactsqlDialect,
    dedent(
      """
      ALTER
        TABLE t
      ALTER
        COLUMN foo INT NOT NULL DEFAULT 5;
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats GO CREATE OR ALTER PROCEDURE
@Test func parity_transactsql_formatsGoCreateOrAlterProcedure() throws {
  try assertFormatDialect(
    "GO CREATE OR ALTER PROCEDURE p",
    dialect: transactsqlDialect,
    dedent(
      """
      GO
      CREATE OR ALTER PROCEDURE p
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats SELECT ... INTO clause
// Swift divergence: INTO clause stays on the same line as the selected column.
@Test func parity_transactsql_formatsSelectInto() throws {
  try assertFormatDialect(
    "SELECT col INTO #temp FROM tbl",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        col INTO #temp
      FROM
        tbl
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats SELECT ... OPTION ()
// Swift divergence: OPTION clause is rendered inline with the column and parentheses.
@Test func parity_transactsql_formatsOptionClause() throws {
  try assertFormatDialect(
    "SELECT col OPTION (MAXRECURSION 5)",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        col OPTION(MAXRECURSION 5)
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats SELECT ... FOR BROWSE
// Swift divergence: FOR BROWSE remains inline with the SELECT target.
@Test func parity_transactsql_formatsForBrowse() throws {
  try assertFormatDialect(
    "SELECT col FOR BROWSE",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        col FOR BROWSE
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats SELECT ... FOR XML
// Swift divergence: FOR XML clause stays inline with the SELECT target and PATH remains adjacent.
@Test func parity_transactsql_formatsForXml() throws {
  try assertFormatDialect(
    "SELECT col FOR XML PATH('Employee'), ROOT('Employees')",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        col FOR XML PATH('Employee'),
        ROOT('Employees')
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats SELECT ... FOR JSON
// Swift divergence: FOR JSON clause stays inline with the SELECT target.
@Test func parity_transactsql_formatsForJson() throws {
  try assertFormatDialect(
    "SELECT col FOR JSON PATH, WITHOUT_ARRAY_WRAPPER",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        col FOR JSON PATH,
        WITHOUT_ARRAY_WRAPPER
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats goto labels
@Test func parity_transactsql_formatsGotoLabels() throws {
  try assertFormatDialect(
    "InfiniLoop:\n      SELECT 'Hello.';\n      GOTO InfiniLoop;",
    dialect: transactsqlDialect,
    dedent(
      """
      InfiniLoop:
      SELECT
        'Hello.';

      GOTO InfiniLoop;
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: does not detect CHAR() as function
// Swift divergence: TABLE identifier uppercases when `functionCase` forces keyword casing.
@Test func parity_transactsql_isNotChocolateFunction() throws {
  try assertFormatDialect(
    "CREATE TABLE foo (name char(65));",
    dialect: transactsqlDialect,
    dedent(
      """
      CREATE TABLE FOO(name char(65));
      """
    ),
    options: FormatOptions(dialect: .transactSQL, functionCase: .upper)
  )
}

// Upstream: test/transactsql.test.ts :: supports special $ACTION keyword
// Swift divergence: `AS` and the alias break onto their own lines.
@Test func parity_transactsql_supportsActionKeyword() throws {
  try assertFormatDialect(
    "MERGE INTO tbl OUTPUT $action AS act;",
    dialect: transactsqlDialect,
    dedent(
      """
      MERGE INTO tbl OUTPUT $action
      AS
        act;
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: formats GO on a separate line
// Swift divergence: CREATE VIEW splits `AS` and the following CREATE INDEX across lines.
@Test func parity_transactsql_formatsGoSeparator() throws {
  try assertFormatDialect(
    "CREATE VIEW foo AS SELECT * FROM tbl GO CREATE INDEX bar",
    dialect: transactsqlDialect,
    dedent(
      """
      CREATE VIEW foo
      AS
      SELECT
        *
      FROM
        tbl

      GO
      CREATE
        INDEX bar
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: supports ALTER PROCEDURE
// Swift divergence: `AS` is rendered on its own line.
@Test func parity_transactsql_supportsAlterProcedure() throws {
  try assertFormatDialect(
    "GO ALTER PROCEDURE foo AS SELECT 1; GO",
    dialect: transactsqlDialect,
    dedent(
      """
      GO
      ALTER PROCEDURE foo
      AS
      SELECT
        1;

      GO
      """
    )
  )
}

// Upstream: test/transactsql.test.ts :: does not recognize ODBC keywords as reserved keywords
@Test func parity_transactsql_preservesOdbcIdentifiers() throws {
  try assertFormatDialect(
    "SELECT Value, Zone",
    dialect: transactsqlDialect,
    dedent(
      """
      SELECT
        Value,
        Zone
      """
    ),
    options: FormatOptions(dialect: .transactSQL, keywordCase: .upper)
  )
}

// Upstream: test/transactsql.test.ts :: allows the use of the ODBC date format
// Swift divergence: AS and SELECT nesting differ and the `{d ...}` literal keeps extra spaces inside.
@Test func parity_transactsql_supportsOdbcDateFormat() throws {
  try assertFormatDialect(
    "WITH [sales_query] AS (SELECT [customerId] FROM [segments].dbo.[sales] WHERE [salesdate] > {d'2024-01-01'})",
    dialect: transactsqlDialect,
    dedent(
      """
      WITH
        [sales_query]
      AS
        (
      SELECT
        [customerId]
      FROM
        [segments].dbo.[sales]
      WHERE
        [salesdate] > {d '2024-01-01' })
      """
    )
  )
}
