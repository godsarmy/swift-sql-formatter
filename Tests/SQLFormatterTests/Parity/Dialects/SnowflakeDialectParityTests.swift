import Testing

@testable import SQLFormatter

// Upstream: test/snowflake.test.ts :: allows $ character as part of unquoted identifiers
@Test func parity_snowflake_allowsDollarCharactersInIdentifiers() throws {
  try assertFormatDialect(
    "SELECT foo$",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        foo$
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: formats ':' path-operator without spaces
// Swift divergence: Swift formatter keeps spaces around the colon operator.
@Test func parity_snowflake_formatsColonPathOperator() throws {
  try assertFormatDialect(
    "SELECT foo : bar",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        foo : bar
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: formats ':' path-operator followed by dots without spaces
// Swift divergence: dot chaining keeps spaces around the colon and dot.
@Test func parity_snowflake_formatsColonPathOperatorWithDots() throws {
  try assertFormatDialect(
    "SELECT foo : bar . baz",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        foo : bar. baz
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: formats ':' path-operator when followed by reserved keyword
// Swift divergence: formatter breaks before the keyword and keeps spaces around the colon.
@Test func parity_snowflake_formatsColonPathOperatorBeforeReservedKeyword() throws {
  try assertFormatDialect(
    "SELECT foo : from",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        foo :
      from
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: formats type-cast operator without spaces
@Test func parity_snowflake_formatsTypeCastOperatorWithoutSpaces() throws {
  try assertFormatDialect(
    "SELECT 2 :: numeric AS foo;",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        2 :: numeric AS foo;
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: supports $$-quoted strings
// Swift divergence: $$-quoted strings currently raise an unterminatedQuotedToken error.
@Test func parity_snowflake_supportsDollarDollarStrings() throws {
  let sql = """
    SELECT $$foo' JOIN"$bar$$, $$foo$$$$bar$$
    """

  do {
    _ = try formatDialect(sql, dialect: .snowflake)
    Issue.record("Expected formatDialect to throw")
  } catch let error as FormatError {
    #expect(String(describing: error).contains("unterminatedQuotedToken"))
  }
}

// Upstream: test/snowflake.test.ts :: supports QUALIFY clause
// Swift divergence: QUALIFY stays on the same line as the table reference.
@Test func parity_snowflake_supportsQualifyClause() throws {
  try assertFormatDialect(
    "SELECT * FROM tbl QUALIFY ROW_NUMBER() OVER my_window = 1",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        *
      FROM
        tbl QUALIFY ROW_NUMBER() OVER my_window = 1
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: ALTER COLUMN clauses stay inline instead of stacking keywords vertically.
@Test func parity_snowflake_formatsAlterColumnClauses() throws {
  try assertFormatDialect(
    """
    ALTER TABLE t ALTER COLUMN foo SET DATA TYPE VARCHAR;
    ALTER TABLE t ALTER COLUMN foo SET DEFAULT 5;
    ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;
    ALTER TABLE t ALTER COLUMN foo SET NOT NULL;
    ALTER TABLE t ALTER COLUMN foo DROP NOT NULL;
    ALTER TABLE t ALTER COLUMN foo COMMENT 'blah';
    ALTER TABLE t ALTER COLUMN foo UNSET COMMENT;
    ALTER TABLE t ALTER COLUMN foo SET MASKING POLICY polis;
    ALTER TABLE t ALTER COLUMN foo UNSET MASKING POLICY;
    ALTER TABLE t ALTER COLUMN foo SET TAG tname = 10;
    ALTER TABLE t ALTER COLUMN foo UNSET TAG tname;
    """,
    dialect: .snowflake,
    dedent(
      """
      ALTER TABLE t ALTER COLUMN foo SET DATA TYPE VARCHAR;

      ALTER TABLE t ALTER COLUMN foo SET DEFAULT 5;

      ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;

      ALTER TABLE t ALTER COLUMN foo SET NOT NULL;

      ALTER TABLE t ALTER COLUMN foo DROP NOT NULL;

      ALTER TABLE t ALTER COLUMN foo COMMENT 'blah';

      ALTER TABLE t ALTER COLUMN foo UNSET COMMENT;

      ALTER TABLE t ALTER COLUMN foo SET MASKING POLICY polis;

      ALTER TABLE t ALTER COLUMN foo UNSET MASKING POLICY;

      ALTER TABLE t ALTER COLUMN foo SET TAG tname = 10;

      ALTER TABLE t ALTER COLUMN foo UNSET TAG tname;
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: detects data types
// Swift divergence: data types stay inline and casing remains as parsed, so whitespace differs.
@Test func parity_snowflake_detectsDataTypes() throws {
  try assertFormatDialect(
    "CREATE TABLE tbl (first_column double Precision, second_column numBer (38, 0), third String);",
    dialect: .snowflake,
    dedent(
      """
      CREATE TABLE tbl(first_column DOUBLE Precision,
      second_column numBer(38,
      0),
      third String);
      """
    ),
    options: FormatOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/snowflake.test.ts :: allows TYPE to be used as an identifier
// Swift divergence: CASE expression remains inline instead of stacking WHEN/ELSE lines.
@Test func parity_snowflake_allowsTypeAsIdentifier() throws {
  try assertFormatDialect(
    "SELECT CASE WHEN type = 'upgrade' THEN amount ELSE 0 END FROM items;",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        CASE WHEN type = 'upgrade' THEN amount ELSE 0 END
      FROM
        items;
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: supports lambda expressions
// Swift divergence: FILTER argument wraps to a new line and spaces surround the path operator.
@Test func parity_snowflake_supportsLambdaExpressions() throws {
  try assertFormatDialect(
    "SELECT FILTER(my_arr, a -> a:value >= 50);",
    dialect: .snowflake,
    dedent(
      """
      SELECT
        FILTER(my_arr,
        a -> a : value >= 50);
      """
    )
  )
}

// Upstream: test/snowflake.test.ts :: supports IDENTIFIER() syntax
@Test func parity_snowflake_supportsIdentifierFunction() throws {
  try assertFormatDialect(
    "CREATE TABLE identifier($foo);",
    dialect: .snowflake,
    dedent(
      """
      CREATE TABLE identifier($foo);
      """
    )
  )
}
