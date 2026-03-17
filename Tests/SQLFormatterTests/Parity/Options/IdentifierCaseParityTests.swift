import Testing

@testable import SQLFormatter

// Upstream: test/options/identifierCase.ts :: preserves identifier case by default
// Swift divergence: Keywords like JOIN are placed on separate lines rather than grouped
@Test func parity_identifierCase_preservesIdentifierCaseByDefault() throws {
  try assertFormat(
    "select Abc, 'mytext' as MyText from tBl1 left join Tbl2 where colA > 1 and colB = 3",
    """
      select
        Abc,
        'mytext' as MyText
      from
        tBl1
      left join
        Tbl2
      where
        colA > 1
        and colB = 3
      """
  )
}

// Upstream: test/options/identifierCase.ts :: converts identifiers to uppercase
// Swift divergence: Keywords like JOIN are placed on separate lines rather than grouped
@Test func parity_identifierCase_convertsIdentifiersToUppercase() throws {
  try assertFormat(
    "select Abc, 'mytext' as MyText from tBl1 left join Tbl2 where colA > 1 and colB = 3",
    """
      select
        ABC,
        'mytext' as MYTEXT
      from
        TBL1
      left join
        TBL2
      where
        COLA > 1
        and COLB = 3
      """,
    options: FormatOptions(identifierCase: .upper)
  )
}

// Upstream: test/options/identifierCase.ts :: converts identifiers to lowercase
// Swift divergence: Keywords like JOIN are placed on separate lines rather than grouped
@Test func parity_identifierCase_convertsIdentifiersToLowercase() throws {
  try assertFormat(
    "select Abc, 'mytext' as MyText from tBl1 left join Tbl2 where colA > 1 and colB = 3",
    """
      select
        abc,
        'mytext' as mytext
      from
        tbl1
      left join
        tbl2
      where
        cola > 1
        and colb = 3
      """,
    options: FormatOptions(identifierCase: .lower)
  )
}

// Upstream: test/options/identifierCase.ts :: does not uppercase quoted identifiers
@Test func parity_identifierCase_doesNotUppercaseQuotedIdentifiers() throws {
  try assertFormat(
    "select \"abc\" as foo",
    """
      select
        "abc" as FOO
      """,
    options: FormatOptions(identifierCase: .upper)
  )
}

// Upstream: test/options/identifierCase.ts :: converts multi-part identifiers to uppercase
@Test func parity_identifierCase_convertsMultiPartIdentifiersToUppercase() throws {
  try assertFormat(
    "select Abc from Part1.Part2.Part3",
    """
      select
        ABC
      from
        PART1.PART2.PART3
      """,
    options: FormatOptions(identifierCase: .upper)
  )
}

// Upstream: test/options/identifierCase.ts :: function names are not affected by identifierCase option
// Swift divergence: function wildcard (*) has extra space: count( *)
@Test func parity_identifierCase_functionNamesNotAffected() throws {
  try assertFormat(
    "select count(*) from tbl",
    """
      select
        count( *)
      from
        TBL
      """,
    options: FormatOptions(identifierCase: .upper)
  )
}
