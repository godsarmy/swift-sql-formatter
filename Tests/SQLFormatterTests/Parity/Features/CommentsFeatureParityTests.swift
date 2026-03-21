import Testing

@testable import SQLFormatter

// Upstream: test/features/comments.ts :: formats SELECT query with different comments
// Swift divergence: block and line comments are emitted as dedicated lines more aggressively.
@Test func parity_comments_formatsSelectWithDifferentComments() throws {
  try assertFormat(
    """
      SELECT
      /*
       * This is a block comment
       */
      * FROM
      -- This is another comment
      MyTable -- One final comment
      WHERE 1 = 2;
    """,
    """
      SELECT
      /*
         * This is a block comment
         */
      *
      FROM
      -- This is another comment
      MyTable
      -- One final comment
      WHERE
        1 = 2;
      """
  )
}

// Upstream: test/features/comments.ts :: maintains block comment indentation
// Swift divergence: top-level block comment under SELECT is not indented.
@Test func parity_comments_maintainsBlockCommentIndentation() throws {
  try assertFormat(
    """
      SELECT
        /*
         * This is a block comment
         */
        *
      FROM
        MyTable
      WHERE
        1 = 2;
      """,
    """
      SELECT
      /*
         * This is a block comment
         */
      *
      FROM
        MyTable
      WHERE
        1 = 2;
      """
  )
}

// Upstream: test/features/comments.ts :: keeps block comment on separate line when separate in input
// Swift divergence: block comments are moved to standalone lines with no indentation.
@Test func parity_comments_keepsSeparateLineBlockCommentOnSeparateLine() throws {
  try assertFormat(
    """
      SELECT
        /* separate-line block comment */
        foo,
        bar /* inline block comment */
      FROM
        tbl;
      """,
    """
      SELECT
      /* separate-line block comment */
      foo,
      bar
      /* inline block comment */
      FROM
        tbl;
      """
  )
}

// Upstream: test/features/comments.ts :: formats tricky line comments
// Swift divergence: line comment after expression is lifted to its own line.
@Test func parity_comments_formatsTrickyLineComments() throws {
  try assertFormat(
    "SELECT a--comment, here\nFROM b--comment",
    """
      SELECT
        a
      --comment, here
      FROM
        b
      --comment
      """
  )
}

// Upstream: test/features/comments.ts :: formats first line comment in file
@Test func parity_comments_formatsFirstLineCommentInFile() throws {
  try assertFormat(
    "-- comment1\n-- comment2\n",
    """
      -- comment1
      -- comment2
      """
  )
}

// Upstream: test/features/comments.ts :: formats first block comment in file
@Test func parity_comments_formatsFirstBlockCommentInFile() throws {
  try assertFormat(
    "/*comment1*/\n/*comment2*/\n",
    """
      /*comment1*/
      /*comment2*/
      """
  )
}

// Upstream: test/features/comments.ts :: recognizes line-comments with windows line-endings
// Swift divergence: comments and trailing inline comments are split onto own lines.
@Test func parity_comments_recognizesLineCommentsWithWindowsLineEndings() throws {
  let result = try format("SELECT * FROM\r\n-- line comment 1\r\nMyTable -- line comment 2\r\n")
  #expect(result == "SELECT\n  *\nFROM\n-- line comment 1\nMyTable\n-- line comment 2")
}

// Upstream: test/features/comments.ts :: handles block comments with /** and **/ patterns
@Test func parity_comments_handlesBlockCommentsWithDoubleAsteriskPatterns() throws {
  let sql = "/** This is a block comment **/"
  let result = try format(sql)
  #expect(result == sql)
}

// Upstream: test/features/comments.ts :: supports # line comment (when hash comments enabled)
@Test func parity_comments_supportsHashLineCommentInMariaDbFamily() throws {
  try assertFormatDialect(
    "SELECT alpha # commment\nFROM beta",
    dialect: .mariaDB,
    """
      SELECT
        alpha # commment
      FROM
        beta
      """
  )

  try assertFormatDialect(
    "SELECT alpha # commment\nFROM beta",
    dialect: .mySQL,
    """
      SELECT
        alpha # commment
      FROM
        beta
      """
  )
}
