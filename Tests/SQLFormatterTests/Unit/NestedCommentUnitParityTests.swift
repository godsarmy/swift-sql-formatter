import Testing

@testable import SQLFormatter

private func tokenize(
  _ sql: String,
  dialect: Dialect = .standardSQL
) throws -> [Token] {
  try Tokenizer(dialect: dialect).tokenize(sql)
}

private func commentTexts(
  from sql: String,
  dialect: Dialect = .standardSQL
) throws -> [String] {
  try tokenize(sql, dialect: dialect)
    .filter { $0.type == .comment }
    .map(\.text)
}

// Upstream: test/unit/NestedComment.test.ts :: matches comment at the start of a string
@Test func parity_nestedComment_matchesCommentAtStart() throws {
  let tokens = try tokenize("/* comment */ blah...")
  let first = tokens.first
  #expect(first?.type == .comment)
  #expect(first?.text == "/* comment */")
}

// Upstream: test/unit/NestedComment.test.ts :: matches empty comment block
@Test func parity_nestedComment_matchesEmptyCommentBlock() throws {
  let tokens = try tokenize("/**/ blah...")
  let first = tokens.first
  #expect(first?.text == "/**/")
}

// Upstream: test/unit/NestedComment.test.ts :: matches comment containing * and / characters
@Test func parity_nestedComment_matchesAsteriskSlashCharacters() throws {
  let tokens = try tokenize("/** // */ blah...")
  let first = tokens.first
  #expect(first?.text == "/** // */")
}

// Upstream: test/unit/NestedComment.test.ts :: matches only first comment, when two comments in row
@Test func parity_nestedComment_matchesAdjacentComments() throws {
  let texts = try commentTexts(from: "/*com1*//*com2*/ blah...")
  #expect(texts == ["/*com1*/", "/*com2*/"])
}

// Upstream: test/unit/NestedComment.test.ts :: matches comment in the middle of a string
@Test func parity_nestedComment_matchesCommentInMiddleOfString() throws {
  let texts = try commentTexts(from: "hello /* comment */ blah...")
  #expect(texts == ["/* comment */"])
}

// Upstream: test/unit/NestedComment.test.ts :: does not match unclosed comment
// Swift divergence: tokenizer raises FormatError.unterminatedBlockComment instead of returning nil when a comment is unterminated.
@Test func parity_nestedComment_doesNotMatchUnclosedComment() {
  do {
    _ = try tokenize("/* comment blah...")
    Issue.record("Expected unterminated block comment error")
  } catch FormatError.unterminatedBlockComment {
    // expected
  } catch {
    Issue.record("Unexpected error \(error)")
  }
}

// Upstream: test/unit/NestedComment.test.ts :: does not match unopened comment
@Test func parity_nestedComment_doesNotMatchUnopenedComment() throws {
  let texts = try commentTexts(from: " comment */ blah...")
  #expect(texts.isEmpty)
}

// Upstream: test/unit/NestedComment.test.ts :: matches a nested comment
// Swift divergence: tokenizer closes block comments at the first */ and returns the remaining markers as separate tokens.
@Test func parity_nestedComment_truncatesAtFirstClosingDelimiter() throws {
  let texts = try commentTexts(from: "/* some /* nested */ comment */ blah...")
  #expect(texts == ["/* some /* nested */"])
}

// Upstream: test/unit/NestedComment.test.ts :: matches a multi-level nested comment
// Swift divergence: only the initial portion ending at the first */ is captured as a comment token.
@Test func parity_nestedComment_truncatesMultiLevelNest() throws {
  let texts = try commentTexts(from: "/* some /* /* nested */ */ comment */ blah...")
  #expect(texts == ["/* some /* /* nested */"])
}

// Upstream: test/unit/NestedComment.test.ts :: matches multiple nested comments
// Swift divergence: nested sections are split across comment tokens and stray markers instead of a single match.
@Test func parity_nestedComment_handlesMultipleNestedMarkers() throws {
  let texts = try commentTexts(from: "/* some /* n1 */ and /* n2 */ coms */ blah...")
  #expect(texts == ["/* some /* n1 */", "/* n2 */"])
}

// Upstream: test/unit/NestedComment.test.ts :: does not match an inproperly nested comment
// Swift divergence: tokenizer throws FormatError.unterminatedBlockComment rather than returning null.
@Test func parity_nestedComment_rejectsImproperlyNestedComment() {
  do {
    _ = try tokenize("/* some /* comment blah...")
    Issue.record("Expected unterminated block comment error")
  } catch FormatError.unterminatedBlockComment {
    // expected
  } catch {
    Issue.record("Unexpected error \(error)")
  }
}
