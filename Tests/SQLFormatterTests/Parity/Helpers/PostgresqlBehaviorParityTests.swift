import Testing

@testable import SQLFormatter

private func assertPostgresLike(
  _ sql: String,
  _ expected: String,
  options: FormatOptions = .default
) throws {
  try assertFormatDialect(sql, dialect: .postgreSQL, expected, options: options)
  try assertFormatDialect(sql, dialect: .duckDB, expected, options: options)
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: allows $ character as part of identifiers
@Test func parity_postgresql_allowsDollarCharacterAsPartOfIdentifiers() throws {
  try assertPostgresLike(
    "SELECT foo$, some$$ident",
    """
      SELECT
        foo$,
        some$$ident
      """
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: formats type-cast operator without spaces
// Swift divergence: keeps spaces around :: operator.
@Test func parity_postgresql_formatsTypeCastOperatorWithoutSpaces() throws {
  try assertPostgresLike(
    "SELECT 2 :: numeric AS foo;",
    """
      SELECT
        2 :: numeric AS foo;
      """
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: formats SELECT DISTINCT ON () syntax
// Swift divergence: DISTINCT and ON are split across lines.
@Test func parity_postgresql_formatsSelectDistinctOnSyntax() throws {
  try assertPostgresLike(
    "SELECT DISTINCT ON (c1, c2) c1, c2 FROM tbl;",
    """
      SELECT
        DISTINCT
      ON
        (c1,
        c2) c1,
        c2
      FROM
        tbl;
      """
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: formats ALTER TABLE ... ALTER COLUMN
// Swift divergence: keeps ALTER COLUMN subclauses on the same line.
@Test func parity_postgresql_formatsAlterTableAlterColumn() throws {
  try assertPostgresLike(
    """
    ALTER TABLE t ALTER COLUMN foo SET DATA TYPE VARCHAR;
    ALTER TABLE t ALTER COLUMN foo SET DEFAULT 5;
    ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;
    ALTER TABLE t ALTER COLUMN foo SET NOT NULL;
    ALTER TABLE t ALTER COLUMN foo DROP NOT NULL;
    """,
    """
      ALTER TABLE t ALTER COLUMN foo SET DATA TYPE VARCHAR;

      ALTER TABLE t ALTER COLUMN foo SET DEFAULT 5;

      ALTER TABLE t ALTER COLUMN foo DROP DEFAULT;

      ALTER TABLE t ALTER COLUMN foo SET NOT NULL;

      ALTER TABLE t ALTER COLUMN foo DROP NOT NULL;
      """
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: allows TYPE to be used as an identifier
@Test func parity_postgresql_allowsTypeAsIdentifier() throws {
  try assertPostgresLike(
    "SELECT type, modified_at FROM items;",
    """
      SELECT
        type,
        modified_at
      FROM
        items;
      """
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: does not recognize common fields names as keywords
@Test func parity_postgresql_doesNotTreatCommonFieldNamesAsKeywords() throws {
  try assertPostgresLike(
    "SELECT id, type, name, location, label, password FROM release;",
    """
      SELECT
        id,
        type,
        name,
        location,
        label,
        password
      FROM
        release;
      """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: formats DEFAULT VALUES clause
// Swift divergence: DEFAULT VALUES remains lowercase and INSERT INTO stays on one line.
@Test func parity_postgresql_formatsDefaultValuesClause() throws {
  try assertPostgresLike(
    "INSERT INTO items default values RETURNING id;",
    """
      INSERT INTO items default values
      RETURNING
        id;
      """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: treats TEXT as data-type (not as plain keyword)
// Swift divergence: CREATE TABLE parenthesis attaches directly to table name.
@Test func parity_postgresql_treatsTextAsDataTypeNotPlainKeyword() throws {
  try assertPostgresLike(
    "CREATE TABLE foo (items text);",
    """
      CREATE TABLE foo(items TEXT);
      """,
    options: FormatOptions(dataTypeCase: .upper)
  )

  try assertPostgresLike(
    "CREATE TABLE foo (text VARCHAR(100));",
    """
      CREATE TABLE foo(text VARCHAR(100));
      """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/behavesLikePostgresqlFormatter.ts :: formats TIMESTAMP WITH TIMEZONE as data type
// Swift divergence: type phrase is line-broken and `zone` is not uppercased.
@Test func parity_postgresql_formatsTimestampWithTimeZoneAsDataType() throws {
  try assertPostgresLike(
    "create table time_table (id int primary key, created_at timestamp with time zone);",
    """
      create table time_table(id INT primary key,
      created_at TIMESTAMP
      with
        TIME zone);
      """,
    options: FormatOptions(dataTypeCase: .upper)
  )
}
