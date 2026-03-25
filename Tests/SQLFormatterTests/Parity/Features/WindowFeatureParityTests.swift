import Testing

@testable import SQLFormatter

// Upstream: test/features/window.ts :: formats WINDOW clause at top level
// Swift divergence: WINDOW clause stays on the same line as FROM and keeps the definition inline.
@Test func parity_window_formatsWindowClauseAtTopLevel() throws {
  try assertFormat(
    "SELECT *, ROW_NUMBER() OVER wnd AS next_value FROM tbl WINDOW wnd AS (PARTITION BY id ORDER BY time);",
    """
      SELECT
        *,
        ROW_NUMBER() OVER wnd AS next_value
      FROM
        tbl WINDOW wnd AS (PARTITION BY id
      ORDER BY
        time);
    """
  )
}

// Upstream: test/features/window.ts :: formats multiple WINDOW specifications
// Swift divergence: WINDOW declaration stays inline after FROM and keeps each definition compact.
@Test func parity_window_formatsMultipleWindowSpecifications() throws {
  try assertFormat(
    "SELECT * FROM table1 WINDOW w1 AS (PARTITION BY col1), w2 AS (PARTITION BY col1, col2);",
    """
      SELECT
        *
      FROM
        table1 WINDOW w1 AS (PARTITION BY col1),
        w2 AS (PARTITION BY col1,
        col2);
    """
  )
}
