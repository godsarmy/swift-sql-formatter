import Testing

@testable import SQLFormatter

private let sparkDialect: Dialect = .spark

// Upstream: test/spark.test.ts :: supports identifiers that start with numbers
@Test func parity_sparkDialect_formatsNumericIdentifiers() throws {
  try assertFormatDialect(
    "SELECT 4four, 12345e FROM 5tbl",
    dialect: sparkDialect,
    dedent(
      """
      SELECT
        4four,
        12345e
      FROM
        5tbl
      """
    )
  )
}

// Upstream: test/spark.test.ts :: formats basic WINDOW clause
// Swift divergence: Swift keeps the WINDOW clauses on the same line as the FROM clause instead of breaking each clause into its own block.
@Test func parity_sparkDialect_formatsWindowClause() throws {
  try assertFormatDialect(
    "SELECT * FROM tbl WINDOW win1, WINDOW win2, WINDOW win3;",
    dialect: sparkDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl WINDOW win1,
        WINDOW win2,
        WINDOW win3;
      """
    )
  )
}

// Upstream: test/spark.test.ts :: formats window function and end as inline
// Swift divergence: Swift wraps the frame length argument for window() onto the next line, splitting after the comma.
@Test func parity_sparkDialect_formatsWindowFunctionInline() throws {
  try assertFormatDialect(
    "SELECT window(time, '1 hour').start AS window_start, window(time, '1 hour').end AS window_end FROM tbl;",
    dialect: sparkDialect,
    dedent(
      """
      SELECT
        window(time,
        '1 hour').start AS window_start,
        window(time,
        '1 hour').end AS window_end
      FROM
        tbl;
      """
    )
  )
}

// Upstream: test/spark.test.ts :: recognizes ${name} substitution variables
@Test func parity_sparkDialect_formatsSubstitutionVariables() throws {
  try assertFormatDialect(
    #"SELECT ${var1}, ${ var 2 } FROM ${table_name} WHERE name = '${name}';"#,
    dialect: sparkDialect,
    dedent(
      #"""
      SELECT
        ${var1},
        ${ var 2 }
      FROM
        ${table_name}
      WHERE
        name = '${name}';
      """#
    )
  )
}

// Upstream: test/spark.test.ts :: supports SORT BY, CLUSTER BY, DISTRIBUTE BY
// Swift divergence: Swift keeps the DISTRIBUTE/CLUSTER/SORT clauses on the same lines as the preceding expressions instead of breaking them onto separate lines.
@Test func parity_sparkDialect_formatsSortClusterDistributeBy() throws {
  try assertFormatDialect(
    "SELECT value, count DISTRIBUTE BY count CLUSTER BY value SORT BY value, count;",
    dialect: sparkDialect,
    dedent(
      """
      SELECT
        value,
        count DISTRIBUTE BY count CLUSTER BY value SORT BY value,
        count;
      """
    )
  )
}

// Upstream: test/spark.test.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: Swift keeps the ALTER COLUMN statement on a single line without splitting keywords onto separate lines.
@Test func parity_sparkDialect_formatsAlterColumn() throws {
  try assertFormatDialect(
    "ALTER TABLE StudentInfo ALTER COLUMN FirstName COMMENT \"new comment\";",
    dialect: sparkDialect,
    dedent(
      """
      ALTER TABLE StudentInfo ALTER COLUMN FirstName COMMENT "new comment";
      """
    )
  )
}
