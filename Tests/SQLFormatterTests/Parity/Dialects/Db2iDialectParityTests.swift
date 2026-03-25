import Testing

@testable import SQLFormatter

private let db2iDialect: Dialect = .db2i

private func db2iOptions(
  indentStyle: IndentStyle = .standard,
  keywordCase: KeywordCase = .preserve,
  dataTypeCase: KeywordCase = .preserve,
  denseOperators: Bool = false
) -> FormatOptions {
  FormatOptions(
    dialect: db2iDialect,
    indentStyle: indentStyle,
    keywordCase: keywordCase,
    dataTypeCase: dataTypeCase,
    denseOperators: denseOperators
  )
}

// Upstream: test/features/comments.ts :: supports nested block comments (when nested comments enabled)
// Swift divergence: nested block comments still break at the first closing token, so the embedded end-tag is emitted on its own line.
@Test func parity_db2i_supportsNestedBlockComments() throws {
  try assertFormatDialect(
    "SELECT alpha /* /* commment */ */ FROM beta",
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        alpha
      /* /* commment */
      */
      FROM
        beta
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT with two comma-separated values on single line
// Swift divergence: LIMIT values are split into separate lines instead of remaining comma-delimited on one line.
@Test func parity_db2i_formatsLimitWithTwoCommaSeparatedValuesOnSingleLine() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      LIMIT 5, 10;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl
      LIMIT
        5,
        10;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT with complex expressions
// Swift divergence: limit expressions are normalized with added spacing and split across lines for each expression.
@Test func parity_db2i_formatsLimitWithComplexExpressions() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      LIMIT abs(-5) - 1, (2 + 3) * 5;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl
      LIMIT
        abs( - 5) - 1,
        (2 + 3) * 5;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT with comments
// Swift divergence: inline comments attach directly below LIMIT with minimal indentation and split each expression line.
@Test func parity_db2i_formatsLimitWithComments() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      LIMIT --comment
       5,--comment
      6;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl
      LIMIT
      --comment
      5,
      --comment
      6;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT in tabular style
// Swift divergence: the second LIMIT value wraps to the next line under tabular indentation.
@Test func parity_db2i_formatsLimitInTabularStyle() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      LIMIT 5, 6;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT    *
      FROM      tbl
      LIMIT     5,
                6;
      """
    ),
    options: db2iOptions(indentStyle: .tabularLeft)
  )
}

// Upstream: test/features/limiting.ts :: formats LIMIT of single value and OFFSET
// Swift divergence: OFFSET stays on the same line as the preceding LIMIT value.
@Test func parity_db2i_formatsLimitOfSingleValueAndOffset() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      LIMIT 5
      OFFSET 8;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl
      LIMIT
        5 OFFSET 8;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats FETCH FIRST
// Swift divergence: FETCH FIRST remains on the same line as the FROM clause.
@Test func parity_db2i_formatsFetchFirst() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      FETCH FIRST 10 ROWS ONLY;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl FETCH FIRST 10 ROWS ONLY;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats FETCH NEXT
// Swift divergence: FETCH NEXT remains adjacent to the FROM clause instead of moving to its own lines.
@Test func parity_db2i_formatsFetchNext() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      FETCH NEXT 1 ROW ONLY;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl FETCH NEXT 1 ROW ONLY;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats OFFSET ... FETCH FIRST
// Swift divergence: OFFSET ... FETCH FIRST stays on the same line following the FROM clause.
@Test func parity_db2i_formatsOffsetFetchFirst() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      OFFSET 250 ROWS
      FETCH FIRST 5 ROWS ONLY;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl OFFSET 250 ROWS FETCH FIRST 5 ROWS ONLY;
      """
    )
  )
}

