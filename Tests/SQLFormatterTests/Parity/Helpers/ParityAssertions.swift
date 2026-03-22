import Foundation
import Testing

@testable import SQLFormatter

func dedent(_ text: String) -> String {
  let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

  var start = 0
  while start < lines.count && lines[start].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  {
    start += 1
  }

  var end = lines.count
  while end > start && lines[end - 1].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
    end -= 1
  }

  if start >= end {
    return ""
  }

  let core = Array(lines[start..<end])
  let minimumIndent =
    core
    .compactMap { line -> Int? in
      if line.trimmingCharacters(in: .whitespaces).isEmpty {
        return nil
      }

      return line.prefix { char in
        char == " " || char == "\t"
      }.count
    }
    .min() ?? 0

  return
    core
    .map { line in
      guard minimumIndent > 0 else {
        return line
      }

      var index = line.startIndex
      var removed = 0
      while removed < minimumIndent && index < line.endIndex {
        let char = line[index]
        if char != " " && char != "\t" {
          break
        }

        index = line.index(after: index)
        removed += 1
      }

      return String(line[index...])
    }
    .joined(separator: "\n")
}

func assertFormat(_ sql: String, _ expected: String, options: FormatOptions = .default) throws {
  let result = try format(sql, options: options)
  #expect(result == dedent(expected))
}

func assertFormatDialect(
  _ sql: String,
  dialect: Dialect,
  _ expected: String,
  options: FormatOptions = .default
) throws {
  let result = try formatDialect(sql, dialect: dialect, options: options)
  #expect(result == dedent(expected))
}

func assertFormatError(_ sql: String, options: FormatOptions = .default, contains text: String) {
  do {
    _ = try format(sql, options: options)
    Issue.record("Expected format() to throw")
  } catch let error as FormatError {
    switch error {
    case .unsupportedFeature(let message):
      #expect(message.contains(text))
    default:
      #expect(String(describing: error).contains(text))
    }
  } catch {
    #expect(String(describing: error).contains(text))
  }
}
