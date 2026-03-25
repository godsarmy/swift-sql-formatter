import Testing

@testable import SQLFormatter

// Upstream: test/features/arrayAndMapAccessors.ts :: supports square brackets for array indexing
// Swift divergence: formatter inserts spaces before square brackets on array accessors.
@Test func parity_arrayAndMapAccessors_supportsArrayIndexing() throws {
  try assertFormat(
    "SELECT arr[1], order_lines[5].productId;",
    """
    SELECT
      arr [1],
      order_lines [5].productId;
    """
  )
}

// Upstream: test/features/arrayAndMapAccessors.ts :: supports square brackets for map lookup
// Swift divergence: formatter inserts spaces before square brackets on map accessors.
@Test func parity_arrayAndMapAccessors_supportsMapLookup() throws {
  try assertFormat(
    "SELECT alpha['a'], beta['gamma'].zeta, yota['foo.bar-baz'];",
    """
    SELECT
      alpha ['a'],
      beta ['gamma'].zeta,
      yota ['foo.bar-baz'];
    """
  )
}

// Upstream: test/features/arrayAndMapAccessors.ts :: supports square brackets for map lookup - uppercase
// Swift divergence: identifierCase upper still leaves spaces before square brackets.
@Test func parity_arrayAndMapAccessors_supportsMapLookupUppercaseIdentifiers() throws {
  try assertFormat(
    "SELECT Alpha['a'], Beta['gamma'].zeTa, yotA['foo.bar-baz'];",
    """
    SELECT
      ALPHA ['a'],
      BETA ['gamma'].ZETA,
      YOTA ['foo.bar-baz'];
    """,
    options: FormatOptions(identifierCase: .upper)
  )
}

// Upstream: test/features/arrayAndMapAccessors.ts :: supports namespaced array identifiers
// Swift divergence: namespace parts are followed by spaces before array accessors.
@Test func parity_arrayAndMapAccessors_supportsNamespacedArrayIdentifiers() throws {
  try assertFormat(
    "SELECT foo.coalesce['blah'];",
    """
    SELECT
      foo.coalesce ['blah'];
    """
  )
}

// Upstream: test/features/arrayAndMapAccessors.ts :: formats array accessor with comment in-between
// Swift divergence: comments split the identifier and array accessor onto separate lines.
@Test func parity_arrayAndMapAccessors_formatsArrayAccessorWithComment() throws {
  try assertFormat(
    "SELECT arr /* comment */ [1];",
    """
    SELECT
      arr
    /* comment */
    [1];
    """
  )
}

// Upstream: test/features/arrayAndMapAccessors.ts :: formats namespaced array accessor with comment in-between
// Swift divergence: comments cause namespace and accessor to break across lines with spaces.
@Test func parity_arrayAndMapAccessors_formatsNamespacedArrayAccessorWithComment() throws {
  try assertFormat(
    "SELECT foo./* comment */arr[1];",
    """
    SELECT
      foo.
    /* comment */
    arr [1];
    """
  )
}

// Upstream: test/features/arrayAndMapAccessors.ts :: changes case of array accessors when identifierCase option used
// Swift divergence: identifier case changes still leave a space before array brackets.
@Test func parity_arrayAndMapAccessors_changesIdentifierCaseInArrayAccessors() throws {
  try assertFormat(
    "SELECT arr[1];",
    """
    SELECT
      ARR [1];
    """,
    options: FormatOptions(identifierCase: .upper)
  )

  try assertFormat(
    "SELECT NS.Arr[1];",
    """
    SELECT
      ns.arr [1];
    """,
    options: FormatOptions(identifierCase: .lower)
  )
}
