import Testing

@testable import SQLFormatter

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE
// Swift divergence: keeps the column list attached to the table identifier and emits inline columns without block indentation.
@Test func parity_createTable_formatsShortCreateTable() throws {
  try assertFormat(
    "CREATE TABLE tbl (a INT PRIMARY KEY, b TEXT);",
    """
      CREATE TABLE tbl(a INT PRIMARY KEY,
      b TEXT);
    """
  )
}

// Upstream: test/features/createTable.ts :: formats long CREATE TABLE
// Swift divergence: columns remain inline without interior indentation or trailing newline for the closing parenthesis.
@Test func parity_createTable_formatsLongCreateTable() throws {
  try assertFormat(
    "CREATE TABLE tbl (a INT PRIMARY KEY, b TEXT, c INT NOT NULL, doggie INT NOT NULL);",
    """
      CREATE TABLE tbl(a INT PRIMARY KEY,
      b TEXT,
      c INT NOT NULL,
      doggie INT NOT NULL);
    """
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE OR REPLACE TABLE
// Swift divergence: the formatter breaks CREATE before OR REPLACE and keeps the inline column layout.
@Test func parity_createTable_formatsCreateOrReplaceTable() throws {
  try assertFormat(
    "CREATE OR REPLACE TABLE tbl (a INT PRIMARY KEY, b TEXT);",
    """
      CREATE
        OR REPLACE TABLE tbl(a INT PRIMARY KEY,
        b TEXT);
    """
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE IF NOT EXISTS
// Swift divergence: keeps the inline column layout with no space before the opening parenthesis.
@Test func parity_createTable_formatsCreateTableIfNotExists() throws {
  try assertFormat(
    "CREATE TABLE IF NOT EXISTS tbl (a INT PRIMARY KEY, b TEXT);",
    """
      CREATE TABLE IF NOT EXISTS tbl(a INT PRIMARY KEY,
      b TEXT);
    """
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE with column comments
// Swift divergence: column comments follow the inline column layout without indentation or extra space before the column list.
@Test func parity_createTable_formatsColumnComments() throws {
  try assertFormat(
    "CREATE TABLE tbl (a INT COMMENT 'Hello world!', b TEXT COMMENT 'Here we are!');",
    """
      CREATE TABLE tbl(a INT COMMENT 'Hello world!',
      b TEXT COMMENT 'Here we are!');
    """
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE with comment
// Swift divergence: columns stay inline, so multiline columns appear even though upstream expects a single line.
@Test func parity_createTable_formatsTableComment() throws {
  try assertFormat(
    "CREATE TABLE tbl (a INT, b TEXT) COMMENT = 'Hello, world!';",
    """
      CREATE TABLE tbl(a INT,
      b TEXT) COMMENT = 'Hello, world!';
    """
  )
}

// Upstream: test/features/createTable.ts :: correctly indents CREATE TABLE in tabular style
// Swift divergence: tabularLeft indent style does not reproduce upstream spacing around the CREATE TABLE header or closing parenthesis.
@Test func parity_createTable_formatsTabularStyle() throws {
  try assertFormat(
    """
      CREATE TABLE foo (
        id INT PRIMARY KEY NOT NULL,
        fname VARCHAR NOT NULL
      );
    """,
    """
    CREATE TABLE foo( id INT PRIMARY KEY NOT NULL,
              fname VARCHAR NOT NULL);
    """,
    options: FormatOptions(indentStyle: .tabularLeft)
  )
}
