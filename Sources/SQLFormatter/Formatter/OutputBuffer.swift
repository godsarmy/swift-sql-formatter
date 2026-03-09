import Foundation

struct OutputBuffer {
  let indentationUnit: String

  private(set) var output = ""
  private var indentLevel = 0
  private var isLineStart = true

  init(indentationUnit: String) {
    self.indentationUnit = indentationUnit
  }

  mutating func write(_ text: String) {
    guard !text.isEmpty else {
      return
    }

    if isLineStart {
      output += String(repeating: indentationUnit, count: indentLevel)
      isLineStart = false
    }

    output += text
  }

  mutating func space() {
    guard !output.isEmpty, !output.hasSuffix(" "), !output.hasSuffix("\n") else {
      return
    }

    output += " "
  }

  mutating func newline() {
    guard !output.isEmpty else {
      return
    }

    if output.hasSuffix(" ") {
      output.removeLast()
    }

    if !output.hasSuffix("\n") {
      output += "\n"
    }

    isLineStart = true
  }

  mutating func indent() {
    indentLevel += 1
  }

  mutating func outdent() {
    indentLevel = max(0, indentLevel - 1)
  }

  func rendered() -> String {
    output.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
