import Testing

@testable import SQLFormatter

// Upstream: test/features/with.ts :: formats WITH clause with multiple Common Table Expressions (CTE)
// Swift divergence: SELECT bodies in CTEs currently lose expected nesting indentation.
@Test func parity_with_formatsWithClauseWithMultipleCTEs() throws {
  try assertFormat(
    """
      WITH
      cte_1 AS (
        SELECT a FROM b WHERE c = 1
      ),
      cte_2 AS (
        SELECT c FROM d WHERE e = 2
      ),
      final AS (
        SELECT * FROM cte_1 LEFT JOIN cte_2 ON b = d
      )
      SELECT * FROM final;
    """,
    """
    WITH
      cte_1 AS (
    SELECT
      a
    FROM
      b
    WHERE
      c = 1),
      cte_2 AS (
    SELECT
      c
    FROM
      d
    WHERE
      e = 2),
      final AS (
    SELECT
      *
    FROM
      cte_1
    LEFT JOIN
      cte_2
    ON
      b = d)
    SELECT
      *
    FROM
      final;
    """
  )
}

// Upstream: test/features/with.ts :: formats WITH clause with parameterized CTE
// Swift divergence: parameterized CTE parentheses and body indentation differ from upstream.
@Test func parity_with_formatsWithClauseWithParameterizedCTE() throws {
  try assertFormat(
    """
      WITH cte_1(id, parent_id) AS (
        SELECT id, parent_id
        FROM tab1
        WHERE parent_id IS NULL
      )
      SELECT id, parent_id FROM cte_1;
    """,
    """
    WITH
      cte_1(id,
      parent_id) AS (
    SELECT
      id,
      parent_id
    FROM
      tab1
    WHERE
      parent_id IS NULL)
    SELECT
      id,
      parent_id
    FROM
      cte_1;
    """
  )
}
