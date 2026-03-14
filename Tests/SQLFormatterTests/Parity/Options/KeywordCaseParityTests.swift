import Testing

@testable import SQLFormatter

// Upstream: test/options/keywordCase.ts :: does not uppercase keywords inside strings
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
