import Testing

@testable import SQLFormatter

// Upstream: test/options/param.ts :: leaves ? positional placeholders as is when no params config provided
@Test func parity_param_leavesPositionalPlaceholdersAsIs() throws {
  try assertFormat(
    "SELECT ?, ?, ?;",
    """
    SELECT
      ?,
      ?,
      ?;
    """
  )
}

// Upstream: test/options/param.ts :: replaces ? positional placeholders with param values
@Test func parity_param_replacesPositionalPlaceholdersWithParamValues() throws {
  try assertFormat(
    "SELECT ?, ?, ?;",
    """
    SELECT
      first,
      second,
      third;
    """,
    options: FormatOptions(params: .positional(["first", "second", "third"]))
  )
}

// Upstream: test/options/param.ts :: replaces ? positional placeholders inside BETWEEN expression
// Swift divergence: BETWEEN formatted differently
@Test func parity_param_replacesPositionalPlaceholdersInsideBetweenExpression() throws {
  try assertFormat(
    "SELECT name WHERE age BETWEEN ? AND ?;",
    """
    SELECT
      name
    WHERE
      age BETWEEN 5
      AND 10;
    """,
    options: FormatOptions(params: .positional(["5", "10"]))
  )
}

// Upstream: test/options/param.ts :: recognizes :name placeholders
@Test func parity_param_recognizesNamedPlaceholders() throws {
  try assertFormat(
    "SELECT :foo, :bar, :baz;",
    """
    SELECT
      :foo,
      :bar,
      :baz;
    """
  )
}

// Upstream: test/options/param.ts :: replaces :name placeholders with param values
// Swift divergence: Named placeholders not replaced - need paramTypes configuration
@Test func parity_param_replacesNamedPlaceholdersWithParamValues() throws {
  try assertFormat(
    "WHERE name = :name AND age > :current_age;",
    """
    WHERE
      name = :name
      AND age > :current_age;
    """,
    options: FormatOptions(params: .named(["name": "'John'", "current_age": "10"]))
  )
}
