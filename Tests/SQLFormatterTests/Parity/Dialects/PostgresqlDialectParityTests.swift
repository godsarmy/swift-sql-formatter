import Testing

@testable import SQLFormatter

private let postgresDialect: Dialect = .postgreSQL

private func postgresOptions(
  keywordCase: KeywordCase = .preserve,
  dataTypeCase: KeywordCase = .preserve,
  functionCase: KeywordCase = .preserve
) -> FormatOptions {
  FormatOptions(
    keywordCase: keywordCase,
    functionCase: functionCase,
    dataTypeCase: dataTypeCase
  )
}

// Upstream: test/postgresql.test.ts :: supports array slice operator
// Swift divergence: formatter injects spaces around slice bounds.
@Test func parity_postgresql_supportsArraySliceOperator() throws {
  try assertFormatDialect(
    "SELECT foo[:5], bar[1:], baz[1:5], zap[:];",
    dialect: postgresDialect,
    dedent(
      """
      SELECT
        foo[ : 5],
        bar[1 : ],
        baz[1 : 5],
        zap[ : ];
      """
    )
  )
}

// Upstream: test/postgresql.test.ts :: formats empty SELECT
// Swift divergence: semicolon is emitted on its own line.
@Test func parity_postgresql_formatsEmptySelect() throws {
  try assertFormatDialect(
    "SELECT;",
    dialect: postgresDialect,
    dedent(
      """
      SELECT
      ;
      """
    )
  )
}

// Upstream: test/postgresql.test.ts :: formats TIMESTAMP WITH TIME ZONE syntax
// Swift divergence: type clauses distribute across lines and casing is preserved.
@Test func parity_postgresql_formatsTimestampWithTimeZoneSyntax() throws {
  try assertFormatDialect(
    "create table time_table (id int,\n          created_at timestamp without time zone,\n          deleted_at time with time zone,\n          modified_at timestamp(0) with time zone);",
    dialect: postgresDialect,
    dedent(
      """
      create table time_table(id INT,
      created_at TIMESTAMP without TIME zone,
      deleted_at TIME
      with
        TIME zone,
        modified_at TIMESTAMP(0)
      with
        TIME zone);
      """
    ),
    options: postgresOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/postgresql.test.ts :: formats FOR UPDATE clause
// Swift divergence: FOR UPDATE remains on the same line as the table reference.
@Test func parity_postgresql_formatsForUpdateClause() throws {
  try assertFormatDialect(
    "SELECT * FROM tbl FOR UPDATE;\n        SELECT * FROM tbl FOR UPDATE OF tbl.salary;",
    dialect: postgresDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl FOR UPDATE;

      SELECT
        *
      FROM
        tbl FOR UPDATE OF tbl.salary;
      """
    )
  )
}

// Upstream: test/postgresql.test.ts :: supports OPERATOR() syntax
// Swift divergence: spacing around dot-qualified operators and parentheses differs.
@Test func parity_postgresql_supportsOperatorSyntax() throws {
  try assertFormatDialect(
    "SELECT foo OPERATOR(public.===) bar;",
    dialect: postgresDialect,
    dedent(
      """
      SELECT
        foo OPERATOR(public. ===) bar;
      """
    )
  )

  try assertFormatDialect(
    "SELECT foo operator ( !== ) bar;",
    dialect: postgresDialect,
    dedent(
      """
      SELECT
        foo operator( !==) bar;
      """
    )
  )
}

// Upstream: test/postgresql.test.ts :: supports OR REPLACE in CREATE FUNCTION
// Swift divergence: keywords break onto separate lines and spacing before parentheses is trimmed.
@Test func parity_postgresql_supportsOrReplaceInCreateFunction() throws {
  try assertFormatDialect(
    "CREATE OR REPLACE FUNCTION foo ();",
    dialect: postgresDialect,
    dedent(
      """
      CREATE
      OR REPLACE FUNCTION foo();
      """
    )
  )
}

// Upstream: test/postgresql.test.ts :: formats JSON and JSONB data types
// Swift divergence: parentheses remain adjacent and keywords retain lowercase.
@Test func parity_postgresql_formatsJsonDataTypes() throws {
  try assertFormatDialect(
    "CREATE TABLE foo (bar json, baz jsonb);",
    dialect: postgresDialect,
    dedent(
      """
      CREATE TABLE foo(bar json,
      baz jsonb);
      """
    ),
    options: postgresOptions(dataTypeCase: .upper, functionCase: .lower)
  )
}

// Upstream: test/postgresql.test.ts :: supports OR REPLACE in CREATE PROCEDURE
// Swift divergence: keywords split across lines and spacing around parentheses is removed.
@Test func parity_postgresql_supportsOrReplaceInCreateProcedure() throws {
  try assertFormatDialect(
    "CREATE OR REPLACE PROCEDURE foo () LANGUAGE sql AS $$ BEGIN END $$;",
    dialect: postgresDialect,
    dedent(
      """
      CREATE
      OR REPLACE PROCEDURE foo() LANGUAGE sql AS $$ BEGIN END $$;
      """
    )
  )
}

// Upstream: test/postgresql.test.ts :: supports UUID type and functions
// Swift divergence: parentheses attach to the table name without additional spacing.
@Test func parity_postgresql_supportsUuidTypeAndFunctions() throws {
  try assertFormatDialect(
    "CREATE TABLE foo (id uuid DEFAULT Gen_Random_Uuid());",
    dialect: postgresDialect,
    dedent(
      """
      CREATE TABLE foo(id UUID DEFAULT gen_random_uuid());
      """
    ),
    options: postgresOptions(dataTypeCase: .upper, functionCase: .lower)
  )
}

// Upstream: test/postgresql.test.ts :: formats keywords in COMMENT ON
// Swift divergence: keywords lowercased and each keyword sits on its own line.
@Test func parity_postgresql_formatsCommentOnKeywords() throws {
  try assertFormatDialect(
    "comment on table foo is 'Hello my table';",
    dialect: postgresDialect,
    dedent(
      """
      comment
      ON
        table foo is 'Hello my table';
      """
    ),
    options: postgresOptions(keywordCase: .upper)
  )
}
