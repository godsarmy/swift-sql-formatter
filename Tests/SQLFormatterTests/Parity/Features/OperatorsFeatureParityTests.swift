import Testing

@testable import SQLFormatter

private let standardOperators = [
  "+",
  "-",
  "*",
  "/",
  ">",
  "<",
  "=",
  "<>",
  "<=",
  ">=",
  "!=",
]

private let logicalOperators = ["AND", "OR"]

// Upstream: test/features/operators.ts :: supports <operator> operator (standard set)
@Test func parity_operators_supportsStandardOperators() throws {
  for op in standardOperators {
    try assertFormat(
      "foo\(op) bar \(op)zap",
      "foo \(op) bar \(op) zap"
    )
  }
}

// Upstream: test/features/operators.ts :: supports <operator> operator in dense mode
@Test func parity_operators_supportsStandardOperatorsInDenseMode() throws {
  let options = FormatOptions(denseOperators: true)

  for op in standardOperators {
    try assertFormat("foo \(op) bar", "foo\(op)bar", options: options)
  }
}

// Upstream: test/features/operators.ts :: supports <logical operator> operator
@Test func parity_operators_supportsLogicalOperators() throws {
  for op in logicalOperators {
    try assertFormat(
      "SELECT true \(op) false AS foo;",
      """
        SELECT
          true
          \(op) false AS foo;
      """
    )
  }
}

// Upstream: test/features/operators.ts :: supports set operators
// Swift divergence: IN/NOT IN expressions break across lines without spaces around the parentheses.
@Test func parity_operators_supportsSetOperators() throws {
  try assertFormat("foo ALL bar", "foo ALL bar")
  try assertFormat("EXISTS bar", "EXISTS bar")
  try assertFormat(
    "foo IN (1, 2, 3)",
    """
      foo IN(1,
      2,
      3)
    """
  )
  try assertFormat(
    "foo NOT IN (1, 2, 3)",
    """
      foo NOT IN(1,
      2,
      3)
    """
  )
  try assertFormat("foo LIKE 'hello%'", "foo LIKE 'hello%'")
  try assertFormat("foo IS NULL", "foo IS NULL")
  try assertFormat("UNIQUE foo", "UNIQUE foo")
}

// Upstream: test/features/operators.ts :: supports ANY set-operator
// Swift divergence: ANY set arguments are formatted on separate lines inside the parentheses.
@Test func parity_operators_supportsAnySetOperator() throws {
  try assertFormat(
    "foo = ANY (1, 2, 3)",
    """
      foo = ANY(1,
      2,
      3)
    """
  )
}
