import Testing

@testable import SQLFormatter

// Upstream: test/features/limiting.ts :: formats LIMIT with two comma-separated values on single line
// Swift divergence: LIMIT values are split into separate lines instead of remaining comma-delimited on one line.
@Test func parity_limiting_formatsLimitWithTwoCommaSeparatedValuesOnSingleLine() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      LIMIT 5, 10;
    """,
    """
    SELECT
      *
    FROM
      tbl
    LIMIT
      5,
      10;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT with complex expressions
// Swift divergence: limit expressions are normalized with added spacing and split across lines for each expression.
@Test func parity_limiting_formatsLimitWithComplexExpressions() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      LIMIT abs(-5) - 1, (2 + 3) * 5;
    """,
    """
    SELECT
      *
    FROM
      tbl
    LIMIT
      abs( - 5) - 1,
      (2 + 3) * 5;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT with comments
// Swift divergence: inline comments attach directly below LIMIT with minimal indentation and split each expression line.
@Test func parity_limiting_formatsLimitWithComments() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      LIMIT --comment
       5,--comment
      6;
    """,
    """
    SELECT
      *
    FROM
      tbl
    LIMIT
    --comment
    5,
    --comment
    6;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT in tabular style
// Swift divergence: the second LIMIT value wraps to the next line under tabular indentation.
@Test func parity_limiting_formatsLimitInTabularStyle() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      LIMIT 5, 6;
    """,
    """
    SELECT    *
    FROM      tbl
    LIMIT     5,
              6;
    """,
    options: FormatOptions(indentStyle: .tabularLeft)
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT of single value and OFFSET
// Swift divergence: OFFSET stays on the same line as the preceding LIMIT value.
@Test func parity_limiting_formatsLimitOfSingleValueAndOffset() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      LIMIT 5
      OFFSET 8;
    """,
    """
    SELECT
      *
    FROM
      tbl
    LIMIT
      5 OFFSET 8;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats FETCH FIRST
// Swift divergence: FETCH FIRST remains on the same line as the FROM clause.
@Test func parity_limiting_formatsFetchFirst() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      FETCH FIRST 10 ROWS ONLY;
    """,
    """
    SELECT
      *
    FROM
      tbl FETCH FIRST 10 ROWS ONLY;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats FETCH NEXT
// Swift divergence: FETCH NEXT remains adjacent to the FROM clause instead of moving to its own lines.
@Test func parity_limiting_formatsFetchNext() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      FETCH NEXT 1 ROW ONLY;
    """,
    """
    SELECT
      *
    FROM
      tbl FETCH NEXT 1 ROW ONLY;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats OFFSET ... FETCH FIRST
// Swift divergence: OFFSET ... FETCH FIRST stays on the same line following the FROM clause.
@Test func parity_limiting_formatsOffsetFetchFirst() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      OFFSET 250 ROWS
      FETCH FIRST 5 ROWS ONLY;
    """,
    """
    SELECT
      *
    FROM
      tbl OFFSET 250 ROWS FETCH FIRST 5 ROWS ONLY;
    """
  )
}

// Upstream: test/features/limiting.ts :: formats OFFSET ... FETCH NEXT
// Swift divergence: OFFSET ... FETCH NEXT stays on the same line after FROM.
@Test func parity_limiting_formatsOffsetFetchNext() throws {
  try assertFormat(
    """
      SELECT *
      FROM tbl
      OFFSET 250 ROWS
      FETCH NEXT 5 ROWS ONLY;
    """,
    """
    SELECT
      *
    FROM
      tbl OFFSET 250 ROWS FETCH NEXT 5 ROWS ONLY;
    """
  )
}
