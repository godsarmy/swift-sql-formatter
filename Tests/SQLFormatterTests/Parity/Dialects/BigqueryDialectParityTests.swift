import Testing

@testable import SQLFormatter

private let bigqueryDialect: Dialect = .bigQuery

// Upstream: test/bigquery.test.ts :: supports dashes inside identifiers
// Swift divergence: Swift splits dashed identifiers around '-' and even breaks the `where` token onto its own line.
@Test func parity_bigquery_formatsDashesInsideIdentifiers() throws {
  try assertFormatDialect(
    "SELECT alpha-foo, where-long-identifier\nFROM beta",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        alpha - foo,
      where
        - long - identifier
      FROM
        beta
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports @@variables
// Swift divergence: None – output matches upstream behavior.
@Test func parity_bigquery_formatsAtAtVariables() throws {
  try assertFormatDialect(
    "SELECT @@error.message, @@time_zone",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        @@error.message,
        @@time_zone
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports strings with rb prefixes
// Swift divergence: Swift inserts whitespace between the prefix and the literal contents.
@Test func parity_bigquery_formatsRbPrefixedStrings() throws {
  try assertFormatDialect(
    "SELECT rb\"huh\", br'bulu bulu', BR'la la' FROM foo",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        rb "huh",
        br 'bulu bulu',
        BR 'la la'
      FROM
        foo
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports triple-quoted strings
// Swift divergence: Swift still cannot parse triple-quoted strings and raises unterminatedQuotedToken.
@Test func parity_bigquery_formatsTripleQuotedStrings() throws {
  let sql = #"""SELECT '''hello 'my' world''', """hello "my" world""", """\"quoted\""" FROM foo"""#

  do {
    _ = try formatDialect(sql, dialect: bigqueryDialect)
    Issue.record("Expected parse to fail for triple-quoted strings")
  } catch FormatError.unterminatedQuotedToken {
    // Expected divergence.
  } catch {
    Issue.record("Expected FormatError.unterminatedQuotedToken, got \(error)")
  }
}

// Upstream: test/bigquery.test.ts :: supports strings with r, b and rb prefixes with triple-quoted strings
// Swift divergence: Swift rejects triple-quoted strings that contain unescaped quotes and throws unterminatedQuotedToken.
@Test func parity_bigquery_rejectsTripleQuotedStringsWithNestedQuotes() throws {
  let sql =
    #"""SELECT R'''blah''', B'''sah''', rb"""hu"h""", br'''bulu bulu''', r"""haha""", BR'''la' la''' FROM foo"""#

  do {
    _ = try formatDialect(sql, dialect: bigqueryDialect)
    Issue.record("Expected parse to fail for nested triple-quoted strings")
  } catch FormatError.unterminatedQuotedToken {
    // Expected divergence.
  } catch {
    Issue.record("Expected FormatError.unterminatedQuotedToken, got \(error)")
  }
}

// Upstream: test/bigquery.test.ts :: supports STRUCT types
// Swift divergence: Swift breaks the ARRAY literal onto separate lines and keeps the STRUCT arguments split.
@Test func parity_bigquery_formatsStructTypes() throws {
  try assertFormatDialect(
    "SELECT STRUCT(\"Alpha\" as name, [23.4, 26.3, 26.4] as splits) FROM beta",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        STRUCT("Alpha" as name,
        [23.4,
        26.3,
        26.4] as splits)
      FROM
        beta
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports parametric ARRAY
// Swift divergence: Swift adds spacing around '<' and '>' in type parameters.
@Test func parity_bigquery_formatsParametricArray() throws {
  try assertFormatDialect(
    "SELECT ARRAY<FLOAT>[1]",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        ARRAY < FLOAT > [1]
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: STRUCT and ARRAY type case is affected by dataTypeCase option
// Swift divergence: Swift still lowercases the identifier and inserts spaces around type parameters even when dataTypeCase is upper.
@Test func parity_bigquery_respectsDataTypeCaseForParametricTypes() throws {
  try assertFormatDialect(
    "SELECT array<struct<y int64, z string>>[(1, \"foo\")]",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        array < struct < y int64,
        z string >> [(1,
        "foo") ]
      """#
    ),
    options: FormatOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/bigquery.test.ts :: supports parametric STRUCT
// Swift divergence: Swift spaces out the type parameters and pushes the parameter list to new lines.
@Test func parity_bigquery_formatsParametricStruct() throws {
  try assertFormatDialect(
    "SELECT STRUCT<ARRAY<INT64>>([])",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        STRUCT < ARRAY < INT64 >> ([])
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports parametric STRUCT with named fields
// Swift divergence: Swift breaks the STRUCT args and ARRAY literal across multiple lines and adds spacing around '<' and '>'.
@Test func parity_bigquery_formatsParametricStructWithNamedFields() throws {
  try assertFormatDialect(
    "SELECT STRUCT<y INT64, z STRING>(1,\"foo\"), STRUCT<arr ARRAY<INT64>>([1,2,3]);",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        STRUCT < y INT64,
        z STRING > (1,
        "foo"),
        STRUCT < arr ARRAY < INT64 >> ([1,
        2,
        3]);
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports uppercasing of STRUCT
// Swift divergence: Swift keeps the struct identifier lowercase and still breaks parameters across lines even with keywordCase upper.
@Test func parity_bigquery_formatsStructUppercased() throws {
  try assertFormatDialect(
    "select struct<Nr int64, myName string>(1,\"foo\");",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        struct < Nr int64,
        myName string > (1,
        "foo");
      """#
    ),
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/bigquery.test.ts :: does not support lowercasing of STRUCT
// Swift divergence: STRUCT remains uppercase and arguments still split even when keywords are lowercased.
@Test func parity_bigquery_preservesStructCaseWhenLowercasingKeywords() throws {
  try assertFormatDialect(
    "SELECT STRUCT<Nr INT64, myName STRING>(1,\"foo\");",
    dialect: bigqueryDialect,
    dedent(
      #"""
      select
        STRUCT < Nr INT64,
        myName STRING > (1,
        "foo");
      """#
    ),
    options: FormatOptions(keywordCase: .lower)
  )
}

// Upstream: test/bigquery.test.ts :: supports QUALIFY clause
// Swift divergence: Swift keeps the QUALIFY condition alongside the WHERE clause and keeps the OVER clause more compact.
@Test func parity_bigquery_formatsQualifyClause() throws {
  try assertFormatDialect(
    """
    SELECT
      item,
      RANK() OVER (PARTITION BY category ORDER BY purchases DESC) AS rank
    FROM Produce
    WHERE Produce.category = 'vegetable'
    QUALIFY rank <= 3
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        item,
        RANK() OVER(PARTITION BY category
      ORDER BY
        purchases DESC) AS rank
      FROM
        Produce
      WHERE
        Produce.category = 'vegetable' QUALIFY rank <= 3
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports parameterised types
// Swift divergence: Swift inserts line breaks inside the numeric precision parentheses and keeps everything on the same line per declaration.
@Test func parity_bigquery_formatsParameterizedTypesDeclarations() throws {
  try assertFormatDialect(
    """
    DECLARE varString STRING(11) '11charswide';
    DECLARE varBytes BYTES(8);
    DECLARE varNumeric NUMERIC(1, 1);
    DECLARE varDecimal DECIMAL(1, 1);
    DECLARE varBignumeric BIGNUMERIC(1, 1);
    DECLARE varBigdecimal BIGDECIMAL(1, 1);
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      DECLARE varString STRING(11) '11charswide';
      DECLARE varBytes BYTES(8);
      DECLARE varNumeric NUMERIC(1,
      1);
      DECLARE varDecimal DECIMAL(1,
      1);
      DECLARE varBignumeric BIGNUMERIC(1,
      1);
      DECLARE varBigdecimal BIGDECIMAL(1,
      1);
      """#
    ),
    options: FormatOptions(linesBetweenQueries: 0)
  )
}

// Upstream: test/bigquery.test.ts :: supports array subscript operator
// Swift divergence: Swift leaves a trailing space before each closing bracket in the subscript literals.
@Test func parity_bigquery_formatsArraySubscriptOperator() throws {
  try assertFormatDialect(
    """
    SELECT item_array[OFFSET(1)] AS item_offset,
    item_array[ORDINAL(1)] AS item_ordinal,
    item_array[SAFE_OFFSET(6)] AS item_safe_offset,
    item_array[SAFE_ORDINAL(6)] AS item_safe_ordinal
    FROM Items;
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        item_array[OFFSET(1) ] AS item_offset,
        item_array[ORDINAL(1) ] AS item_ordinal,
        item_array[SAFE_OFFSET(6) ] AS item_safe_offset,
        item_array[SAFE_ORDINAL(6) ] AS item_safe_ordinal
      FROM
        Items;
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports named arguments
// Swift divergence: Swift puts each named argument on its own line.
@Test func parity_bigquery_formatsNamedArguments() throws {
  try assertFormatDialect(
    """
    SELECT MAKE_INTERVAL(1, day=>2, minute => 3)
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        MAKE_INTERVAL(1,
        day => 2,
        minute => 3)
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports FROM clause operators: UNNEST
// Swift divergence: Swift breaks the array literal and places it on the next line without indentation.
@Test func parity_bigquery_formatsUnnestOperator() throws {
  try assertFormatDialect(
    "SELECT * FROM UNNEST ([1, 2, 3]);",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        *
      FROM
        UNNEST([1,
        2,
        3]);
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports FROM clause operators: PIVOT
// Swift divergence: Swift compacts the PIVOT clause and squeezes the IN list onto the same indentation level.
@Test func parity_bigquery_formatsPivotOperator() throws {
  try assertFormatDialect(
    "SELECT * FROM Produce PIVOT(sales FOR quarter IN (Q1, Q2, Q3, Q4));",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        *
      FROM
        Produce PIVOT(sales FOR quarter IN(Q1,
        Q2,
        Q3,
        Q4));
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports FROM clause operators: UNPIVOT
// Swift divergence: Swift compacts the UNPIVOT clause in the same way it compacts PIVOT.
@Test func parity_bigquery_formatsUnpivotOperator() throws {
  try assertFormatDialect(
    "SELECT * FROM Produce UNPIVOT(sales FOR quarter IN (Q1, Q2, Q3, Q4));",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        *
      FROM
        Produce UNPIVOT(sales FOR quarter IN(Q1,
        Q2,
        Q3,
        Q4));
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports FROM clause operators: TABLESAMPLE SYSTEM
// Swift divergence: The TABLESAMPLE SYSTEM clause sticks to the same line as FROM and removes the space before the parentheses.
@Test func parity_bigquery_formatsTablesampleSystemOperator() throws {
  try assertFormatDialect(
    "SELECT * FROM dataset.my_table TABLESAMPLE SYSTEM (10 PERCENT);",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        *
      FROM
        dataset.my_table TABLESAMPLE SYSTEM(10 PERCENT);
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: supports trailing comma in SELECT clause
// Swift divergence: None – Swift already matches upstream formatting.
@Test func parity_bigquery_formatsSelectWithTrailingComma() throws {
  try assertFormatDialect(
    "SELECT foo, bar, FROM tbl;",
    dialect: bigqueryDialect,
    dedent(
      #"""
      SELECT
        foo,
        bar,
      FROM
        tbl;
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE SCHEMA
// Swift divergence: Swift collapses the CREATE keyword into one column and keeps OPTIONS on the same line as COLLATE.
@Test func parity_bigquery_formatsCreateSchema() throws {
  try assertFormatDialect(
    """
    CREATE SCHEMA mydataset
      DEFAULT COLLATE 'und:ci'
      OPTIONS(
        location="us", labels=[("label1","value1"),("label2","value2")])
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        SCHEMA mydataset DEFAULT COLLATE 'und:ci' OPTIONS(
        location = "us",
        labels = [("label1",
        "value1"),
        ("label2",
        "value2") ])
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE EXTERNAL TABLE ... WITH PARTITION COLUMN
// Swift divergence: Swift pushes PARTITION COLUMNS and OPTIONS onto new lines with compact argument lists.
@Test func parity_bigquery_formatsCreateExternalTableWithPartitionColumns() throws {
  try assertFormatDialect(
    """
    CREATE EXTERNAL TABLE dataset.CsvTable
    WITH PARTITION COLUMNS (
      field_1 STRING,
      field_2 INT64
    )
    OPTIONS(
      format = 'CSV',
      uris = ['gs://bucket/path1.csv']
    )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        EXTERNAL TABLE dataset.CsvTable
      WITH
        PARTITION COLUMNS( field_1 STRING,
        field_2 INT64) OPTIONS( format = 'CSV',
        uris = [ 'gs://bucket/path1.csv' ])
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE FUNCTION
// Swift divergence: Swift keeps FUNCTION arguments on new lines and keeps AS on the same line.
@Test func parity_bigquery_formatsCreateFunction() throws {
  try assertFormatDialect(
    """
    CREATE FUNCTION mydataset.myFunc(x FLOAT64, y FLOAT64)
    RETURNS FLOAT64
    AS (x * y);
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        FUNCTION mydataset.myFunc(x FLOAT64,
        y FLOAT64) RETURNS FLOAT64 AS (x * y);
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE FUNCTION - LANGUAGE js
// Swift divergence: Swift moves the LANGUAGE and AS clauses onto the same line and inserts a space between the r prefix and the string.
@Test func parity_bigquery_formatsCreateFunctionLanguageJs() throws {
  try assertFormatDialect(
    #"""
    CREATE FUNCTION myFunc(x FLOAT64, y FLOAT64)
    RETURNS FLOAT64
    LANGUAGE js
    AS r"""
        return x*y;
      """;
    """#,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        FUNCTION myFunc(x FLOAT64,
        y FLOAT64) RETURNS FLOAT64 LANGUAGE js AS r """
          return x*y;
        """;
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE TABLE FUNCTION
// Swift divergence: Swift keeps the RETURNS TABLE declaration on the same line and pushes the SELECT body down two lines without indentation.
@Test func parity_bigquery_formatsCreateTableFunction() throws {
  try assertFormatDialect(
    """
    CREATE TABLE FUNCTION mydataset.names_by_year(y INT64)
    RETURNS TABLE<name STRING, year INT64>
    AS (
      SELECT year, name
      FROM mydataset.mytable
      WHERE year = y
    )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE TABLE FUNCTION mydataset.names_by_year(y INT64) RETURNS TABLE < name STRING,
      year INT64 > AS (
      SELECT
        year,
        name
      FROM
        mydataset.mytable
      WHERE
        year = y)
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE PROCEDURE
// Swift divergence: Swift opens the BEGIN/END block inline with the CREATE PROCEDURE header and breaks the inner SELECT onto new lines.
@Test func parity_bigquery_formatsCreateProcedure() throws {
  try assertFormatDialect(
    """
    CREATE PROCEDURE myDataset.QueryTable()
    BEGIN
      SELECT * FROM anotherDataset.myTable;
    END;
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        PROCEDURE myDataset.QueryTable() BEGIN
      SELECT
        *
      FROM
        anotherDataset.myTable;

      END;
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE ROW ACCESS POLICY
// Swift divergence: Swift keeps GRANT and FILTER clauses on the same line as the preceding keywords.
@Test func parity_bigquery_formatsCreateRowAccessPolicy() throws {
  try assertFormatDialect(
    """
    CREATE ROW ACCESS POLICY us_filter
    ON mydataset.table1
    GRANT TO (\"group:abc@example.com\", \"user:hello@example.com\")
    FILTER USING (Region=\"US\")
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        ROW ACCESS POLICY us_filter
      ON
        mydataset.table1 GRANT TO(
        "group:abc@example.com",
        "user:hello@example.com") FILTER USING (Region =
        "US")
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE CAPACITY / RESERVATION / ASSIGNMENT
// Swift divergence: Swift inserts spaces around hyphens and inside the JSON literal.
@Test func parity_bigquery_formatsCreateCapacity() throws {
  try assertFormatDialect(
    #"""
    CREATE CAPACITY admin_project.region-us.my-commitment
    AS JSON """{
        "slot_count": 100,
        "plan": "FLEX"
      }"""
    """#,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        CAPACITY admin_project.region - us.my - commitment AS JSON """{
          " slot_count ": 100,
          " plan ": " FLEX "
        }"""
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE CAPACITY / RESERVATION / ASSIGNMENT
// Swift divergence: Same spacing divergence as CREATE CAPACITY.
@Test func parity_bigquery_formatsCreateReservation() throws {
  try assertFormatDialect(
    #"""
    CREATE RESERVATION admin_project.region-us.my-commitment
    AS JSON """{
        "slot_count": 100,
        "plan": "FLEX"
      }"""
    """#,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        RESERVATION admin_project.region - us.my - commitment AS JSON """{
          " slot_count ": 100,
          " plan ": " FLEX "
        }"""
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE CAPACITY / RESERVATION / ASSIGNMENT
// Swift divergence: Same spacing divergence as CREATE CAPACITY.
@Test func parity_bigquery_formatsCreateAssignment() throws {
  try assertFormatDialect(
    #"""
    CREATE ASSIGNMENT admin_project.region-us.my-commitment
    AS JSON """{
        "slot_count": 100,
        "plan": "FLEX"
      }"""
    """#,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        ASSIGNMENT admin_project.region - us.my - commitment AS JSON """{
          " slot_count ": 100,
          " plan ": " FLEX "
        }"""
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports CREATE SEARCH INDEX
// Swift divergence: Swift keeps the ON clause on its own line but otherwise matches.
@Test func parity_bigquery_formatsCreateSearchIndex() throws {
  try assertFormatDialect(
    """
    CREATE SEARCH INDEX my_index
    ON dataset.my_table(ALL COLUMNS);
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      CREATE
        SEARCH INDEX my_index
      ON
        dataset.my_table(ALL COLUMNS);
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER SCHEMA - SET DEFAULT COLLATE
// Swift divergence: Swift splits SET onto its own line but otherwise keeps the clause together.
@Test func parity_bigquery_formatsAlterSchemaSetDefaultCollate() throws {
  try assertFormatDialect(
    """
    ALTER SCHEMA mydataset
    SET DEFAULT COLLATE 'und:ci'
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER SCHEMA mydataset
      SET
        DEFAULT COLLATE 'und:ci'
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER SCHEMA - SET OPTIONS
// Swift divergence: Swift places the opening parenthesis on the same line as OPTIONS and keeps the assignment compact.
@Test func parity_bigquery_formatsAlterSchemaSetOptions() throws {
  try assertFormatDialect(
    """
    ALTER SCHEMA mydataset
    SET OPTIONS(
      default_table_expiration_days=3.75
      )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER SCHEMA mydataset
      SET
        OPTIONS( default_table_expiration_days = 3.75)
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER TABLE - SET OPTIONS
// Swift divergence: Swift keeps the CALL to TIMESTAMP_ADD on the same line by wrapping arguments across multiple lines.
@Test func parity_bigquery_formatsAlterTableSetOptions() throws {
  try assertFormatDialect(
    """
    ALTER TABLE mydataset.mytable
    SET OPTIONS(
      expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
    )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER TABLE mydataset.mytable
      SET
        OPTIONS( expiration_timestamp = TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL 7 DAY))
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER TABLE - SET DEFAULT COLLATE
// Swift divergence: Swift behaves the same as ALTER SCHEMA but for tables.
@Test func parity_bigquery_formatsAlterTableSetDefaultCollate() throws {
  try assertFormatDialect(
    """
    ALTER TABLE mydataset.mytable
    SET DEFAULT COLLATE 'und:ci'
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER TABLE mydataset.mytable
      SET
        DEFAULT COLLATE 'und:ci'
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER COLUMN - SET OPTIONS
// Swift divergence: Swift keeps ALTER COLUMN together with the table name and keeps the OPTIONS line compact.
@Test func parity_bigquery_formatsAlterColumnSetOptions() throws {
  try assertFormatDialect(
    """
    ALTER TABLE mydataset.mytable
    ALTER COLUMN price
    SET OPTIONS (
      description="Price per unit"
    )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER TABLE mydataset.mytable ALTER COLUMN price
      SET
        OPTIONS( description = "Price per unit")
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER COLUMN - DROP NOT NULL
// Swift divergence: Swift keeps the whole statement on one line.
@Test func parity_bigquery_formatsAlterColumnDropNotNull() throws {
  try assertFormatDialect(
    """
    ALTER TABLE mydataset.mytable
    ALTER COLUMN price
    DROP NOT NULL
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER TABLE mydataset.mytable ALTER COLUMN price DROP NOT NULL
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER COLUMN - SET DATA TYPE
// Swift divergence: Swift keeps DATA TYPE indented beneath SET.
@Test func parity_bigquery_formatsAlterColumnSetDataType() throws {
  try assertFormatDialect(
    """
    ALTER TABLE mydataset.mytable
    ALTER COLUMN price
    SET DATA TYPE NUMERIC
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER TABLE mydataset.mytable ALTER COLUMN price
      SET
        DATA TYPE NUMERIC
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER VIEW - SET OPTIONS
// Swift divergence: Swift mirrors the ALTER TABLE options formatting when dealing with views.
@Test func parity_bigquery_formatsAlterViewSetOptions() throws {
  try assertFormatDialect(
    """
    ALTER VIEW mydataset.myview
    SET OPTIONS (
      expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
    )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER VIEW mydataset.myview
      SET
        OPTIONS( expiration_timestamp = TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL 7 DAY))
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports ALTER BI_CAPACITY - SET OPTIONS
// Swift divergence: Swift inserts spaces around hyphens in the BI_CAPACITY name and keeps OPTIONS compact.
@Test func parity_bigquery_formatsAlterBiCapacitySetOptions() throws {
  try assertFormatDialect(
    """
    ALTER BI_CAPACITY my-project.region-us.default
    SET OPTIONS(
      size_gb = 250
    )
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      ALTER BI_CAPACITY my - project.region - us.default
      SET
        OPTIONS( size_gb = 250)
      """#
    )
  )
}

// Upstream: test/bigquery.test.ts :: Supports DROP clauses
// Swift divergence: Swift breaks ON clauses onto their own lines starting with the ON keyword.
@Test func parity_bigquery_formatsDropClauses() throws {
  try assertFormatDialect(
    """
    DROP SCHEMA mydataset.name;
    DROP VIEW mydataset.name;
    DROP FUNCTION mydataset.name;
    DROP TABLE FUNCTION mydataset.name;
    DROP PROCEDURE mydataset.name;
    DROP RESERVATION mydataset.name;
    DROP ASSIGNMENT mydataset.name;
    DROP SEARCH INDEX index2 ON mydataset.mytable;
    DROP mypolicy ON mydataset.mytable;
    DROP ALL ROW ACCESS POLICIES ON table_name;
    """,
    dialect: bigqueryDialect,
    dedent(
      #"""
      DROP SCHEMA mydataset.name;
      DROP VIEW mydataset.name;
      DROP FUNCTION mydataset.name;
      DROP TABLE FUNCTION mydataset.name;
      DROP PROCEDURE mydataset.name;
      DROP RESERVATION mydataset.name;
      DROP ASSIGNMENT mydataset.name;
      DROP SEARCH INDEX index2
      ON
        mydataset.mytable;
      DROP mypolicy
      ON
        mydataset.mytable;
      DROP ALL ROW ACCESS POLICIES
      ON
        table_name;
      """#
    ),
    options: FormatOptions(linesBetweenQueries: 0)
  )
}
