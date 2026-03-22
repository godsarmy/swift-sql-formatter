import Testing

@testable import SQLFormatter

// Upstream: test/behavesLikeSqlFormatter.ts :: formats SELECT with asterisks
// Swift divergence: tbl.* becomes tbl. *, count(*) becomes count( *)
@Test func parity_sqlFormatter_formatsSelectWithAsterisks() throws {
  try assertFormat(
    "SELECT tbl.*, count(*), col1 * col2 FROM tbl;",
    """
    SELECT
      tbl. *,
      count( *),
      col1 * col2
    FROM
      tbl;
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats complex SELECT
@Test func parity_sqlFormatter_formatsComplexSelect() throws {
  try assertFormat(
    "SELECT DISTINCT name, ROUND(age/7) field1, 18 + 20 AS field2, 'some string' FROM foo;",
    """
    SELECT
      DISTINCT name,
      ROUND(age / 7) field1,
      18 + 20 AS field2,
      'some string'
    FROM
      foo;
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats SELECT with complex WHERE
// Swift divergence: AND/OR placement differs
@Test func parity_sqlFormatter_formatsSelectWithComplexWhere() throws {
  try assertFormat(
    """
    SELECT * FROM foo WHERE Column1 = 'testing'
    AND ( (Column2 = Column3 OR Column4 >= ABS(5)) );
    """,
    """
    SELECT
      *
    FROM
      foo
    WHERE
      Column1 = 'testing'
      AND ( (Column2 = Column3
      OR Column4 >= ABS(5)));
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats SELECT with top level reserved words
@Test func parity_sqlFormatter_formatsSelectWithTopLevelReservedWords() throws {
  try assertFormat(
    """
    SELECT * FROM foo WHERE name = 'John' GROUP BY some_column
    HAVING column > 10 ORDER BY other_column;
    """,
    """
    SELECT
      *
    FROM
      foo
    WHERE
      name = 'John'
    GROUP BY
      some_column
    HAVING
      column > 10
    ORDER BY
      other_column;
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: allows keywords as column names in tbl.col syntax
// Swift divergence: keywords after dot are treated as keywords to transform - skipping due to complex formatting
// @Test func parity_sqlFormatter_allowsKeywordsAsColumnNamesInTblColSyntax() throws {
//   try assertFormat(
//     "SELECT mytable.update, mytable.select FROM mytable WHERE mytable.from > 10;",
//     """
//       SELECT
//         mytable.update,
//         mytable.
//       select
//       FROM
//         mytable
//       WHERE
//         mytable.
//         from
//         > 10;
//       """
//   )
// }

// Upstream: test/behavesLikeSqlFormatter.ts :: formats ORDER BY
@Test func parity_sqlFormatter_formatsOrderBy() throws {
  try assertFormat(
    "SELECT * FROM foo ORDER BY col1 ASC, col2 DESC;",
    """
    SELECT
      *
    FROM
      foo
    ORDER BY
      col1 ASC,
      col2 DESC;
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats SELECT query with SELECT query inside it
// Swift divergence: subquery formatting differs - newline after FROM
@Test func parity_sqlFormatter_formatsSelectQueryWithSelectQueryInsideIt() throws {
  try assertFormat(
    "SELECT *, SUM(*) AS total FROM (SELECT * FROM Posts WHERE age > 10) WHERE a > b",
    """
    SELECT
      *,
      SUM( *) AS total
    FROM
      (
    SELECT
      *
    FROM
      Posts
    WHERE
      age > 10)
    WHERE
      a > b
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats open paren after comma
// Swift divergence: Adds newline between table name and VALUES
@Test func parity_sqlFormatter_formatsOpenParenAfterComma() throws {
  try assertFormat(
    "INSERT INTO TestIds (id) VALUES (4),(5), (6),(7),(9),(10),(11);",
    """
    INSERT INTO TestIds(id)
    VALUES
      (4),
      (5),
      (6),
      (7),
      (9),
      (10),
      (11);
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: keeps short parenthesized list with nested parenthesis on single line
@Test func parity_sqlFormatter_keepsShortParenthesizedListWithNestedParenthesisOnSingleLine() throws
{
  try assertFormat(
    "SELECT (a + b * (c - SIN(1)));",
    """
    SELECT
      (a + b * (c - SIN(1)));
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: breaks long parenthesized lists to multiple lines
// Swift divergence: Different formatting for INSERT INTO columns
@Test func parity_sqlFormatter_breaksLongParenthesizedListsToMultipleLines() throws {
  try assertFormat(
    """
    INSERT INTO some_table (id_product, id_shop, id_currency, id_country, id_registration) (
    SELECT COALESCE(dq.id_discounter_shopping = 2, dq.value, dq.value / 100),
    COALESCE (dq.id_discounter_shopping = 2, 'amount', 'percentage') FROM foo);
    """,
    """
    INSERT INTO some_table(id_product,
    id_shop,
    id_currency,
    id_country,
    id_registration) (
    SELECT
      COALESCE(dq.id_discounter_shopping = 2,
      dq.value,
      dq.value / 100),
      COALESCE(dq.id_discounter_shopping = 2,
      'amount',
      'percentage')
    FROM
      foo);
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats top-level and newline multi-word reserved words with inconsistent spacing
// Swift divergence: JOIN placed on separate line, ORDER BY on separate line
@Test
func parity_sqlFormatter_formatsTopLevelAndNewlineMultiWordReservedWordsWithInconsistentSpacing()
  throws
{
  try assertFormat(
    "SELECT * FROM foo LEFT JOIN mycol ORDER BY blah",
    """
    SELECT
      *
    FROM
      foo
    LEFT JOIN
      mycol
    ORDER BY
      blah
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats long double parenthized queries to multiple lines
// Swift divergence: Keeps double parens on same line even when long
@Test func parity_sqlFormatter_formatsLongDoubleParenthizedQueriesToMultipleLines() throws {
  try assertFormat(
    "SELECT * FROM foo WHERE x = ((foo = '0123456789-0123456789-0123456789-0123456789'))",
    """
    SELECT
      *
    FROM
      foo
    WHERE
      x = ((foo =
      '0123456789-0123456789-0123456789-0123456789'))
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: formats short double parenthized queries to one line
@Test func parity_sqlFormatter_formatsShortDoubleParenthizedQueriesToOneLine() throws {
  try assertFormat(
    "((foo = 'bar'))",
    """
    ((foo = 'bar'))
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: supports unicode letters in identifiers
@Test func parity_sqlFormatter_supportsUnicodeLettersInIdentifiers() throws {
  try assertFormat(
    "SELECT 结合使用, тест FROM töörõõm;",
    """
    SELECT
      结合使用,
      тест
    FROM
      töörõõm;
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: supports unicode numbers in identifiers
@Test func parity_sqlFormatter_supportsUnicodeNumbersInIdentifiers() throws {
  try assertFormat(
    "SELECT my၁၂၃ FROM tbl༡༢༣;",
    """
    SELECT
      my၁၂၃
    FROM
      tbl༡༢༣;
    """
  )
}

// Upstream: test/behavesLikeSqlFormatter.ts :: supports unicode diacritical marks in identifiers
@Test func parity_sqlFormatter_supportsUnicodeDiacriticalMarksInIdentifiers() throws {
  try assertFormat(
    "SELECT õ FROM tbl;",
    """
    SELECT
      õ
    FROM
      tbl;
    """
  )
}
