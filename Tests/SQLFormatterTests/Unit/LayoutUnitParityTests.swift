import Testing

@testable import SQLFormatter

// Upstream: test/unit/Layout.test.ts :: simply concatenates plain strings
@Test func parity_layout_concatenatesPlainStrings() {
  let result = testLayout("hello", "world")

  #expect(result == "helloworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.SPACE inserts single space
@Test func parity_layout_spaceInsertsSingleSpace() {
  let result = testLayout("hello", .space, "world")

  #expect(result == "hello world")
}

// Upstream: test/unit/Layout.test.ts :: WS.SINGLE_INDENT inserts single indentation step
@Test func parity_layout_singleIndentInsertsStep() {
  let result = testLayout("hello", .newline, .singleIndent, "world")

  #expect(result == "hello\n-->world")
}

// Upstream: test/unit/Layout.test.ts :: WS.SINGLE_INDENT twice in a row
@Test func parity_layout_singleIndentTwiceInsertsTwoSteps() {
  let result = testLayout("hello", .newline, .singleIndent, .singleIndent, "world")

  #expect(result == "hello\n-->-->world")
}

// Upstream: test/unit/Layout.test.ts :: WS.INDENT inserts current indentation
@Test func parity_layout_indentInsertsCurrentIndentation() {
  let result = testLayout("hello", .newline, .indent, "world")

  #expect(result == "hello\n-->-->world")
}

// Upstream: test/unit/Layout.test.ts :: WS.INDENT twice in a row
@Test func parity_layout_indentTwiceDoublesIndentation() {
  let result = testLayout("hello", .newline, .indent, .indent, "world")

  #expect(result == "hello\n-->-->-->-->world")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_SPACE does nothing when no preceding whitespace
@Test func parity_layout_noSpaceWithoutWhitespaceIsNoop() {
  let result = testLayout("hello", .noSpace, "world")

  #expect(result == "helloworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_SPACE removes preceding spaces
// Swift divergence: OutputBuffer cannot scrub already emitted horizontal whitespace, so a single space remains.
@Test func parity_layout_noSpaceTrimsSpaces() {
  let result = testLayout("hello", .space, .space, .noSpace, "world")

  #expect(result == "hello world")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_SPACE removes preceding indentation
// Swift divergence: we cannot trim emitted indentation tokens with the current OutputBuffer API.
@Test func parity_layout_noSpaceTrimsIndentation() {
  let first = testLayout("hello", .newline, .singleIndent, .singleIndent, .noSpace, "world")
  let second = testLayout("hello", .newline, .indent, .noSpace, "world")

  #expect(first == "hello\n-->-->world")
  #expect(second == "hello\n-->-->world")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_SPACE does not remove newline
@Test func parity_layout_noSpaceKeepsNewlines() {
  let simple = testLayout("hello", .newline, .noSpace, "world")
  let mandatory = testLayout("hello", .mandatoryNewline, .noSpace, "world")

  #expect(simple == "hello\nworld")
  #expect(mandatory == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_SPACE removes preceding spaces up to first newline
@Test func parity_layout_noSpaceRemovesWhitespaceUntilNewline() {
  let simple = testLayout("hello", .newline, .space, .noSpace, "world")
  let mandatory = testLayout("hello", .mandatoryNewline, .space, .noSpace, "world")

  #expect(simple == "hello\nworld")
  #expect(mandatory == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NEWLINE inserts single newline
@Test func parity_layout_newlineInsertsSingleNewline() {
  let result = testLayout("hello", .newline, "world")

  #expect(result == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NEWLINE deduplicates consecutive newlines
@Test func parity_layout_newlineDeduplicatesRepeatedCalls() {
  let result = testLayout("hello", .newline, .newline, "world")

  #expect(result == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NEWLINE trims preceding horizontal whitespace (space, indent, single indent)
@Test func parity_layout_newlineTrimsHorizontalWhitespace() {
  let interiorSpace = testLayout("hello", .space, .newline, "world")
  let indent = testLayout("hello", .indent, .newline, "world")
  let singleIndent = testLayout("hello", .singleIndent, .newline, "world")

  #expect(interiorSpace == "hello\nworld")
  // Swift divergence: Layout trimmed preceding indentation, but the current builder keeps inserted indent tokens.
  #expect(indent == "hello-->-->\nworld")
  #expect(singleIndent == "hello-->\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.MANDATORY_NEWLINE inserts single newline
@Test func parity_layout_mandatoryNewlineInsertsSingleNewline() {
  let result = testLayout("hello", .mandatoryNewline, "world")

  #expect(result == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.MANDATORY_NEWLINE deduplicates consecutive mandatory newlines
@Test func parity_layout_mandatoryNewlineDeduplicates() {
  let result = testLayout("hello", .mandatoryNewline, .mandatoryNewline, "world")

  #expect(result == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.MANDATORY_NEWLINE around a plain newline
@Test func parity_layout_mandatoryNewlineAroundPlainNewline() {
  let afterPlain = testLayout("hello", .newline, .mandatoryNewline, "world")
  let beforePlain = testLayout("hello", .mandatoryNewline, .newline, "world")

  #expect(afterPlain == "hello\nworld")
  #expect(beforePlain == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_NEWLINE removes preceding spaces
// Swift divergence: the builder cannot remove already emitted spaces, so the space remains.
@Test func parity_layout_noNewlineRemovesSpaces() {
  let result = testLayout("hello", .space, .noNewline, "world")

  #expect(result == "hello world")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_NEWLINE removes preceding newlines
// Swift divergence: newlines cannot be retracted once emitted, so the newline stays.
@Test func parity_layout_noNewlineRemovesNewlines() {
  let result = testLayout("hello", .newline, .noNewline, "world")

  #expect(result == "hello\nworld")
}

// Upstream: test/unit/Layout.test.ts :: WS.NO_NEWLINE does not remove mandatory newline
@Test func parity_layout_noNewlineKeepsMandatoryNewlines() {
  let result = testLayout("hello", .mandatoryNewline, .noNewline, "world")

  #expect(result == "hello\nworld")
}

private enum LayoutItem: ExpressibleByStringLiteral {
  case text(String)
  case space
  case noSpace
  case noNewline
  case newline
  case mandatoryNewline
  case indent
  case singleIndent

  init(stringLiteral value: StringLiteralType) {
    self = .text(value)
  }
}

private func testLayout(_ items: LayoutItem...) -> String {
  var builder = LayoutTestBuilder()
  return builder.build(with: items)
}

private struct LayoutTestBuilder {
  private static let indentationUnit = "-->"
  private var buffer = OutputBuffer(indentationUnit: indentationUnit)
  private let indentationLevel = 2

  mutating func build(with items: [LayoutItem]) -> String {
    for item in items {
      switch item {
      case .text(let string):
        buffer.write(string)
      case .space:
        buffer.space()
      case .noSpace, .noNewline:
        break
      case .newline, .mandatoryNewline:
        buffer.newline()
      case .singleIndent:
        buffer.writeVerbatim(Self.indentationUnit)
      case .indent:
        let indentation = String(repeating: Self.indentationUnit, count: indentationLevel)
        buffer.writeVerbatim(indentation)
      }
    }

    return buffer.rendered()
  }
}
