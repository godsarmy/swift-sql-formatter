import Testing

@testable import SQLFormatter

private let trinoDialect: Dialect = .trino

// Upstream: test/trino.test.ts :: formats SET SESSION
@Test func parity_trino_formatsSetSession() throws {
  try assertFormatDialect(
    "SET SESSION foo = 444;",
    dialect: trinoDialect,
    dedent(
      """
      SET SESSION foo = 444;
      """
    )
  )
}

// Upstream: test/trino.test.ts :: formats row PATTERN()s
// Swift divergence: MATCH_RECOGNIZE clauses stay inline and grouping differs.
@Test func parity_trino_formatsRowPatterns() throws {
  try assertFormatDialect(
    "SELECT * FROM orders MATCH_RECOGNIZE(\n        PARTITION BY custkey\n        ORDER BY orderdate\n        MEASURES\n                  A.totalprice AS starting_price,\n                  LAST(B.totalprice) AS bottom_price,\n                  LAST(U.totalprice) AS top_price\n        ONE ROW PER MATCH\n        AFTER MATCH SKIP PAST LAST ROW\n        PATTERN ((A | B){5} {- C+ D+ -} E+)\n        SUBSET U = (C, D)\n        DEFINE\n                  B AS totalprice < PREV(totalprice),\n                  C AS totalprice > PREV(totalprice) AND totalprice <= A.totalprice,\n                  D AS totalprice > PREV(totalprice)\n        )",
    dialect: trinoDialect,
    dedent(
      """
      SELECT
        *
      FROM
        orders MATCH_RECOGNIZE( PARTITION BY custkey
      ORDER BY
        orderdate MEASURES A.totalprice AS
        starting_price,
        LAST(B.totalprice) AS bottom_price,
        LAST(U.totalprice) AS top_price ONE ROW PER
        MATCH AFTER MATCH SKIP PAST LAST ROW PATTERN((A
        | B) {5} { - C + D + - } E +) SUBSET U = (C,
        D) DEFINE B AS totalprice < PREV(totalprice),
        C AS totalprice > PREV(totalprice)
        AND totalprice <= A.totalprice,
        D AS totalprice > PREV(totalprice))
      """
    )
  )
}
