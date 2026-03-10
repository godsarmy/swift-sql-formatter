import Testing

@testable import SQLFormatter

private struct DialectFixture {
  let name: String
  let sql: String
  let options: FormatOptions
  let expected: String
}

@Test func formatsDialectFixtures() async throws {
  let fixtures: [DialectFixture] = [
    DialectFixture(
      name: "standard bracket identifier",
      sql: "SELECT [name] FROM [users] WHERE [active] = 1",
      options: FormatOptions(dialect: .standardSQL),
      expected: """
        SELECT
          [name]
        FROM
          [users]
        WHERE
          [active] = 1
        """
    ),
    DialectFixture(
      name: "postgres returning clause",
      sql: "SELECT \"name\" FROM \"users\" RETURNING id",
      options: FormatOptions(dialect: .postgreSQL),
      expected: """
        SELECT
          "name"
        FROM
          "users"
        RETURNING
          id
        """
    ),
    DialectFixture(
      name: "postgres cast and concat",
      sql: "SELECT metadata::jsonb || payload FROM events",
      options: FormatOptions(dialect: .postgreSQL),
      expected: """
        SELECT
          metadata :: jsonb || payload
        FROM
          events
        """
    ),
  ]

  for fixture in fixtures {
    let result = try format(fixture.sql, options: fixture.options)
    #expect(result == fixture.expected, Comment(rawValue: fixture.name))
  }
}
