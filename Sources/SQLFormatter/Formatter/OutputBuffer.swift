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

  mutating func newline(count: Int = 1) {
    guard !output.isEmpty else {
      return
    }

    if output.hasSuffix(" ") {
      output.removeLast()
    }

    let trailingNewlines = output.reversed().prefix { $0 == "\n" }.count
    let missingNewlines = max(0, count - trailingNewlines)
    if missingNewlines > 0 {
      output += String(repeating: "\n", count: missingNewlines)
    }

    isLineStart = true
  }

  mutating func indent() {
    indentLevel += 1
  }

  mutating func outdent() {
    indentLevel = max(0, indentLevel - 1)
  }

  var currentLineLength: Int {
    if let lineStart = output.lastIndex(of: "\n") {
      return output.distance(from: output.index(after: lineStart), to: output.endIndex)
    }

    return output.count
  }

  func rendered() -> String {
    output.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
