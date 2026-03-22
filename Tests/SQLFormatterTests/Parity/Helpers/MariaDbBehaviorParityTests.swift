import Testing

@testable import SQLFormatter

private func assertMariaLike(
  _ sql: String,
  _ expected: String,
  options: FormatOptions = .default
) throws {
  try assertFormatDialect(sql, dialect: .mariaDB, expected, options: options)
  try assertFormatDialect(sql, dialect: .mySQL, expected, options: options)
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: allows $ character as part of identifiers
@Test func parity_mariadb_allowsDollarCharacterAsPartOfIdentifiers() throws {
  try assertMariaLike(
    "SELECT $foo, some$$ident",
    """
    SELECT
      $foo,
      some$$ident
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports identifiers that start with numbers
@Test func parity_mariadb_supportsIdentifiersStartingWithNumbers() throws {
  try assertMariaLike(
    "SELECT 4four, 12345e, 12e45, $567 FROM tbl",
    """
    SELECT
      4four,
      12345e,
      12e45,
      $567
    FROM
      tbl
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports unicode identifiers that start with numbers
@Test func parity_mariadb_supportsUnicodeIdentifiersStartingWithNumbers() throws {
  try assertMariaLike(
    "SELECT 1ä FROM tbl",
    """
    SELECT
      1ä
    FROM
      tbl
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports @variables
@Test func parity_mariadb_supportsAtVariables() throws {
  try assertMariaLike(
    "SELECT @foo, @some_long.var$with$special.chars",
    """
    SELECT
      @foo,
      @some_long.var$with$special.chars
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports @`name` variables
// Swift divergence: formatter inserts a space between @ and backtick-quoted identifier.
@Test func parity_mariadb_supportsBacktickAtVariables() throws {
  try assertMariaLike(
    "SELECT @`baz zaz` FROM tbl;",
    """
    SELECT
      @ `baz zaz`
    FROM
      tbl;
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports setting variables: @var :=
// Swift divergence: tokenizer splits := into : =.
@Test func parity_mariadb_supportsSettingVariables() throws {
  try assertMariaLike(
    "SET @foo := 10;",
    """
    SET
      @foo : = 10;
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports @@ system variables
@Test func parity_mariadb_supportsDoubleAtSystemVariables() throws {
  try assertMariaLike(
    "SELECT @@GLOBAL.time, @@SYSTEM.date, @@hour FROM foo;",
    """
    SELECT
      @@GLOBAL.time,
      @@SYSTEM.date,
      @@hour
    FROM
      foo;
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports REPLACE INTO syntax
// Swift divergence: table name stays on REPLACE INTO line; tuple values are split per line.
@Test func parity_mariadb_supportsReplaceIntoSyntax() throws {
  try assertMariaLike(
    "REPLACE INTO tbl VALUES (1,'Leopard'),(2,'Dog');",
    """
    REPLACE INTO tbl
    VALUES
      (1,
      'Leopard'),
      (2,
      'Dog');
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports INSERT ... ON DUPLICATE KEY UPDATE
// Swift divergence: ON DUPLICATE KEY and UPDATE are broken onto separate lines.
@Test func parity_mariadb_supportsInsertOnDuplicateKeyUpdate() throws {
  try assertMariaLike(
    "INSERT INTO customer VALUES ('John','Doe') ON DUPLICATE KEY UPDATE fname='Untitled';",
    """
    INSERT INTO customer
    VALUES
      ('John',
      'Doe')
    ON
      DUPLICATE KEY
    UPDATE fname = 'Untitled';
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports INSERT ... ON DUPLICATE KEY UPDATE + VALUES() function
// Swift divergence: clause and VALUES() call are split across additional lines.
@Test func parity_mariadb_supportsInsertOnDuplicateKeyUpdateWithValuesFunction() throws {
  try assertMariaLike(
    "INSERT INTO customer VALUES ('John','Doe') ON DUPLICATE KEY UPDATE col=VALUES(col2);",
    """
    INSERT INTO customer
    VALUES
      ('John',
      'Doe')
    ON
      DUPLICATE KEY
    UPDATE col =
    VALUES
      (col2);
    """
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: uppercases only reserved keywords
// Swift divergence: CREATE/INSERT parenthesis spacing and INSERT column list wrapping differ.
@Test func parity_mariadb_uppercasesOnlyReservedKeywords() throws {
  try assertMariaLike(
    """
    create table account (id int comment 'the most important column');
    select * from mysql.user;
    insert into user (id, name) values (1, 'Blah');
    """,
    """
    CREATE TABLE account(id INT comment 'the most important column');

    SELECT
      *
    FROM
      mysql.user;

    INSERT INTO user(id,
    name)
    VALUES
      (1,
      'Blah');
    """,
    options: FormatOptions(keywordCase: .upper, dataTypeCase: .upper)
  )
}

// Upstream: test/behavesLikeMariaDbFormatter.ts :: supports *.* syntax in GRANT statement
// Swift divergence: GRANT ON/TO sections are line-broken and *.* is tokenized as *. *.
@Test func parity_mariadb_supportsStarDotStarGrantSyntax() throws {
  try assertMariaLike(
    "GRANT ALL ON *.* TO user2;",
    """
    GRANT ALL
    ON
      *. *
    TO
      user2;
    """
  )
}
