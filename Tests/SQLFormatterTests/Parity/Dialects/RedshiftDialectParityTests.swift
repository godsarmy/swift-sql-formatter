import Testing

@testable import SQLFormatter

// Upstream: test/redshift.test.ts :: formats type-cast operator without spaces
// Swift divergence: formatter inserts spaces around the type-cast operator.
@Test func parity_redshift_formatsTypeCastOperatorWithoutSpaces() throws {
  try assertFormatDialect(
    "SELECT 2 :: numeric AS foo;",
    dialect: .redshift,
    dedent(
      """
      SELECT
        2 :: numeric AS foo;
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: formats LIMIT
@Test func parity_redshift_formatsLimit() throws {
  try assertFormatDialect(
    "SELECT col1 FROM tbl ORDER BY col2 DESC LIMIT 10;",
    dialect: .redshift,
    dedent(
      """
      SELECT
        col1
      FROM
        tbl
      ORDER BY
        col2 DESC
      LIMIT
        10;
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: formats only -- as a line comment
// Swift divergence: line comment remains flush-left without indenting the following table name.
@Test func parity_redshift_formatsSingleLineComments() throws {
  try assertFormatDialect(
    """
      SELECT col FROM
      -- This is a comment
      MyTable;
    """,
    dialect: .redshift,
    dedent(
      """
      SELECT
        col
      FROM
      -- This is a comment
      MyTable;
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: formats temp table name starting with #
// Swift divergence: formatter inserts a space between # and the temporary table name identifier.
@Test func parity_redshift_formatsTempTableNames() throws {
  try assertFormatDialect(
    "CREATE TABLE #tablename AS tbl;",
    dialect: .redshift,
    dedent(
      """
      CREATE TABLE # tablename AS tbl;
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: formats DISTKEY and SORTKEY after CREATE TABLE
// Swift divergence: column definitions stay inline and key clauses remain on the same line as the table definition.
@Test func parity_redshift_formatsDistAndSortKeys() throws {
  try assertFormatDialect(
    "CREATE TABLE items (a INT PRIMARY KEY, b TEXT, c INT NOT NULL, d INT NOT NULL, e INT NOT NULL) DISTKEY(created_at) SORTKEY(created_at);",
    dialect: .redshift,
    dedent(
      """
      CREATE TABLE items(a INT PRIMARY KEY,
      b TEXT,
      c INT NOT NULL,
      d INT NOT NULL,
      e INT NOT NULL) DISTKEY(created_at) SORTKEY(created_at);
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: formats COPY
@Test func parity_redshift_formatsCopy() throws {
  try assertFormatDialect(
    """
      COPY schema.table
      FROM 's3://bucket/file.csv'
      IAM_ROLE 'arn:aws:iam::123456789:role/rolename'
      FORMAT AS CSV DELIMITER ',' QUOTE '"'
      REGION AS 'us-east-1'
    """,
    dialect: .redshift,
    dedent(
      """
      COPY schema.table
      FROM
        's3://bucket/file.csv' IAM_ROLE 'arn:aws:iam::123456789:role/rolename' FORMAT AS CSV DELIMITER ',' QUOTE '"' REGION AS 'us-east-1'
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: ALTER COLUMN clauses remain on a single line instead of being stacked.
@Test func parity_redshift_formatsAlterColumnClauses() throws {
  try assertFormatDialect(
    """
      ALTER TABLE t ALTER COLUMN foo TYPE VARCHAR;
      ALTER TABLE t ALTER COLUMN foo ENCODE my_encoding;
    """,
    dialect: .redshift,
    dedent(
      """
      ALTER TABLE t ALTER COLUMN foo TYPE VARCHAR;

      ALTER TABLE t ALTER COLUMN foo ENCODE my_encoding;
      """
    )
  )
}

// Upstream: test/redshift.test.ts :: supports QUALIFY clause
// Swift divergence: QUALIFY clause stays on the same line as the table reference.
@Test func parity_redshift_supportsQualifyClause() throws {
  try assertFormatDialect(
    "SELECT * FROM tbl QUALIFY ROW_NUMBER() OVER my_window = 1",
    dialect: .redshift,
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
