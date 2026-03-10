import Testing

@testable import SQLFormatter

private struct EndToEndFixture {
  let name: String
  let sql: String
  let options: FormatOptions
  let expected: String
}

@Test func formatsEndToEndFixturesForTrickyCoverage() async throws {
  let fixtures: [EndToEndFixture] = [
    EndToEndFixture(
      name: "nested subquery",
      sql: "SELECT id FROM (SELECT id FROM users) sub",
      options: .default,
      expected: """
        SELECT
          id
        FROM
          (
        SELECT
          id
        FROM
          users) sub
        """
    ),
    EndToEndFixture(
      name: "cte",
      sql: "WITH ids AS (SELECT id FROM users) SELECT id FROM ids",
      options: .default,
      expected: """
        WITH
          ids AS (
        SELECT
          id
        FROM
          users)
        SELECT
          id
        FROM
          ids
        """
    ),
    EndToEndFixture(
      name: "comments",
      sql: "SELECT id FROM users -- active users\nWHERE active = 1",
      options: .default,
      expected: """
        SELECT
          id
        FROM
          users
        -- active users
        WHERE
          active = 1
        """
    ),
    EndToEndFixture(
      name: "placeholders",
      sql: "SELECT :column FROM users WHERE id = ?",
      options: FormatOptions(
        positionalPlaceholders: ["42"],
        namedPlaceholders: ["column": "name"]
      ),
      expected: """
        SELECT
          name
        FROM
          users
        WHERE
          id = 42
        """
    ),
    EndToEndFixture(
      name: "quoted identifiers",
      sql: "SELECT \"full_name\" FROM \"user accounts\"",
      options: FormatOptions(dialect: .postgreSQL),
      expected: """
        SELECT
          "full_name"
        FROM
          "user accounts"
        """
    ),
    EndToEndFixture(
      name: "multiline expression wrapping",
      sql: "SELECT id FROM users WHERE active = 1 AND deleted = 0 AND archived = 0",
      options: FormatOptions(expressionWidth: 18),
      expected: """
        SELECT
          id
        FROM
          users
        WHERE
          active = 1
          AND deleted = 0
          AND archived = 0
        """
    ),
    EndToEndFixture(
      name: "multiple queries",
      sql: "SELECT id FROM users; SELECT id FROM teams",
      options: FormatOptions(linesBetweenQueries: 1),
      expected: """
        SELECT
          id
        FROM
          users;

        SELECT
          id
        FROM
          teams
        """
    ),
  ]

  for fixture in fixtures {
    let result = try format(fixture.sql, options: fixture.options)
    #expect(result == fixture.expected, Comment(rawValue: fixture.name))
  }
}
