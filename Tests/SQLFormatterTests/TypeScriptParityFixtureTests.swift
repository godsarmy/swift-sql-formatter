import Testing

@testable import SQLFormatter

private struct TypeScriptParityFixture {
  let name: String
  let sql: String
  let options: FormatOptions
  let expected: String
}

@Test func formatsStarterTypeScriptParityFixtures() async throws {
  let fixtures: [TypeScriptParityFixture] = [
    TypeScriptParityFixture(
      name: "order by with asc desc casing",
      sql: "SELECT foo FROM bar ORDER BY foo asc, zap desc",
      options: FormatOptions(keywordCase: .upper),
      expected: """
        SELECT
          foo
        FROM
          bar
        ORDER BY
          foo ASC,
          zap DESC
        """
    ),
    TypeScriptParityFixture(
      name: "positional placeholders",
      sql: "SELECT ? FROM users WHERE id = ?",
      options: FormatOptions(positionalPlaceholders: ["name", "42"]),
      expected: """
        SELECT
          name
        FROM
          users
        WHERE
          id = 42
        """
    ),
    TypeScriptParityFixture(
      name: "join formatting",
      sql: "SELECT id FROM users LEFT OUTER JOIN teams ON users.team_id = teams.id",
      options: .default,
      expected: """
        SELECT
          id
        FROM
          users
        LEFT OUTER JOIN
          teams
        ON
          users.team_id = teams.id
        """
    ),
  ]

  for fixture in fixtures {
    let result = try format(fixture.sql, options: fixture.options)
    #expect(result == fixture.expected, Comment(rawValue: fixture.name))
  }
}
