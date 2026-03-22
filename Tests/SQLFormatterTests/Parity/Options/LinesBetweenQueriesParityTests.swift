import Testing

@testable import SQLFormatter

// Upstream: test/options/linesBetweenQueries.ts :: defaults to single empty line between queries
@Test func parity_linesBetweenQueries_defaultsToSingleEmptyLineBetweenQueries() throws {
  try assertFormat(
    "SELECT * FROM foo; SELECT * FROM bar;",
    """
    SELECT
      *
    FROM
      foo;

    SELECT
      *
    FROM
      bar;
    """
  )
}

// Upstream: test/options/linesBetweenQueries.ts :: supports more empty lines between queries
@Test func parity_linesBetweenQueries_supportsMoreEmptyLinesBetweenQueries() throws {
  try assertFormat(
    "SELECT * FROM foo; SELECT * FROM bar;",
    """
    SELECT
      *
    FROM
      foo;


    SELECT
      *
    FROM
      bar;
    """,
    options: FormatOptions(linesBetweenQueries: 2)
  )
}

// Upstream: test/options/linesBetweenQueries.ts :: supports no empty lines between queries
@Test func parity_linesBetweenQueries_supportsNoEmptyLinesBetweenQueries() throws {
  try assertFormat(
    "SELECT * FROM foo; SELECT * FROM bar;",
    """
    SELECT
      *
    FROM
      foo;
    SELECT
      *
    FROM
      bar;
    """,
    options: FormatOptions(linesBetweenQueries: 0)
  )
}
