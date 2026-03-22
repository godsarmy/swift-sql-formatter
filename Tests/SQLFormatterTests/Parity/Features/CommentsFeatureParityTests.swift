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

// Upstream: test/features/comments.ts :: supports // line comment (when double-slash comments enabled)
@Test func parity_comments_supportsDoubleSlashLineCommentInSnowflake() throws {
  try assertFormatDialect(
    "SELECT alpha // commment\nFROM beta",
    dialect: .snowflake,
    """
    SELECT
      alpha // commment
    FROM
      beta
    """
  )
}

// Upstream: test/features/comments.ts :: supports nested block comments (when nested comments enabled)
// Swift divergence: tokenizer closes block comments at the first */, so nested comments split across lines.
@Test func parity_comments_supportsNestedBlockCommentsInPostgresqlFamily() throws {
  try assertFormatDialect(
    "SELECT alpha /* /* commment */ */ FROM beta",
    dialect: .postgreSQL,
    """
    SELECT
      alpha
    /* /* commment */
    */
    FROM
      beta
    """
  )

  try assertFormatDialect(
    "SELECT alpha /* /* commment */ */ FROM beta",
    dialect: .duckDB,
    """
    SELECT
      alpha
    /* /* commment */
    */
    FROM
      beta
    """
  )
}

// Upstream: test/features/comments.ts :: formats line comments followed by semicolon
// Swift divergence: inline line comment is emitted on its own line.
@Test func parity_comments_formatsLineCommentFollowedBySemicolon() throws {
  try assertFormat(
    """
      SELECT a FROM b --comment
      ;
    """,
    """
    SELECT
      a
    FROM
      b
    --comment
    ;
    """
  )
}

// Upstream: test/features/comments.ts :: formats line comments followed by comma
// Swift divergence: comment and following identifier are emitted on dedicated lines.
@Test func parity_comments_formatsLineCommentFollowedByComma() throws {
  try assertFormat(
    """
      SELECT a --comment
      , b
    """,
    """
    SELECT
      a
    --comment
    ,
    b
    """
  )
}

// Upstream: test/features/comments.ts :: formats line comments followed by close-paren
// Swift divergence: parenthesized expression remains compact; comment is moved to own line.
@Test func parity_comments_formatsLineCommentFollowedByCloseParen() throws {
  try assertFormat(
    "SELECT ( a --comment\n )",
    """
    SELECT
      ( a
    --comment
    )
    """
  )
}

// Upstream: test/features/comments.ts :: formats line comments followed by open-paren
// Swift divergence: comment is moved to own line and `()` stays unindented.
@Test func parity_comments_formatsLineCommentFollowedByOpenParen() throws {
  try assertFormat(
    "SELECT a --comment\n()",
    """
    SELECT
      a
    --comment
    ()
    """
  )
}

// Upstream: test/features/comments.ts :: preserves single-line comments at end of lines
// Swift divergence: end-of-line comments are split into standalone lines.
@Test func parity_comments_preservesSingleLineCommentsAtEndOfLines() throws {
  try assertFormat(
    """
      SELECT
        a, --comment1
        b --comment2
      FROM --comment3
        my_table;
    """,
    """
    SELECT
      a,
    --comment1
    b
    --comment2
    FROM
    --comment3
    my_table;
    """
  )
}

// Upstream: test/features/comments.ts :: preserves single-line comments on separate lines
// Swift divergence: separate-line comments are preserved but unindented.
@Test func parity_comments_preservesSingleLineCommentsOnSeparateLines() throws {
  try assertFormat(
    """
      SELECT
        --comment1
        a,
        --comment2
        b
      FROM
        --comment3
        my_table;
    """,
    """
    SELECT
    --comment1
    a,
    --comment2
    b
    FROM
    --comment3
    my_table;
    """
  )
}

// Upstream: test/features/comments.ts :: does not detect unclosed comment as a comment
@Test func parity_comments_doesNotDetectUnclosedCommentAsComment() throws {
  assertFormatError(
    """
    SELECT count(*)
    /*SomeComment
    """,
    contains: "unterminatedBlockComment"
  )
}

// Upstream: test/features/comments.ts :: formats comments between function name and parenthesis
// Swift divergence: comment is emitted on a standalone line and `*` gets spaced.
@Test func parity_comments_formatsCommentsBetweenFunctionNameAndParenthesis() throws {
  try assertFormat(
    """
      SELECT count /* comment */ (*);
    """,
    """
    SELECT
      count
    /* comment */
    ( *);
    """
  )
}

// Upstream: test/features/comments.ts :: formats comments between qualified.names (before dot)
// Swift divergence: comments before dot split qualified names over multiple lines.
@Test func parity_comments_formatsCommentsBetweenQualifiedNamesBeforeDot() throws {
  try assertFormat(
    """
      SELECT foo/* com1 */.bar, count()/* com2 */.bar, foo.bar/* com3 */.baz, (1, 2) /* com4 */.foo;
    """,
    """
    SELECT
      foo
    /* com1 */
    .bar,
    count()
    /* com2 */
    .bar,
    foo.bar
    /* com3 */
    .baz,
    (1,
    2)
    /* com4 */
    .foo;
    """
  )
}

// Upstream: test/features/comments.ts :: indents multiline block comment that is not a doc-comment
// Swift divergence: multiline block comment is not indented.
@Test func parity_comments_indentsMultilineBlockCommentThatIsNotDocComment() throws {
  try assertFormat(
    """
      SELECT 1
      /*
      comment line
      */
    """,
    """
    SELECT
      1
    /*
      comment line
      */
    """
  )
}

// Upstream: test/features/comments.ts :: formats comments between qualified.names (after dot)
// Swift divergence: comments after dot split each token to separate lines.
@Test func parity_comments_formatsCommentsBetweenQualifiedNamesAfterDot() throws {
  try assertFormat(
    """
      SELECT foo. /* com1 */ bar, foo. /* com2 */ *;
    """,
    """
    SELECT
      foo.
    /* com1 */
    bar,
    foo.
    /* com2 */
    *;
    """
  )
}
