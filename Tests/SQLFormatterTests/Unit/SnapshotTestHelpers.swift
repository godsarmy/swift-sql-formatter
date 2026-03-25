import Foundation

@testable import SQLFormatter

struct FixtureTokenSnapshot: Equatable {
  let type: TokenType
  let text: String
}

func fixtureTokenSnapshots(from tokens: [Token]) -> [FixtureTokenSnapshot] {
  tokens.map { FixtureTokenSnapshot(type: $0.type, text: $0.text) }
}

func tokenizeFixtureSQL(_ sql: String, dialect: Dialect = .standardSQL) throws -> [Token] {
  try Tokenizer(dialect: dialect).tokenize(sql)
}

private func fixturesRootURL() -> URL {
  URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("Tests/SQLFormatterTests/Fixtures")
}

func loadFixtureSQL(named name: String, directory: String) throws -> String {
  let fixtureURL = fixturesRootURL().appendingPathComponent(directory).appendingPathComponent(name)
  return try String(contentsOf: fixtureURL, encoding: .utf8)
}
