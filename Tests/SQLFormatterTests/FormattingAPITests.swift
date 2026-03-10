import Testing

@testable import SQLFormatter

@Test func formatsBasicSelectFromWhereQuery() async throws {
  let sql = "SELECT id, name FROM people WHERE active = 1"
  let expected = """
    SELECT
      id,
      name
    FROM
      people
    WHERE
      active = 1
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func supportsReusableFormatterInstance() async throws {
  let formatter = SQLFormatter.Formatter()
  let sql = "SELECT id, name FROM people WHERE active = 1"
  let expected = """
    SELECT
      id,
      name
    FROM
      people
    WHERE
      active = 1
    """

  let result = try formatter.format(sql)

  #expect(result == expected)
}

@Test func formatsJoinGroupOrderAndLimitClauses() async throws {
  let sql =
    "SELECT id, name FROM users INNER JOIN teams ON users.team_id = teams.id WHERE active = 1 GROUP BY id, name ORDER BY name LIMIT 10"
  let expected = """
    SELECT
      id,
      name
    FROM
      users
    INNER JOIN
      teams
    ON
      users.team_id = teams.id
    WHERE
      active = 1
    GROUP BY
      id,
      name
    ORDER BY
      name
    LIMIT
      10
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsLeftOuterJoinAndNaturalJoinClauses() async throws {
  let sql =
    "SELECT id FROM users LEFT OUTER JOIN teams ON users.team_id = teams.id NATURAL JOIN offices"
  let expected = """
    SELECT
      id
    FROM
      users
    LEFT OUTER JOIN
      teams
    ON
      users.team_id = teams.id
    NATURAL JOIN
      offices
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func preservesCommentsAsStandaloneLines() async throws {
  let sql = "SELECT id FROM users -- active users\nWHERE active = 1"
  let expected = """
    SELECT
      id
    FROM
      users
    -- active users
    WHERE
      active = 1
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func separatesMultipleQueriesWithDefaultSpacing() async throws {
  let sql = "SELECT id FROM users; SELECT id FROM teams"
  let expected = """
    SELECT
      id
    FROM
      users;

    SELECT
      id
    FROM
      teams
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func respectsLinesBetweenQueriesOption() async throws {
  let sql = "SELECT id FROM users; SELECT id FROM teams"
  let expected = """
    SELECT
      id
    FROM
      users;
    SELECT
      id
    FROM
      teams
    """

  let result = try format(sql, options: FormatOptions(linesBetweenQueries: 0))

  #expect(result == expected)
}

@Test func respectsTabWidthOption() async throws {
  let sql = "SELECT id, name FROM users"
  let expected = """
    SELECT
        id,
        name
    FROM
        users
    """

  let result = try format(sql, options: FormatOptions(tabWidth: 4))

  #expect(result == expected)
}

@Test func tokenizerSplitsWordsOperatorsAndPunctuation() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT name, age FROM people WHERE active = 1")

  let expectedTypes: [TokenType] = [
    .word, .whitespace, .word, .punctuation, .whitespace, .word, .whitespace,
    .word, .whitespace, .word, .whitespace, .word, .whitespace, .word,
    .whitespace, .operatorToken, .whitespace, .word,
  ]

  #expect(tokens.map(\.type) == expectedTypes)
  #expect(
    tokens.map(\.text) == [
      "SELECT", " ", "name", ",", " ", "age", " ", "FROM", " ", "people", " ",
      "WHERE", " ", "active", " ", "=", " ", "1",
    ])
}

@Test func tokenizerKeepsQuotedTokensTogether() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT 'hello world', [user] FROM people")

  let expectedTypes: [TokenType] = [
    .word, .whitespace, .quoted, .punctuation, .whitespace, .quoted, .whitespace, .word,
    .whitespace, .word,
  ]

  #expect(tokens.map(\.type) == expectedTypes)
  #expect(tokens[2].text == "'hello world'")
  #expect(tokens[5].text == "[user]")
}

@Test func tokenizerCapturesLineAndBlockComments() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT /* note */ id -- trailing")

  let expectedTypes: [TokenType] = [
    .word, .whitespace, .comment, .whitespace, .word, .whitespace, .comment,
  ]

  #expect(tokens.map(\.type) == expectedTypes)
  #expect(tokens[2].text == "/* note */")
  #expect(tokens[6].text == "-- trailing")
}

@Test func tokenizerTracksTokenLocations() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT\n  name")

  #expect(tokens[0].location == SQLFormatter.SourceLocation(line: 1, column: 1, offset: 0))
  #expect(tokens[1].location == SQLFormatter.SourceLocation(line: 1, column: 7, offset: 6))
  #expect(tokens[2].location == SQLFormatter.SourceLocation(line: 2, column: 1, offset: 7))
  #expect(tokens[3].location == SQLFormatter.SourceLocation(line: 2, column: 3, offset: 9))
}

@Test func unterminatedQuotedTokenIncludesLocation() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)

  do {
    _ = try tokenizer.tokenize("SELECT\n'hello")
    Issue.record("Expected unterminated quoted token error")
  } catch let error as FormatError {
    #expect(
      error
        == .unterminatedQuotedToken(
          at: SQLFormatter.SourceLocation(line: 2, column: 1, offset: 7)
        ))
  }
}

@Test func unterminatedBlockCommentIncludesLocation() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)

  do {
    _ = try tokenizer.tokenize("SELECT\n/* note")
    Issue.record("Expected unterminated block comment error")
  } catch let error as FormatError {
    #expect(
      error
        == .unterminatedBlockComment(
          at: SQLFormatter.SourceLocation(line: 2, column: 1, offset: 7)
        ))
  }
}

@Test func defaultDialectIsStandardSQL() async throws {
  let options = FormatOptions.default

  #expect(options.dialect == .standardSQL)
  #expect(options.tabWidth == 2)
  #expect(options.useTabs == false)
  #expect(options.linesBetweenQueries == 1)
}
