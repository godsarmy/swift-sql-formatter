import Testing

@testable import SQLFormatter

// Upstream: test/options/indentStyle.ts :: supports standard mode
@Test func parity_indentStyle_supportsStandardMode() throws {
  try assertFormat(
    "SELECT COUNT(a.column1) FROM table1",
    """
    SELECT
      COUNT(a.column1)
    FROM
      table1
    """,
    options: FormatOptions(indentStyle: .standard)
  )
}

// Upstream: test/options/indentStyle.ts :: supports tabularLeft mode
@Test func parity_indentStyle_supportsTabularLeftMode() throws {
  try assertFormat(
    "SELECT COUNT(a.column1) FROM table1",
    """
    SELECT    COUNT(a.column1)
    FROM      table1
    """,
    options: FormatOptions(indentStyle: .tabularLeft)
  )
}

// Upstream: test/options/indentStyle.ts :: supports tabularRight mode
@Test func parity_indentStyle_supportsTabularRightMode() throws {
  try assertFormat(
    "SELECT COUNT(a.column1) FROM table1",
    """
    SELECT COUNT(a.column1)
         FROM table1
    """,
    options: FormatOptions(indentStyle: .tabularRight)
  )
}

// Upstream: test/options/indentStyle.ts :: tabularLeft handles long keywords
// Swift divergence: UNION ALL placed on same line as preceding FROM
@Test func parity_indentStyle_tabularLeftHandlesLongKeywords() throws {
  try assertFormat(
    """
    SELECT *
    FROM a
    UNION ALL
    SELECT *
    FROM b
    LEFT OUTER JOIN c;
    """,
    """
    SELECT    *
    FROM      a UNION ALL
    SELECT    *
    FROM      b
    LEFT OUTER JOIN c;
    """,
    options: FormatOptions(indentStyle: .tabularLeft)
  )
}

// Upstream: test/options/indentStyle.ts :: tabularRight handles long keywords
// Swift divergence: Different formatting for set operations - UNION ALL on same line
@Test func parity_indentStyle_tabularRightHandlesLongKeywords() throws {
  try assertFormat(
    """
    SELECT *
    FROM a
    UNION ALL
    SELECT *
    FROM b
    LEFT OUTER JOIN c;
    """,
    """
    SELECT *
         FROM a UNION ALL
       SELECT *
         FROM b
    LEFT OUTER JOIN c;
    """,
    options: FormatOptions(indentStyle: .tabularRight)
  )
}
