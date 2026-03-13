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

@Test func returnsEmptyStringForEmptyInput() async throws {
  let result = try format("")

  #expect(result == "")
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

@Test func formatsMultipleCtes() async throws {
  let sql = "WITH ids AS (SELECT id FROM users), teams AS (SELECT id FROM teams) SELECT id FROM ids"
  let expected = """
    WITH
      ids AS (
    SELECT
      id
    FROM
      users),
      teams AS (
    SELECT
      id
    FROM
      teams)
    SELECT
      id
    FROM
      ids
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCteColumnLists() async throws {
  let sql = "WITH ids(a) AS (SELECT id FROM users) SELECT a FROM ids"
  let expected = """
    WITH
      ids(a) AS (
    SELECT
      id
    FROM
      users)
    SELECT
      a
    FROM
      ids
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsUnionAllQueries() async throws {
  let sql = "SELECT id FROM users UNION ALL SELECT id FROM teams"
  let expected = """
    SELECT
      id
    FROM
      users UNION ALL
    SELECT
      id
    FROM
      teams
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsIntersectQueries() async throws {
  let sql = "SELECT id FROM users INTERSECT SELECT id FROM teams"
  let expected = """
    SELECT
      id
    FROM
      users INTERSECT
    SELECT
      id
    FROM
      teams
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCaseExpressionsInSelectLists() async throws {
  let sql = "SELECT CASE WHEN active = 1 THEN name ELSE email END FROM users"
  let expected = """
    SELECT
      CASE WHEN active = 1 THEN name ELSE email END
    FROM
      users
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateTableStatements() async throws {
  let sql = "CREATE TABLE users (id INT, name VARCHAR(20), active BOOLEAN);"
  let expected = """
    CREATE TABLE users(id INT,
    name VARCHAR(20),
    active BOOLEAN);
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsInsertValuesStatements() async throws {
  let sql = "INSERT INTO users (id, name) VALUES (1, 'A'), (2, 'B');"
  let expected = """
    INSERT INTO users(id,
    name)
    VALUES
      (1,
      'A'),
      (2,
      'B');
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsInsertSelectStatements() async throws {
  let sql = "INSERT INTO users SELECT id, name FROM archived_users;"
  let expected = """
    INSERT INTO users
    SELECT
      id,
      name
    FROM
      archived_users;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsUpdateStatements() async throws {
  let sql = "UPDATE users SET name = 'A', active = 1 WHERE id = 1;"
  let expected = """
    UPDATE users
    SET
      name = 'A',
      active = 1
    WHERE
      id = 1;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsDeleteStatements() async throws {
  let sql = "DELETE FROM users WHERE active = 0;"
  let expected = """
    DELETE FROM users
    WHERE
      active = 0;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateTableAsSelectStatements() async throws {
  let sql = "CREATE TABLE t AS SELECT id FROM users;"
  let expected = """
    CREATE TABLE t AS
    SELECT
      id
    FROM
      users;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsInsertSelectWithColumnListAndPredicate() async throws {
  let sql = "INSERT INTO users (id, name) SELECT id, name FROM archived_users WHERE active = 1;"
  let expected = """
    INSERT INTO users(id,
    name)
    SELECT
      id,
      name
    FROM
      archived_users
    WHERE
      active = 1;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsUpdateStatementsWithCaseExpressions() async throws {
  let sql = "UPDATE users SET name = CASE WHEN active = 1 THEN 'A' ELSE 'B' END WHERE id = 1;"
  let expected = """
    UPDATE users
    SET
      name = CASE WHEN active = 1 THEN 'A' ELSE 'B' END
    WHERE
      id = 1;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsDeleteUsingStatements() async throws {
  let sql = "DELETE FROM users USING archived_users WHERE users.id = archived_users.id;"
  let expected = """
    DELETE FROM users USING archived_users
    WHERE
      users.id = archived_users.id;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateViewStatements() async throws {
  let sql = "CREATE VIEW active_users AS SELECT id, name FROM users WHERE active = 1;"
  let expected = """
    CREATE VIEW active_users AS
    SELECT
      id,
      name
    FROM
      users
    WHERE
      active = 1;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateOrReplaceViewStatements() async throws {
  let sql = "CREATE OR REPLACE VIEW active_users AS SELECT id FROM users;"
  let expected = """
    CREATE OR REPLACE VIEW active_users AS
    SELECT
      id
    FROM
      users;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateViewWithColumnsStatements() async throws {
  let sql = "CREATE VIEW my_view (id, fname, lname) AS SELECT * FROM tbl;"
  let expected = """
    CREATE VIEW my_view(id,
    fname,
    lname) AS
    SELECT
      *
    FROM
      tbl;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateViewIfNotExistsStatements() async throws {
  let sql = "CREATE VIEW IF NOT EXISTS my_view AS SELECT 42;"
  let expected = """
    CREATE VIEW IF NOT EXISTS my_view AS
    SELECT
      42;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateMaterializedViewStatements() async throws {
  let sql = "CREATE MATERIALIZED VIEW mat_view AS SELECT 42;"
  let expected = """
    CREATE MATERIALIZED VIEW mat_view AS
    SELECT
      42;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsTruncateTableStatements() async throws {
  let sql = "TRUNCATE TABLE users;"
  let expected = """
    TRUNCATE TABLE users;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsTruncateStatementsWithoutTableKeyword() async throws {
  let sql = "TRUNCATE Customers;"
  let expected = """
    TRUNCATE Customers;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsTruncateTableLists() async throws {
  let sql = "TRUNCATE TABLE users, teams;"
  let expected = """
    TRUNCATE TABLE users,
    teams;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsTruncateTableRestartIdentityStatements() async throws {
  let sql = "TRUNCATE TABLE users RESTART IDENTITY;"
  let expected = """
    TRUNCATE TABLE users RESTART IDENTITY;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsTruncateTableCascadeStatements() async throws {
  let sql = "TRUNCATE TABLE users CASCADE;"
  let expected = """
    TRUNCATE TABLE users CASCADE;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsMergeIntoStatements() async throws {
  let sql =
    "MERGE INTO tgt USING src ON tgt.id = src.id WHEN MATCHED THEN UPDATE SET name = src.name WHEN NOT MATCHED THEN INSERT (id, name) VALUES (src.id, src.name);"
  let expected = """
    MERGE INTO tgt
    USING
      src
    ON
      tgt.id = src.id
    WHEN MATCHED
    THEN
    UPDATE
    SET
      name = src.name
    WHEN NOT MATCHED
    THEN
      INSERT (id,
      name)
    VALUES
      (src.id,
      src.name);
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsMergeIntoDeleteBranches() async throws {
  let sql = "MERGE INTO tgt USING src ON tgt.id = src.id WHEN MATCHED THEN DELETE;"
  let expected = """
    MERGE INTO tgt
    USING
      src
    ON
      tgt.id = src.id
    WHEN MATCHED
    THEN
      DELETE;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsMergeIntoStatementsWithAliases() async throws {
  let sql =
    "MERGE INTO DetailedInventory AS t USING Inventory AS i ON t.product = i.product WHEN MATCHED THEN UPDATE SET quantity = t.quantity + i.quantity WHEN NOT MATCHED THEN INSERT (product, quantity) VALUES ('Horse saddle', 12);"
  let expected = """
    MERGE INTO DetailedInventory AS t
    USING
      Inventory AS i
    ON
      t.product = i.product
    WHEN MATCHED
    THEN
    UPDATE
    SET
      quantity = t.quantity + i.quantity
    WHEN NOT MATCHED
    THEN
      INSERT (product,
      quantity)
    VALUES
      ('Horse saddle',
      12);
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsMergeIntoNotMatchedBySourceBranches() async throws {
  let sql = "MERGE INTO tgt USING src ON tgt.id = src.id WHEN NOT MATCHED BY SOURCE THEN DELETE;"
  let expected = """
    MERGE INTO tgt
    USING
      src
    ON
      tgt.id = src.id
    WHEN NOT MATCHED BY SOURCE
    THEN
      DELETE;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsMergeIntoNotMatchedByTargetBranches() async throws {
  let sql =
    "MERGE INTO tgt USING src ON tgt.id = src.id WHEN NOT MATCHED BY TARGET THEN INSERT (id) VALUES (src.id);"
  let expected = """
    MERGE INTO tgt
    USING
      src
    ON
      tgt.id = src.id
    WHEN NOT MATCHED BY TARGET
    THEN
      INSERT (id)
    VALUES
      (src.id);
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsCreateViewWithCheckOptionStatements() async throws {
  let sql = "CREATE VIEW active_users AS SELECT id FROM users WHERE active = 1 WITH CHECK OPTION;"
  let expected = """
    CREATE VIEW active_users AS
    SELECT
      id
    FROM
      users
    WHERE
      active = 1
    WITH
      CHECK OPTION;
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func preservesMixedNumericLiteralForms() async throws {
  let sql = "SELECT 1, 1.25, -4, 6e7 FROM numbers"
  let expected = """
    SELECT
      1,
      1.25,
      - 4,
      6e7
    FROM
      numbers
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func preservesBasicSingleQuotedStrings() async throws {
  let sql = "SELECT 'hello', 'world' FROM users"
  let expected = """
    SELECT
      'hello',
      'world'
    FROM
      users
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func preservesEscapedSingleQuotedStrings() async throws {
  let sql = "SELECT 'a''b', 'it''s ok' FROM users"
  let expected = """
    SELECT
      'a''b',
      'it''s ok'
    FROM
      users
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func preservesPrefixedNationalCharacterStrings() async throws {
  let sql = "SELECT N'name', N'it''s' FROM tbl"
  let expected = """
    SELECT
      N'name',
      N'it''s'
    FROM
      tbl
    """

  let result = try format(sql, options: FormatOptions(dialect: .transactSQL))

  #expect(result == expected)
}

@Test func preservesPostgresEscapeStrings() async throws {
  let sql = #"SELECT E'Line\nBreak', E'It\'s ok' FROM users"#
  let expected = #"""
    SELECT
      E'Line\nBreak',
      E'It\'s ok'
    FROM
      users
    """#

  let result = try format(sql, options: FormatOptions(dialect: .postgreSQL))

  #expect(result == expected)
}

@Test func preservesUnicodeEscapeStrings() async throws {
  let sql = #"SELECT U&'d\0061t\+000061' FROM users"#
  let expected = #"""
    SELECT
      U&'d\0061t\+000061'
    FROM
      users
    """#

  let result = try format(sql, options: FormatOptions(dialect: .postgreSQL))

  #expect(result == expected)
}

@Test func preservesDollarQuotedStrings() async throws {
  let sql = "SELECT $$hello$$, $tag$inner$tag$ FROM users"
  let expected = """
    SELECT
      $$hello$$,
      $tag$inner$tag$
    FROM
      users
    """

  let result = try format(sql, options: FormatOptions(dialect: .postgreSQL))

  #expect(result == expected)
}

@Test func preservesTripleQuotedBigQueryStrings() async throws {
  let sql = "SELECT '''abc''', '''line\nvalue''' FROM t"
  let expected = """
    SELECT
      '''abc''',
      '''line
    value'''
    FROM
      t
    """

  let result = try format(sql, options: FormatOptions(dialect: .bigQuery))

  #expect(result == expected)
}

@Test func preservesTripleDoubleQuotedBigQueryStrings() async throws {
  let sql = "SELECT \"\"\"abc\"\"\", \"\"\"line\nvalue\"\"\" FROM t"
  let expected = ##"""
    SELECT
      """abc""",
      """line
    value"""
    FROM
      t
    """##

  let result = try format(sql, options: FormatOptions(dialect: .bigQuery))

  #expect(result == expected)
}

@Test func preservesRawTripleQuotedBigQueryStrings() async throws {
  let sql = "SELECT R'''abc''', R'''line\nvalue''' FROM t"
  let expected = """
    SELECT
      R'''abc''',
      R'''line
    value'''
    FROM
      t
    """

  let result = try format(sql, options: FormatOptions(dialect: .bigQuery))

  #expect(result == expected)
}

@Test func preservesOracleBracketQuotedStrings() async throws {
  let sql = "SELECT q'[abc]' FROM dual"
  let expected = """
    SELECT
      q'[abc]'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesOracleBraceQuotedStrings() async throws {
  let sql = "SELECT q'{a''b}' FROM dual"
  let expected = """
    SELECT
      q'{a''b}'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesOraclePipeQuotedStrings() async throws {
  let sql = "SELECT q'|abc|' FROM dual"
  let expected = """
    SELECT
      q'|abc|'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesOracleParenthesisQuotedStrings() async throws {
  let sql = "SELECT q'(abc)' FROM dual"
  let expected = """
    SELECT
      q'(abc)'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesOracleAngleBracketQuotedStrings() async throws {
  let sql = "SELECT q'<abc>' FROM dual"
  let expected = """
    SELECT
      q'<abc>'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesOracleHashQuotedStrings() async throws {
  let sql = "SELECT q'#abc#' FROM dual"
  let expected = """
    SELECT
      q'#abc#'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesOracleBangQuotedStringsWithEscapedQuotes() async throws {
  let sql = "SELECT q'!a''b!' FROM dual"
  let expected = """
    SELECT
      q'!a''b!'
    FROM
      dual
    """

  let result = try format(sql, options: FormatOptions(dialect: .plSQL))

  #expect(result == expected)
}

@Test func preservesDoubleQuotedTokensInSelectLists() async throws {
  let sql = "SELECT \"string literal\" FROM users"
  let expected = """
    SELECT
      "string literal"
    FROM
      users
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsSimpleOverPartitionClauses() async throws {
  let sql = "SELECT sum(amount) OVER (PARTITION BY team) FROM payroll"
  let expected = """
    SELECT
      sum(amount) OVER(PARTITION BY team)
    FROM
      payroll
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func formatsWindowFunctionsWithOrderByInsideOver() async throws {
  let sql = "SELECT row_number() OVER (PARTITION BY team ORDER BY id) FROM payroll"
  let expected = """
    SELECT
      row_number() OVER(PARTITION BY team
    ORDER BY
      id)
    FROM
      payroll
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

@Test func preservesBlockCommentsAsStandaloneLines() async throws {
  let sql = "SELECT id FROM users /* active users */ WHERE active = 1"
  let expected = """
    SELECT
      id
    FROM
      users
    /* active users */
    WHERE
      active = 1
    """

  let result = try format(sql)

  #expect(result == expected)
}

@Test func preservesQuotedIdentifierStylesAroundDots() async throws {
  let sql = "SELECT \"a\".\"b\", `c`, [d] FROM [tbl]"
  let expected = """
    SELECT
      "a"."b",
      `c`,
      [d]
    FROM
      [tbl]
    """

  let result = try format(sql, options: FormatOptions(dialect: .standardSQL))

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

@Test func uppercasesAscAndDescInOrderByClauses() async throws {
  let sql = "SELECT foo FROM bar ORDER BY foo asc, zap desc"
  let expected = """
    SELECT
      foo
    FROM
      bar
    ORDER BY
      foo ASC,
      zap DESC
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

@Test func respectsFunctionCaseOption() async throws {
  let sql = "SELECT Concat(Trim(first_name), ' ', Trim(last_name)) FROM users"
  let expected = """
    SELECT
      CONCAT(TRIM(first_name),
      ' ',
      TRIM(last_name))
    FROM
      users
    """

  let result = try format(sql, options: FormatOptions(functionCase: .upper))

  #expect(result == expected)
}

@Test func respectsDataTypeCaseOption() async throws {
  let sql = "SELECT Cast(ssid AS Int), VarChar(20) FROM employee"
  let expected = """
    SELECT
      Cast(ssid AS INT),
      VARCHAR(20)
    FROM
      employee
    """

  let result = try format(sql, options: FormatOptions(dataTypeCase: .upper))

  #expect(result == expected)
}

@Test func respectsIdentifierCaseOption() async throws {
  let sql = "select count(a.Column1), a.Column2 as myCol from Table1 as a"
  let expected = """
    select
      count(A.COLUMN1),
      A.COLUMN2 as MYCOL
    from
      TABLE1 as A
    """

  let result = try format(sql, options: FormatOptions(identifierCase: .upper))

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
  let sql = "SELECT price + (product.original_price * product.sales_tax) AS total FROM product"
  let expected = """
    SELECT
      price + (product.original_price *
      product.sales_tax) AS total
    FROM
      product
    """

  let result = try format(sql, options: FormatOptions(expressionWidth: 40))

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
  let sql = "SELECT price + (product.original_price * product.sales_tax) AS total FROM product"
  let expected = """
    SELECT
      price + (product.original_price * product.sales_tax) AS total
    FROM
      product
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

@Test func paramTypesSupportQuestionMarkNumberedPlaceholders() async throws {
  let sql = "SELECT ?1 FROM users WHERE id = ?2"
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
      params: .named(["1": "name", "2": "42"]),
      paramTypes: ParamTypes(numbered: [.questionMark])
    )
  )

  #expect(result == expected)
}

@Test func paramTypesSupportCustomRegexPlaceholders() async throws {
  let sql = "SELECT __column__ FROM users WHERE id = __id__"
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
      params: .named(["column": "name", "id": "42"]),
      paramTypes: ParamTypes(
        custom: [
          CustomParameterType(
            regex: #"__[a-zA-Z_][a-zA-Z0-9_]*__"#,
            key: { text in
              String(text.dropFirst(2).dropLast(2))
            }
          )
        ]
      )
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
  #expect(options.functionCase == .preserve)
  #expect(options.dataTypeCase == .preserve)
  #expect(options.identifierCase == .preserve)
  #expect(options.logicalOperatorNewline == .before)
  #expect(options.linesBetweenQueries == 1)
  #expect(options.expressionWidth == 50)
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

@Test func canResolveBuiltInDialectsFromMixedCaseNames() async throws {
  #expect(DialectRegistry.dialect(named: "PostgreSQL") == .postgreSQL)
  #expect(DialectRegistry.dialect(named: "TRANSACTSQL") == .transactSQL)
  #expect(DialectRegistry.dialect(named: "BigQuery") == .bigQuery)
}

@Test func canResolveAliasDialectsFromMixedCaseNames() async throws {
  #expect(DialectRegistry.dialect(named: "POSTGRES") == .postgreSQL)
  #expect(DialectRegistry.dialect(named: "SingleStore") == .singleStoreDB)
  #expect(DialectRegistry.dialect(named: "TSQL") == .transactSQL)
}

@Test func canResolveCustomDialectByNameFromRegistry() async throws {
  let custom = createDialect(
    DialectOptions(
      name: "customsql",
      clauseKeywords: Dialect.standardSQL.clauseKeywords.union(["RETURNING"]),
      reservedWords: Dialect.standardSQL.reservedWords.union(["RETURNING"])
    )
  )

  #expect(DialectRegistry.dialect(named: "customsql", additionalDialects: [custom]) == custom)
  #expect(DialectRegistry.dialect(named: "CUSTOMSQL", additionalDialects: [custom]) == custom)
  #expect(DialectRegistry.dialect(named: "customsql") == nil)
}

@Test func canResolveMixedCaseCustomDialectNamesFromRegistry() async throws {
  let custom = createDialect(DialectOptions(name: "CustomPG"), base: .postgreSQL)

  #expect(DialectRegistry.dialect(named: "custompg", additionalDialects: [custom]) == custom)
  #expect(DialectRegistry.dialect(named: "CUSTOMPG", additionalDialects: [custom]) == custom)
}

@Test func registryNamesIncludeAdditionalDialects() async throws {
  let custom = createDialect(DialectOptions(name: "CustomPG"), base: .postgreSQL)

  let canonicalNames = DialectRegistry.canonicalNames(additionalDialects: [custom])
  let names = DialectRegistry.names(additionalDialects: [custom])

  #expect(canonicalNames.contains("custompg"))
  #expect(names.contains("custompg"))
  #expect(names.contains("postgres"))
  #expect(names.contains("tsql"))
}

@Test func canResolveCustomDialectAliasesFromRegistry() async throws {
  let custom = createDialect(DialectOptions(name: "CustomPG"), base: .postgreSQL)
  let aliases = ["pgx": "CustomPG"]

  #expect(
    DialectRegistry.dialect(
      named: "pgx",
      additionalDialects: [custom],
      additionalAliases: aliases
    ) == custom)
  #expect(
    DialectRegistry.dialect(
      named: "PGX",
      additionalDialects: [custom],
      additionalAliases: aliases
    ) == custom)
}

@Test func registryNamesIncludeAdditionalAliases() async throws {
  let custom = createDialect(DialectOptions(name: "CustomPG"), base: .postgreSQL)
  let names = DialectRegistry.names(
    additionalDialects: [custom],
    additionalAliases: ["pgx": "CustomPG"]
  )

  #expect(names.contains("custompg"))
  #expect(names.contains("pgx"))
}

@Test func customAliasesAreCaseInsensitiveForKeysAndTargets() async throws {
  let custom = createDialect(DialectOptions(name: "CustomPG"), base: .postgreSQL)

  let resolved = DialectRegistry.dialect(
    named: "pgx",
    additionalDialects: [custom],
    additionalAliases: ["PGX": "CUSTOMPG"]
  )

  #expect(resolved == custom)
}

@Test func builtInAliasesTakePrecedenceOverConflictingCustomAliases() async throws {
  let custom = createDialect(DialectOptions(name: "custom-postgres"), base: .postgreSQL)

  let resolved = DialectRegistry.dialect(
    named: "postgres",
    additionalDialects: [custom],
    additionalAliases: ["postgres": "custom-postgres"]
  )

  #expect(resolved == .postgreSQL)
}

@Test func formatDialectUsesExplicitDialectArgument() async throws {
  let sql = "select id from users returning id"
  let expected = """
    SELECT
      id
    FROM
      users
    RETURNING
      id
    """

  let options = FormatOptions(dialect: .standardSQL, keywordCase: .upper)
  let result = try formatDialect(sql, dialect: .postgreSQL, options: options)

  #expect(result == expected)
}

@Test func canFormatWithCustomDialectFromDialectOptions() async throws {
  let custom = createDialect(
    DialectOptions(
      name: "customsql",
      clauseKeywords: Dialect.standardSQL.clauseKeywords.union(["RETURNING"]),
      reservedWords: Dialect.standardSQL.reservedWords.union(["RETURNING"])
    )
  )

  let sql = "select id from users returning id"
  let expected = """
    SELECT
      id
    FROM
      users
    RETURNING
      id
    """

  let result = try formatDialect(sql, dialect: custom, options: FormatOptions(keywordCase: .upper))

  #expect(result == expected)
}

@Test func customDialectCanInheritFromPostgreSQLBase() async throws {
  let custom = createDialect(DialectOptions(name: "custompg"), base: .postgreSQL)

  let tokens = try Tokenizer(dialect: custom).tokenize("SELECT meta::jsonb || data")

  #expect(tokens.contains(where: { $0.text == "::" && $0.type == .operatorToken }))
  #expect(tokens.contains(where: { $0.text == "||" && $0.type == .operatorToken }))
}

@Test func customDialectWithPostgreSQLBaseFormatsReturningClause() async throws {
  let custom = createDialect(
    DialectOptions(name: "custompg"),
    base: .postgreSQL
  )

  let sql = "select id from users returning id"
  let expected = """
    SELECT
      id
    FROM
      users
    RETURNING
      id
    """

  let result = try formatDialect(sql, dialect: custom, options: FormatOptions(keywordCase: .upper))

  #expect(result == expected)
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
