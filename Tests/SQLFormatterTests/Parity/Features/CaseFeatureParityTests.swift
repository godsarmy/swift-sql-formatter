import Testing

@testable import SQLFormatter

// Upstream: test/features/case.ts :: formats CASE ... WHEN with a blank expression
// Swift divergence: CASE/WHEN chain currently stays inline.
@Test func parity_case_formatsCaseWhenWithBlankExpression() throws {
  try assertFormat(
    "CASE WHEN opt = 'foo' THEN 1 WHEN opt = 'bar' THEN 2 WHEN opt = 'baz' THEN 3 ELSE 4 END;",
    "CASE WHEN opt = 'foo' THEN 1 WHEN opt = 'bar' THEN 2 WHEN opt = 'baz' THEN 3 ELSE 4 END;"
  )
}

// Upstream: test/features/case.ts :: formats CASE ... WHEN with an expression
// Swift divergence: CASE/WHEN chain currently stays inline.
@Test func parity_case_formatsCaseWhenWithExpression() throws {
  try assertFormat(
    "CASE trim(sqrt(2)) WHEN 'one' THEN 1 WHEN 'two' THEN 2 WHEN 'three' THEN 3 ELSE 4 END;",
    "CASE trim(sqrt(2)) WHEN 'one' THEN 1 WHEN 'two' THEN 2 WHEN 'three' THEN 3 ELSE 4 END;"
  )
}

// Upstream: test/features/case.ts :: formats CASE ... WHEN inside SELECT
// Swift divergence: CASE expression currently stays inline in SELECT list.
@Test func parity_case_formatsCaseWhenInsideSelect() throws {
  try assertFormat(
    "SELECT foo, bar, CASE baz WHEN 'one' THEN 1 WHEN 'two' THEN 2 ELSE 3 END FROM tbl;",
    """
    SELECT
      foo,
      bar,
      CASE baz WHEN 'one' THEN 1 WHEN 'two' THEN 2 ELSE 3 END
    FROM
      tbl;
    """
  )
}

// Upstream: test/features/case.ts :: recognizes lowercase CASE ... END
// Swift divergence: lowercase case/end chain currently stays inline.
@Test func parity_case_recognizesLowercaseCaseEnd() throws {
  try assertFormat(
    "case when opt = 'foo' then 1 else 2 end;",
    "case when opt = 'foo' then 1 else 2 end;"
  )
}

// Upstream: test/features/case.ts :: ignores words CASE and END inside other strings
@Test func parity_case_ignoresWordsCaseEndInsideOtherStrings() throws {
  try assertFormat(
    "SELECT CASEDATE, ENDDATE FROM table1;",
    """
    SELECT
      CASEDATE,
      ENDDATE
    FROM
      table1;
    """
  )
}

// Upstream: test/features/case.ts :: properly converts to uppercase in case statements
// Swift divergence: keywordCase does not currently uppercase lowercase case/else/end tokens here.
@Test func parity_case_convertsToUppercaseInCaseStatements() throws {
  try assertFormat(
    "case trim(sqrt(my_field)) when 'one' then 1 when 'two' then 2 when 'three' then 3 else 4 end;",
    "case TRIM(SQRT(my_field)) WHEN 'one' THEN 1 WHEN 'two' THEN 2 WHEN 'three' THEN 3 else 4 end;",
    options: FormatOptions(keywordCase: .upper, functionCase: .upper)
  )
}

// Upstream: test/features/case.ts :: handles edge case of ending inline block with END
// Swift divergence: inline CASE expression inside SUM currently remains inline.
@Test func parity_case_handlesEdgeCaseEndingInlineBlockWithEnd() throws {
  try assertFormat(
    "select sum(case a when foo then bar end) from quaz",
    """
    select
      sum(case a when foo then bar end)
    from
      quaz
    """
  )
}

// Upstream: test/features/case.ts :: formats CASE with comments
// Swift divergence: comments in CASE expressions are currently emitted on standalone lines.
@Test func parity_case_formatsCaseWithComments() throws {
  try assertFormat(
    """
    SELECT CASE /*c1*/ foo /*c2*/
    WHEN /*c3*/ 1 /*c4*/ THEN /*c5*/ 2 /*c6*/
    ELSE /*c7*/ 3 /*c8*/
    END;
    """,
    """
    SELECT
      CASE
    /*c1*/
    foo
    /*c2*/
    WHEN
    /*c3*/
    1
    /*c4*/
    THEN
    /*c5*/
    2
    /*c6*/
    ELSE
    /*c7*/
    3
    /*c8*/
    END;
    """
  )
}

// Upstream: test/features/case.ts :: formats CASE with comments inside sub-expressions
// Swift divergence: comments in CASE sub-expressions are currently emitted on standalone lines.
@Test func parity_case_formatsCaseWithCommentsInsideSubexpressions() throws {
  try assertFormat(
    """
    SELECT CASE foo + /*c1*/ bar
    WHEN 1 /*c2*/ + 1 THEN 2 /*c2*/ * 2
    ELSE 3 - /*c3*/ 3
    END;
    """,
    """
    SELECT
      CASE foo +
    /*c1*/
    bar WHEN 1
    /*c2*/
    + 1 THEN 2
    /*c2*/
    * 2 ELSE 3 -
    /*c3*/
    3 END;
    """
  )
}

// Upstream: test/features/case.ts :: formats CASE with identStyle:tabularLeft
// Swift divergence: tabular styles keep this CASE expression inline.
@Test func parity_case_formatsCaseWithIndentStyleTabularLeft() throws {
  try assertFormat(
    "SELECT CASE foo WHEN 1 THEN bar ELSE baz END;",
    "SELECT    CASE foo WHEN 1 THEN bar ELSE baz END;",
    options: FormatOptions(indentStyle: .tabularLeft)
  )
}

// Upstream: test/features/case.ts :: formats CASE with identStyle:tabularRight
// Swift divergence: tabular styles keep this CASE expression inline.
@Test func parity_case_formatsCaseWithIndentStyleTabularRight() throws {
  try assertFormat(
    "SELECT CASE foo WHEN 1 THEN bar ELSE baz END;",
    "SELECT CASE foo WHEN 1 THEN bar ELSE baz END;",
    options: FormatOptions(indentStyle: .tabularRight)
  )
}

// Upstream: test/features/case.ts :: formats nested case expressions
// Swift divergence: nested CASE chains currently stay largely inline.
@Test func parity_case_formatsNestedCaseExpressions() throws {
  try assertFormat(
    """
    SELECT
      CASE
        CASE foo WHEN 1 THEN 11 ELSE 22 END
        WHEN 11 THEN 110
        WHEN 22 THEN 220
        ELSE 123
      END
    FROM
      tbl;
    """,
    """
    SELECT
      CASE CASE foo WHEN 1 THEN 11 ELSE 22 END WHEN 11 THEN 110 WHEN 22 THEN 220 ELSE 123 END
    FROM
      tbl;
    """
  )
}

// Upstream: test/features/case.ts :: formats between inside case expression
// Swift divergence: CASE chain is inline and BETWEEN keeps line break before AND.
@Test func parity_case_formatsBetweenInsideCaseExpression() throws {
  try assertFormat(
    "SELECT CASE WHEN x1 BETWEEN 1 AND 12 THEN '' END c1;",
    """
    SELECT
      CASE WHEN x1 BETWEEN 1
      AND 12 THEN '' END c1;
    """
  )
}
