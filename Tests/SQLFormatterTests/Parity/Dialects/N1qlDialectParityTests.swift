import Testing

@testable import SQLFormatter

private let n1qlDialect: Dialect = .n1ql

// Upstream: test/n1ql.test.ts :: formats INSERT with {} object literal
// Swift divergence: keeps INSERT/VALUES and object literal much more compact.
@Test func parity_n1ql_formatsInsertWithObjectLiteral() throws {
  try assertFormatDialect(
    "INSERT INTO heroes (KEY, VALUE) VALUES ('123', {'id':1,'type':'Tarzan'});",
    dialect: n1qlDialect,
    dedent(
      """
      INSERT INTO heroes(KEY,
      VALUE) VALUES('123',
      { 'id' : 1,
      'type' : 'Tarzan' });
      """
    )
  )
}

// Upstream: test/n1ql.test.ts :: formats INSERT with large object and array literals
// Swift divergence: keeps INSERT/VALUES and object/array literal compact with different spacing.
@Test func parity_n1ql_formatsInsertWithLargeObjectLiteral() throws {
  try assertFormatDialect(
    """
    INSERT INTO heroes (KEY, VALUE) VALUES ('123', {'id': 1, 'type': 'Tarzan',
    'array': [123456789, 123456789, 123456789, 123456789, 123456789], 'hello': 'world'});
    """,
    dialect: n1qlDialect,
    dedent(
      """
      INSERT INTO heroes(KEY,
      VALUE) VALUES('123',
      { 'id' : 1,
      'type' : 'Tarzan',
      'array' : [123456789,
      123456789,
      123456789,
      123456789,
      123456789],
      'hello' : 'world' });
      """
    )
  )
}

// Upstream: test/n1ql.test.ts :: formats SELECT query with UNNEST top level reserver word
// Swift divergence: UNNEST remains on same line as FROM source.
@Test func parity_n1ql_formatsSelectWithUnnestKeyword() throws {
  try assertFormatDialect(
    "SELECT * FROM tutorial UNNEST tutorial.children c;",
    dialect: n1qlDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tutorial UNNEST tutorial.children c;
      """
    )
  )
}

// Upstream: test/n1ql.test.ts :: formats SELECT query with NEST and USE KEYS
// Swift divergence: USE KEYS and NEST stay inline with FROM source.
@Test func parity_n1ql_formatsSelectWithNestAndUseKeys() throws {
  try assertFormatDialect(
    """
    SELECT * FROM usr
    USE KEYS 'Elinor_33313792' NEST orders_with_users orders
    ON KEYS ARRAY s.order_id FOR s IN usr.shipped_order_history END;
    """,
    dialect: n1qlDialect,
    dedent(
      """
      SELECT
        *
      FROM
        usr USE KEYS 'Elinor_33313792' NEST orders_with_users orders
      ON
        KEYS ARRAY s.order_id FOR s IN usr.shipped_order_history END;
      """
    )
  )
}

// Upstream: test/n1ql.test.ts :: formats explained DELETE query with USE KEYS
// Swift divergence: EXPLAIN remains inline with DELETE.
@Test func parity_n1ql_formatsExplainedDeleteWithUseKeys() throws {
  try assertFormatDialect(
    "EXPLAIN DELETE FROM tutorial t USE KEYS 'baldwin'",
    dialect: n1qlDialect,
    dedent(
      """
      EXPLAIN DELETE
      FROM
        tutorial t USE KEYS 'baldwin'
      """
    )
  )
}

// Upstream: test/n1ql.test.ts :: formats UPDATE query with USE KEYS
// Swift divergence: USE KEYS and SET remain inline with UPDATE.
@Test func parity_n1ql_formatsUpdateWithUseKeys() throws {
  try assertFormatDialect(
    "UPDATE tutorial USE KEYS 'baldwin' SET type = 'actor'",
    dialect: n1qlDialect,
    dedent(
      """
      UPDATE tutorial USE KEYS 'baldwin' SET type = 'actor'
      """
    )
  )
}
