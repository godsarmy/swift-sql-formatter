import Testing

@testable import SQLFormatter

private let hiveDialect: Dialect = .hive

// Upstream: test/hive.test.ts :: recognizes ${hivevar:name} substitution variables
// Swift divergence: substitution variables are emitted without escaping before the dollar sign.
@Test func parity_hiveDialect_formatsHivevarSubstitutionVariables() throws {
  try assertFormatDialect(
    #"SELECT ${var1}, ${ var 2 } FROM ${hivevar:table_name} WHERE name = '${hivevar:name}';"#,
    dialect: hiveDialect,
    dedent(
      """
      SELECT
        ${var1},
        ${ var 2 }
      FROM
        ${hivevar:table_name}
      WHERE
        name = '${hivevar:name}';
      """
    )
  )
}

// Upstream: test/hive.test.ts :: supports SORT BY, CLUSTER BY, DISTRIBUTE BY
// Swift divergence: DISTRIBUTE/CLUSTER/SORT BY clauses stay attached to the prior SELECT line.
@Test func parity_hiveDialect_formatsSortClusterAndDistributeBy() throws {
  try assertFormatDialect(
    "SELECT value, count DISTRIBUTE BY count CLUSTER BY value SORT BY value, count;",
    dialect: hiveDialect,
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

// Upstream: test/hive.test.ts :: formats INSERT INTO TABLE
// Swift divergence: INSERT INTO TABLE stays on one line and VALUES formatting breaks each element.
@Test func parity_hiveDialect_formatsInsertIntoTable() throws {
  try assertFormatDialect(
    "INSERT INTO TABLE Customers VALUES (12,-123.4, 'Skagen 2111','Stv');",
    dialect: hiveDialect,
    dedent(
      """
      INSERT INTO TABLE Customers
      VALUES
        (12,
        - 123.4,
        'Skagen 2111',
        'Stv');
      """
    )
  )
}
