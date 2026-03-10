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

@Test func supportsMultipleBlankLinesBetweenQueries() async throws {
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

  let result = try format(sql, options: FormatOptions(linesBetweenQueries: 2))

  #expect(result == expected)
}

@Test func placesSemicolonOnNewLineWhenConfigured() async throws {
  let sql = "SELECT id FROM users; SELECT id FROM teams"
  let expected = """
    SELECT
      id
    FROM
      users
    ;

    SELECT
      id
    FROM
      teams
    """

  let result = try format(sql, options: FormatOptions(newlineBeforeSemicolon: true))

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

@Test func respectsUseTabsOption() async throws {
  let sql = "SELECT id, name FROM users"
  let expected = "SELECT\n\tid,\n\tname\nFROM\n\tusers"

  let result = try format(sql, options: FormatOptions(tabWidth: 8, useTabs: true))

  #expect(result == expected)
}

@Test func respectsUpperKeywordCaseOption() async throws {
  let sql = "select id, name from users where active = 1"
  let expected = """
    SELECT
      id,
      name
    FROM
      users
    WHERE
      active = 1
    """

  let result = try format(sql, options: FormatOptions(keywordCase: .upper))

  #expect(result == expected)
}

@Test func respectsLowerKeywordCaseOption() async throws {
  let sql = "SELECT id, name FROM users WHERE active = 1"
  let expected = """
    select
      id,
      name
    from
      users
    where
      active = 1
    """

  let result = try format(sql, options: FormatOptions(keywordCase: .lower))

  #expect(result == expected)
}

@Test func placesLogicalOperatorsAfterExpressionsWhenConfigured() async throws {
  let sql = "SELECT id FROM users WHERE active = 1 AND deleted = 0 OR archived = 0"
  let expected = """
    SELECT
      id
    FROM
      users
    WHERE
      active = 1 AND
      deleted = 0 OR
      archived = 0
    """

  let result = try format(
    sql,
    options: FormatOptions(logicalOperatorNewline: .after)
  )

  #expect(result == expected)
}

@Test func keepsOperatorsDenseWhenConfigured() async throws {
  let sql = "SELECT price + (price * tax) FROM products WHERE id = 1"
  let expected = """
    SELECT
      price+(price*tax)
    FROM
      products
    WHERE
      id=1
    """

  let result = try format(sql, options: FormatOptions(denseOperators: true))

  #expect(result == expected)
}

@Test func wrapsLongExpressionsWhenExpressionWidthIsSet() async throws {
  let sql = "SELECT id FROM users WHERE active = 1 AND deleted = 0"
  let expected = """
    SELECT
      id
    FROM
      users
    WHERE
      active = 1
      AND deleted = 0
    """

  let result = try format(sql, options: FormatOptions(expressionWidth: 18))

  #expect(result == expected)
}

@Test func preservesKeywordCaseByDefault() async throws {
  let sql = "select id, name from users where active = 1"
  let expected = """
    select
      id,
      name
    from
      users
    where
      active = 1
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func doesNotWrapExpressionsWhenExpressionWidthIsNonPositive() async throws {
  let sql = "SELECT id FROM users WHERE active = 1 AND deleted = 0"
  let expected = """
    SELECT
      id
    FROM
      users
    WHERE
      active = 1
      AND deleted = 0
    """

  let result = try format(sql, options: FormatOptions(expressionWidth: 0))

  #expect(result == expected)
}

@Test func replacesPositionalPlaceholders() async throws {
  let sql = "SELECT ? FROM users WHERE id = ?"
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(sql, options: FormatOptions(positionalPlaceholders: ["name", "42"]))

  #expect(result == expected)
}

@Test func replacesNamedPlaceholders() async throws {
  let sql = "SELECT :column FROM users WHERE id = :id"
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(
    sql,
    options: FormatOptions(namedPlaceholders: ["column": "name", "id": "42"])
  )

  #expect(result == expected)
}

@Test func paramsAPIReplacesPositionalPlaceholders() async throws {
  let sql = "SELECT ? FROM users WHERE id = ?"
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(
    sql,
    options: FormatOptions(
      params: .positional(["name", "42"]),
      paramTypes: ParamTypes(positional: true)
    )
  )

  #expect(result == expected)
}

@Test func paramsAPIReplacesNumberedDialectPlaceholders() async throws {
  let sql = "SELECT $1 FROM users WHERE id = $2"
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(
    sql,
    options: FormatOptions(
      dialect: .postgreSQL,
      params: .named(["1": "name", "2": "42"])
    )
  )

  #expect(result == expected)
}

@Test func paramsAPIReplacesQuotedDialectPlaceholders() async throws {
  let sql = "SELECT @\"column\" FROM users WHERE id = @\"id\""
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(
    sql,
    options: FormatOptions(
      dialect: .transactSQL,
      params: .named(["column": "name", "id": "42"])
    )
  )

  #expect(result == expected)
}

@Test func paramsAPIReplacesClickHouseCustomPlaceholders() async throws {
  let sql = "SELECT {column:String} FROM users WHERE id = {id:Int32}"
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(
    sql,
    options: FormatOptions(
      dialect: .clickHouse,
      params: .named(["column": "name", "id": "42"])
    )
  )

  #expect(result == expected)
}

@Test func respectsConfiguredPlaceholderTypes() async throws {
  let sql = "SELECT @column, :column FROM users"
  let expected = """
    SELECT
      name,
      :column
    FROM
      users
    """

  let result = try format(
    sql,
    options: FormatOptions(
      namedPlaceholders: ["column": "name"],
      placeholderTypes: [.atNamed]
    )
  )

  #expect(result == expected)
}

@Test func paramTypesCanOverrideDialectDefaults() async throws {
  let sql = "SELECT :column FROM users WHERE id = :id"
  let expected = """
    SELECT
      name
    FROM
      users
    WHERE
      id = 42
    """

  let result = try format(
    sql,
    options: FormatOptions(
      dialect: .postgreSQL,
      params: .named(["column": "name", "id": "42"]),
      paramTypes: ParamTypes(named: [.colon])
    )
  )

  #expect(result == expected)
}

@Test func preservesContentBetweenDisableEnableDirectives() async throws {
  let sql = """
    SELECT id FROM users
    -- sql-formatter-disable
    select   id,   name   from users where active=1
    -- sql-formatter-enable
    SELECT id FROM teams
    """
  let expected = """
    SELECT
      id
    FROM
      users
    -- sql-formatter-disable
    select   id,   name   from users where active=1
    -- sql-formatter-enable
    SELECT
      id
    FROM
      teams
    """

  let result = try format(sql)

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

@Test func tokenizerTracksUnicodeAndCRLFLocations() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT\r\n😀name")

  #expect(tokens[0].location == SQLFormatter.SourceLocation(line: 1, column: 1, offset: 0))
  #expect(tokens[1].location == SQLFormatter.SourceLocation(line: 1, column: 7, offset: 6))
  #expect(tokens[2].location == SQLFormatter.SourceLocation(line: 2, column: 1, offset: 8))
  #expect(tokens[2].text == "😀name")
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
  #expect(options.keywordCase == .preserve)
  #expect(options.logicalOperatorNewline == .before)
  #expect(options.linesBetweenQueries == 1)
  #expect(options.expressionWidth == nil)
  #expect(options.newlineBeforeSemicolon == false)
  #expect(options.denseOperators == false)
  #expect(options.positionalPlaceholders == [])
  #expect(options.namedPlaceholders == [:])
  #expect(
    options.placeholderTypes
      == [.questionMark, .colonNamed, .atNamed, .dollarNamed]
  )
}

@Test func canResolveDialectByNameFromRegistry() async throws {
  let expectedDialects: [(String, Dialect)] = [
    ("sql", .standardSQL),
    ("bigquery", .bigQuery),
    ("clickhouse", .clickHouse),
    ("db2", .db2),
    ("db2i", .db2i),
    ("duckdb", .duckDB),
    ("hive", .hive),
    ("mariadb", .mariaDB),
    ("mysql", .mySQL),
    ("tidb", .tiDB),
    ("n1ql", .n1ql),
    ("plsql", .plSQL),
    ("postgresql", .postgreSQL),
    ("redshift", .redshift),
    ("singlestoredb", .singleStoreDB),
    ("snowflake", .snowflake),
    ("spark", .spark),
    ("sqlite", .sqlite),
    ("transactsql", .transactSQL),
    ("trino", .trino),
  ]

  for (name, dialect) in expectedDialects {
    #expect(DialectRegistry.dialect(named: name) == dialect)
  }

  #expect(DialectRegistry.dialect(named: "postgres") == .postgreSQL)
  #expect(DialectRegistry.dialect(named: "singlestore") == .singleStoreDB)
  #expect(DialectRegistry.dialect(named: "tsql") == .transactSQL)
  #expect(DialectRegistry.dialect(named: "missing") == nil)
}

@Test func postgreSQLDialectTokenizesPostgresSpecificOperators() async throws {
  let tokenizer = Tokenizer(dialect: .postgreSQL)
  let tokens = try tokenizer.tokenize("SELECT meta::jsonb || data")

  #expect(tokens.map(\.text) == ["SELECT", " ", "meta", "::", "jsonb", " ", "||", " ", "data"])
  #expect(tokens[3].type == .operatorToken)
  #expect(tokens[6].type == .operatorToken)
}

@Test func standardDialectDoesNotTokenizePostgresSpecificOperators() async throws {
  let tokenizer = Tokenizer(dialect: .standardSQL)
  let tokens = try tokenizer.tokenize("SELECT meta::jsonb || data")

  #expect(tokens.contains(where: { $0.text == "::" && $0.type == .operatorToken }) == false)
  #expect(tokens.contains(where: { $0.text == "||" && $0.type == .operatorToken }) == false)
}

@Test func postgreSQLDialectFormatsReturningClauseAndKeywordCasing() async throws {
  let sql = "select id from users returning id"
  let expected = """
    SELECT
      id
    FROM
      users
    RETURNING
      id
    """

  let result = try format(sql, options: FormatOptions(dialect: .postgreSQL, keywordCase: .upper))

  #expect(result == expected)
}
