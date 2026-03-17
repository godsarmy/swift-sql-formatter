import Testing

@testable import SQLFormatter

// Upstream: test/options/paramTypes.ts :: when paramTypes.positional=true
@Test func parity_paramTypes_supportsPositional() throws {
  try assertFormat(
    "SELECT ?, ?, ?;",
    """
      SELECT
        first,
        second,
        third;
      """,
    options: FormatOptions(
      positionalPlaceholders: ["first", "second", "third"],
      placeholderTypes: [.questionMark]
    )
  )
}

// Upstream: test/options/paramTypes.ts :: when paramTypes.named=[":"]
@Test func parity_paramTypes_supportsNamed() throws {
  try assertFormat(
    "SELECT :a, :b, :c;",
    """
      SELECT
        first,
        second,
        third;
      """,
    options: FormatOptions(
      namedPlaceholders: ["a": "first", "b": "second", "c": "third"],
      placeholderTypes: [.colonNamed]
    )
  )
}
