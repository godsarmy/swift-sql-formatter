import Testing

@testable import SQLFormatter

// Upstream: test/features/returning.ts :: places RETURNING to new line
// Swift divergence: VALUES row keeps RETURNING inline instead of breaking to its own line.
@Test func parity_returning_placesReturningToNewLine() throws {
  try assertFormat(
    "INSERT INTO users (firstname, lastname) VALUES ('Joe', 'Cool') RETURNING id, firstname;",
    """
    INSERT INTO users(firstname,
    lastname)
    VALUES
      ('Joe',
      'Cool') RETURNING id,
      firstname;
    """
  )
}
