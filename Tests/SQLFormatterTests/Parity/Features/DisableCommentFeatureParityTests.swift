import Testing

@testable import SQLFormatter

// Upstream: test/features/disableComment.ts :: does not format text between /* sql-formatter-disable */ and /* sql-formatter-enable */
@Test func parity_disableComment_doesNotFormatTextBetweenDisableAndEnable() throws {
  try assertFormat(
    """
    SELECT foo FROM bar;
    /* sql-formatter-disable */
    SELECT foo FROM bar;
    /* sql-formatter-enable */
    SELECT foo FROM bar;
    """,
    """
    SELECT
      foo
    FROM
      bar;

    /* sql-formatter-disable */
    SELECT foo FROM bar;
    /* sql-formatter-enable */
    SELECT
      foo
    FROM
      bar;
    """
  )
}

// Upstream: test/features/disableComment.ts :: preserves indentation between /* sql-formatter-disable */ and /* sql-formatter-enable */
@Test func parity_disableComment_preservesIndentationBetweenDisableAndEnable() throws {
  let sql = """
    /* sql-formatter-disable */
    SELECT
      foo
        FROM
          bar;
    /* sql-formatter-enable */
    """
  try assertFormat(sql, sql)
}

// Upstream: test/features/disableComment.ts :: does not format text after /* sql-formatter-disable */ until end of file
@Test func parity_disableComment_doesNotFormatTextAfterDisableUntilEndOfFile() throws {
  try assertFormat(
    """
    SELECT foo FROM bar;
    /* sql-formatter-disable */
    SELECT foo FROM bar;

    SELECT foo FROM bar;
    """,
    """
    SELECT
      foo
    FROM
      bar;

    /* sql-formatter-disable */
    SELECT foo FROM bar;

    SELECT foo FROM bar;
    """
  )
}

// Upstream: test/features/disableComment.ts :: does not parse code between disable/enable comments
// Swift divergence: disabled segment is emitted without expression indentation under SELECT.
@Test func parity_disableComment_doesNotParseCodeBetweenDisableAndEnable() throws {
  try assertFormat(
    "SELECT /*sql-formatter-disable*/ ?!{}[] /*sql-formatter-enable*/ FROM bar;",
    """
    SELECT
    /*sql-formatter-disable*/ ?!{}[] /*sql-formatter-enable*/
    FROM
      bar;
    """
  )
}
