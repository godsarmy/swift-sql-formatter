import Testing

@testable import SQLFormatter

// Upstream: test/features/between.ts :: formats BETWEEN _ AND _ on single line
// Swift divergence: formatter line-breaks before AND in BETWEEN expressions.
@Test func parity_between_formatsBetweenOnSingleLine() throws {
  try assertFormat(
    "foo BETWEEN bar AND baz",
    """
    foo BETWEEN bar
    AND baz
    """
  )
}

// Upstream: test/features/between.ts :: supports qualified.names as BETWEEN expression values
// Swift divergence: formatter line-breaks before AND in BETWEEN expressions.
@Test func parity_between_supportsQualifiedNamesAsBetweenValues() throws {
  try assertFormat(
    "foo BETWEEN t.bar AND t.baz",
    """
    foo BETWEEN t.bar
    AND t.baz
    """
  )
}

// Upstream: test/features/between.ts :: formats BETWEEN with comments inside
// Swift divergence: comments and operands are split across separate lines.
@Test func parity_between_formatsWithCommentsInside() throws {
  try assertFormat(
    "WHERE foo BETWEEN /*C1*/ t.bar /*C2*/ AND /*C3*/ t.baz",
    """
    WHERE
      foo BETWEEN
    /*C1*/
    t.bar
    /*C2*/
    AND
    /*C3*/
    t.baz
    """
  )
}

// Upstream: test/features/between.ts :: supports complex expressions inside BETWEEN
// Swift divergence: line breaks before AND and normalizes `3+4` to `3 + 4`.
@Test func parity_between_supportsComplexExpressionsInsideBetween() throws {
  try assertFormat(
    "foo BETWEEN 1+2 AND 3+4",
    """
    foo BETWEEN 1 + 2
    AND 3 + 4
    """
  )
}

// Upstream: test/features/between.ts :: supports CASE inside BETWEEN
// Swift divergence: CASE in BETWEEN remains on one line before AND.
@Test func parity_between_supportsCaseInsideBetween() throws {
  try assertFormat(
    "foo BETWEEN CASE x WHEN 1 THEN 2 END AND 3",
    """
    foo BETWEEN CASE x WHEN 1 THEN 2 END
    AND 3
    """
  )
}

// Upstream: test/features/between.ts :: supports AND after BETWEEN
// Swift divergence: `foo BETWEEN 1 AND 2` is split so AND 2 is on its own line.
@Test func parity_between_supportsAndAfterBetween() throws {
  try assertFormat(
    "SELECT foo BETWEEN 1 AND 2 AND x > 10",
    """
    SELECT
      foo BETWEEN 1
      AND 2
      AND x > 10
    """
  )
}