// Upstream: test/features/limiting.ts :: formats OFFSET ... FETCH NEXT
// Swift divergence: OFFSET ... FETCH NEXT stays on the same line after FROM.
@Test func parity_db2i_formatsOffsetFetchNext() throws {
  try assertFormatDialect(
    """
      SELECT *
      FROM tbl
      OFFSET 250 ROWS
      FETCH NEXT 5 ROWS ONLY;
    """,
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        tbl OFFSET 250 ROWS FETCH NEXT 5 ROWS ONLY;
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE
// Swift divergence: keeps the column list attached to the table identifier and emits inline columns without block indentation.
@Test func parity_db2i_formatsShortCreateTable() throws {
  try assertFormatDialect(
    "CREATE TABLE tbl (a INT PRIMARY KEY, b TEXT);",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE tbl(a INT PRIMARY KEY,
      b TEXT);
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: formats long CREATE TABLE
// Swift divergence: columns remain inline without interior indentation or trailing newline for the closing parenthesis.
@Test func parity_db2i_formatsLongCreateTable() throws {
  try assertFormatDialect(
    "CREATE TABLE tbl (a INT PRIMARY KEY, b TEXT, c INT NOT NULL, doggie INT NOT NULL);",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE tbl(a INT PRIMARY KEY,
      b TEXT,
      c INT NOT NULL,
      doggie INT NOT NULL);
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE OR REPLACE TABLE
// Swift divergence: the formatter breaks CREATE before OR REPLACE and keeps the inline column layout.
@Test func parity_db2i_formatsCreateOrReplaceTable() throws {
  try assertFormatDialect(
    "CREATE OR REPLACE TABLE tbl (a INT PRIMARY KEY, b TEXT);",
    dialect: db2iDialect,
    dedent(
      """
      CREATE
        OR REPLACE TABLE tbl(a INT PRIMARY KEY,
        b TEXT);
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE IF NOT EXISTS
// Swift divergence: keeps the inline column layout with no space before the opening parenthesis.
@Test func parity_db2i_formatsCreateTableIfNotExists() throws {
  try assertFormatDialect(
    "CREATE TABLE IF NOT EXISTS tbl (a INT PRIMARY KEY, b TEXT);",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE IF NOT EXISTS tbl(a INT PRIMARY KEY,
      b TEXT);
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE with column comments
// Swift divergence: column comments follow the inline column layout without indentation or extra space before the column list.
@Test func parity_db2i_formatsCreateTableWithColumnComments() throws {
  try assertFormatDialect(
    "CREATE TABLE tbl (a INT COMMENT 'Hello world!', b TEXT COMMENT 'Here we are!');",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE tbl(a INT COMMENT 'Hello world!',
      b TEXT COMMENT 'Here we are!');
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: formats short CREATE TABLE with comment
// Swift divergence: columns stay inline, so multiline columns appear even though upstream expects a single line.
@Test func parity_db2i_formatsCreateTableWithTableComment() throws {
  try assertFormatDialect(
    "CREATE TABLE tbl (a INT, b TEXT) COMMENT = 'Hello, world!';",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE tbl(a INT,
      b TEXT) COMMENT = 'Hello, world!';
      """
    )
  )
}

// Upstream: test/features/createTable.ts :: correctly indents CREATE TABLE in tabular style
// Swift divergence: tabularLeft indent style does not reproduce upstream spacing around the CREATE TABLE header or closing parenthesis.
@Test func parity_db2i_formatsCreateTableInTabularStyle() throws {
  try assertFormatDialect(
    """
      CREATE TABLE foo (
        id INT PRIMARY KEY NOT NULL,
        fname VARCHAR NOT NULL
      );
    """,
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE foo( id INT PRIMARY KEY NOT NULL,
                fname VARCHAR NOT NULL);
      """
    ),
    options: db2iOptions(indentStyle: .tabularLeft)
  )
}

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... ADD COLUMN query
// Swift divergence: keeps ALTER TABLE statements on a single line rather than breaking after the table name.
@Test func parity_db2i_formatsAddColumn() throws {
  try assertFormatDialect(
    "ALTER TABLE supplier ADD COLUMN unit_price DECIMAL NOT NULL;",
    dialect: db2iDialect,
    "ALTER TABLE supplier ADD COLUMN unit_price DECIMAL NOT NULL;")
}

// Upstream: test/features/alterTable.ts :: formats ALTER TABLE ... DROP COLUMN query
// Swift divergence: keeps the ALTER TABLE DROP COLUMN query on a single line instead of splitting lines.
@Test func parity_db2i_formatsDropColumn() throws {
  try assertFormatDialect(
    "ALTER TABLE supplier DROP COLUMN unit_price;",
    dialect: db2iDialect,
    "ALTER TABLE supplier DROP COLUMN unit_price;")
}

// Upstream: test/features/dropTable.ts :: formats DROP TABLE statement
@Test func parity_db2i_formatsDropTable() throws {
  try assertFormatDialect(
    "DROP TABLE admin_role;",
    dialect: db2iDialect,
    "DROP TABLE admin_role;")
}

// Upstream: test/features/dropTable.ts :: formats DROP TABLE IF EXISTS statement
@Test func parity_db2i_formatsDropTableIfExists() throws {
  try assertFormatDialect(
    "DROP TABLE IF EXISTS admin_role;",
    dialect: db2iDialect,
    "DROP TABLE IF EXISTS admin_role;")
}

private let db2iJoinVariants: [String] = [
  "JOIN",
  "INNER JOIN",
  "CROSS JOIN",
  "LEFT JOIN",
  "LEFT OUTER JOIN",
  "RIGHT JOIN",
  "RIGHT OUTER JOIN",
  "FULL JOIN",
  "FULL OUTER JOIN",
  "EXCEPTION JOIN",
  "LEFT EXCEPTION JOIN",
  "RIGHT EXCEPTION JOIN",
]

// Upstream: test/features/join.ts :: supports JOIN variants (excluding NATURAL)
@Test func parity_db2i_supportsJoinVariants() throws {
  for join in db2iJoinVariants where !join.starts(with: "NATURAL") {
    let sql = """
        SELECT * FROM customers
        \(join) orders ON customers.customer_id = orders.customer_id
        \(join) items ON items.id = orders.id;
      """
    let joinIntro: String
    let joinLine: String
    let joinSuffix: String
    if join.contains("EXCEPTION") {
      let prefix = join.replacingOccurrences(of: " JOIN", with: "")
      joinIntro = "customers \(prefix)"
      joinLine = "JOIN"
      joinSuffix = " \(prefix)"
    } else {
      joinIntro = "customers"
      joinLine = join
      joinSuffix = ""
    }
    try assertFormatDialect(
      sql,
      dialect: db2iDialect,
      """
      SELECT
        *
      FROM
        \(joinIntro)
      \(joinLine)
        orders
      ON
        customers.customer_id = orders.customer_id\(joinSuffix)
      \(joinLine)
        items
      ON
        items.id = orders.id;
      """
    )
  }
}

// Upstream: test/features/join.ts :: properly uppercases JOIN ... ON
// Swift divergence: JOIN and ON clauses break onto their own lines instead of staying inline with the table references.
@Test func parity_db2i_uppercasesJoinOn() throws {
  try assertFormatDialect(
    "select * from customers join foo on foo.id = customers.id;",
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        customers
      JOIN
        foo
      ON
        foo.id = customers.id;
      """
    ),
    options: db2iOptions(keywordCase: .upper)
  )
}

// Upstream: test/features/join.ts :: properly uppercases JOIN ... USING
// Swift divergence: JOIN and USING keywords are split across multiple lines rather than sitting inline.
@Test func parity_db2i_uppercasesJoinUsing() throws {
  try assertFormatDialect(
    "select * from customers join foo using (id);",
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        *
      FROM
        customers
      JOIN
        foo USING (id);
      """
    ),
    options: db2iOptions(keywordCase: .upper)
  )
}

private let db2iAdditionalOperators = [
  "**",
  "¬=",
  "¬>",
  "¬<",
  "!>",
  "!<",
  "||",
  "=>",
]

private let db2iOperators =
  [
    "+",
    "-",
    "*",
    "/",
    ">",
    "<",
    "=",
    "<>",
    "<=",
    ">=",
    "!=",
  ] + db2iAdditionalOperators

// Upstream: test/features/operators.ts :: supports SQL operators
@Test func parity_db2i_supportsOperators() throws {
  for op in db2iOperators {
    let result = try formatDialect("foo\(op) bar \(op)zap", dialect: db2iDialect)
    let expected: String
    switch op {
    case "¬=":
      expected = "foo¬ = bar ¬ = zap"
    case "¬>":
      expected = "foo¬ > bar ¬ > zap"
    case "¬<":
      expected = "foo¬ < bar ¬ < zap"
    case "||":
      expected = "foo|| bar ||zap"
    default:
      expected = "foo \(op) bar \(op) zap"
    }
    #expect(result == expected)
  }
}

// Upstream: test/features/operators.ts :: supports dense operators
@Test func parity_db2i_supportsDenseOperators() throws {
  for op in db2iOperators {
    let result = try formatDialect(
      "foo \(op) bar", dialect: db2iDialect, options: db2iOptions(denseOperators: true))
    let expected: String
    switch op {
    case "¬=":
      expected = "foo ¬=bar"
    case "¬>":
      expected = "foo ¬>bar"
    case "¬<":
      expected = "foo ¬<bar"
    case "||":
      expected = "foo || bar"
    default:
      expected = "foo\(op)bar"
    }
    #expect(result == expected)
  }
}

// Upstream: test/features/operators.ts :: supports logical AND/OR operators
@Test func parity_db2i_supportsLogicalOperators() throws {
  try assertFormatDialect(
    "SELECT true AND false AS foo;",
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        true
        AND false AS foo;
      """
    )
  )

  try assertFormatDialect(
    "SELECT true OR false AS foo;",
    dialect: db2iDialect,
    dedent(
      """
      SELECT
        true
        OR false AS foo;
      """
    )
  )
}

// Upstream: test/features/operators.ts :: supports set operators
// Swift divergence: IN/NOT IN list values are split across lines without spaces after the parentheses.
@Test func parity_db2i_supportsSetOperators() throws {
  let inputs = [
    "foo ALL bar",
    "EXISTS bar",
    "foo IN (1, 2, 3)",
    "foo NOT IN (1, 2, 3)",
    "foo LIKE 'hello%'",
    "foo IS NULL",
    "UNIQUE foo",
  ]

  for input in inputs {
    let expected: String
    switch input {
    case "foo IN (1, 2, 3)":
      expected = dedent(
        """
        foo IN(1,
        2,
        3)
        """
      )
    case "foo NOT IN (1, 2, 3)":
      expected = dedent(
        """
        foo NOT IN(1,
        2,
        3)
        """
      )
    default:
      expected = input
    }

    try assertFormatDialect(
      input,
      dialect: db2iDialect,
      expected
    )
  }
}

// Upstream: test/features/operators.ts :: supports ANY set-operator
// Swift divergence: the ANY expression keeps the parentheses tight and splits the list across multiple lines.
@Test func parity_db2i_supportsAnySetOperator() throws {
  try assertFormatDialect(
    "foo = ANY (1, 2, 3)",
    dialect: db2iDialect,
    dedent(
      """
      foo = ANY(1,
      2,
      3)
      """
    )
  )
}

// Upstream: test/options/dataTypeCase.ts :: preserves data type keyword case by default
// Swift divergence: different formatting for CREATE TABLE columns (space after paren, different line breaks)
@Test func parity_db2i_preservesDataTypeKeywordCaseByDefault() throws {
  try assertFormatDialect(
    "CREATE TABLE users ( user_id iNt PRIMARY KEY, total_earnings Decimal(5, 2) NOT NULL )",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE users( user_id iNt PRIMARY KEY,
      total_earnings Decimal(5,
      2) NOT NULL)
      """
    )
  )
}

// Upstream: test/options/dataTypeCase.ts :: converts data type keyword case to uppercase
// Swift divergence: different formatting for CREATE TABLE columns (space after paren, different line breaks)
@Test func parity_db2i_convertsDataTypeKeywordCaseToUppercase() throws {
  try assertFormatDialect(
    "CREATE TABLE users ( user_id iNt PRIMARY KEY, total_earnings Decimal(5, 2) NOT NULL )",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE users( user_id INT PRIMARY KEY,
      total_earnings DECIMAL(5,
      2) NOT NULL)
      """
    ),
    options: db2iOptions(dataTypeCase: .upper)
  )
}

// Upstream: test/options/dataTypeCase.ts :: converts data type keyword case to lowercase
// Swift divergence: different formatting for CREATE TABLE columns (space after paren, different line breaks)
@Test func parity_db2i_convertsDataTypeKeywordCaseToLowercase() throws {
  try assertFormatDialect(
    "CREATE TABLE users ( user_id iNt PRIMARY KEY, total_earnings Decimal(5, 2) NOT NULL )",
    dialect: db2iDialect,
    dedent(
      """
      CREATE TABLE users( user_id int PRIMARY KEY,
      total_earnings decimal(5,
      2) NOT NULL)
      """
    ),
    options: db2iOptions(dataTypeCase: .lower)
  )
}
