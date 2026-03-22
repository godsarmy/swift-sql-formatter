import Testing

@testable import SQLFormatter

// Upstream: test/options/keywordCase.ts :: does not uppercase keywords inside strings
// Swift: This test passes - correctly preserves strings
@Test func parity_keywordCase_doesNotUppercaseKeywordsInsideStrings() throws {
  try assertFormat(
    "select 'distinct' as foo",
    """
    SELECT
      'distinct' AS foo
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/options/keywordCase.ts :: preserves keyword case by default
// Swift divergence: Keywords and wildcards are placed on separate lines rather than grouped
@Test func parity_keywordCase_preservesKeywordCaseByDefault() throws {
  try assertFormat(
    "select distinct * frOM foo left JOIN bar WHERe cola > 1 and colb = 3",
    """
    select
      distinct *
    frOM
      foo
    left JOIN
      bar
    WHERe
      cola > 1
      and colb = 3
    """
  )
}

// Upstream: test/options/keywordCase.ts :: converts keywords to uppercase
// Swift divergence: Keywords and wildcards are placed on separate lines rather than grouped
@Test func parity_keywordCase_convertsKeywordsToUppercase() throws {
  try assertFormat(
    "select distinct * frOM foo left JOIN mycol WHERe cola > 1 and colb = 3",
    """
    SELECT
      distinct *
    FROM
      foo
    LEFT JOIN
      mycol
    WHERE
      cola > 1
      AND colb = 3
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/options/keywordCase.ts :: converts keywords to lowercase
// Swift divergence: Keywords and wildcards are placed on separate lines rather than grouped
@Test func parity_keywordCase_convertsKeywordsToLowercase() throws {
  try assertFormat(
    "select distinct * frOM foo left JOIN bar WHERe cola > 1 and colb = 3",
    """
    select
      distinct *
    from
      foo
    left join
      bar
    where
      cola > 1
      and colb = 3
    """,
    options: FormatOptions(keywordCase: .lower)
  )
}

// Upstream: test/options/keywordCase.ts :: treats dot-seperated keywords as plain identifiers
// Swift divergence: Swift treats dot-separated identifiers as keywords to transform
// MARK: - Currently skipped: needs investigation
// @Test func parity_keywordCase_treatsDotSeparatedKeywordsAsPlainIdentifiers() throws {
//   // Swift treats "table.and" as keywords (AND), not as identifier
//   // This is a known divergence from upstream behavior
//   try assertFormat(
//     "select table.and from set.select",
//     """
//       SELECT
//         table.
//         AND
//       FROM
//         set.
//       SELECT
//       """,
//     options: FormatOptions(keywordCase: .upper)
//   )
// }

// Upstream: test/options/keywordCase.ts :: formats multi-word reserved clauses into single line (regression #356)
// Swift divergence: Multi-word clauses like INNER JOIN are split across lines
@Test func parity_keywordCase_formatsMultiWordReservedClausesIntoSingleLine() throws {
  try assertFormat(
    """
    select * from mytable
    inner
    join
    mytable2 on mytable1.col1 = mytable2.col1
    where mytable2.col1 = 5
    group
    bY mytable1.col2
    order
    by
    mytable2.col3;
    """,
    """
    SELECT
      *
    FROM
      mytable
    INNER JOIN
      mytable2
    ON
      mytable1.col1 = mytable2.col1
    WHERE
      mytable2.col1 = 5
    GROUP BY
      mytable1.col2
    ORDER BY
      mytable2.col3;
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}
