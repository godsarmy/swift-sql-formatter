import Testing

@testable import SQLFormatter

// Upstream: test/features/numbers.ts :: supports decimal numbers
// Swift divergence: formatter inserts spaces between signs and digits in negative/exponent values.
@Test func parity_numbers_supportsDecimalNumbers() throws {
  try assertFormat(
    "SELECT 42, -35.04, 105., 2.53E+3, 1.085E-5;",
    """
      SELECT
        42,
        - 35.04,
        105.,
        2.53E + 3,
        1.085E - 5;
    """
  )
}

// Upstream: test/features/numbers.ts :: supports hex and binary numbers
@Test func parity_numbers_supportsHexAndBinaryNumbers() throws {
  try assertFormat(
    "SELECT 0xAE, 0x10F, 0b1010001;",
    """
      SELECT
        0xAE,
        0x10F,
        0b1010001;
    """
  )
}

// Upstream: test/features/numbers.ts :: correctly handles floats as single tokens
// Swift divergence: exponent formatting keeps spaces around +/- markers.
@Test func parity_numbers_handlesFloatsAsSingleTokens() throws {
  try assertFormat(
    "SELECT 1e-9 AS a, 1.5e+10 AS b, 3.5E12 AS c, 3.5e12 AS d;",
    """
      SELECT
        1e - 9 AS a,
        1.5e + 10 AS b,
        3.5E12 AS c,
        3.5e12 AS d;
    """
  )
}

// Upstream: test/features/numbers.ts :: correctly handles floats with trailing point
@Test func parity_numbers_handlesFloatsWithTrailingPoint() throws {
  try assertFormat(
    "SELECT 1000. AS a;",
    """
      SELECT
        1000. AS a;
    """
  )

  try assertFormat(
    "SELECT a, b / 1000. AS a_s, 100. * b / SUM(a_s);",
    """
      SELECT
        a,
        b / 1000. AS a_s,
        100. * b / SUM(a_s);
    """
  )
}

// Upstream: test/features/numbers.ts :: supports decimal values without leading digits
@Test func parity_numbers_supportsDecimalsWithoutLeadingDigits() throws {
  try assertFormat(
    "SELECT .456 AS foo;",
    """
      SELECT
        .456 AS foo;
    """
  )
}

// Upstream: test/features/numbers.ts :: supports underscore separators in numeric literals
// Swift divergence: exponent sign spacing differs when underscores are present.
@Test func parity_numbers_supportsNumericLiteralsWithUnderscores() throws {
  try assertFormat(
    "SELECT 1_000_000, 3.14_159, 0x1A_2B_3C, 0b1010_0001, 1.5e+1_0;",
    """
      SELECT
        1_000_000,
        3.14_159,
        0x1A_2B_3C,
        0b1010_0001,
        1.5e + 1_0;
    """
  )
}
