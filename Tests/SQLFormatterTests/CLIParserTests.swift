import Foundation
import Testing

@testable import SQLFormatter
@testable import SQLFormatterCLICommon

@Test func parserAcceptsLanguageAlias() async throws {
  let options = try SQLFormatterCLIParser.parse(arguments: ["--language", "postgres"])

  #expect(options.dialect == .postgreSQL)
}

@Test func parserLoadsDefaultConfigFileFromCurrentDirectory() async throws {
  let directory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: directory) }

  let configURL = directory.appendingPathComponent(".sql-formatter.json")
  try Data(#"{"language":"postgresql","keywordCase":"upper","indentStyle":"tabularLeft"}"#.utf8)
    .write(to: configURL)

  let options = try SQLFormatterCLIParser.parse(arguments: [], currentDirectory: directory)

  #expect(options.dialect == .postgreSQL)
  #expect(options.keywordCase == .upper)
  #expect(options.indentStyle == .tabularLeft)
}

@Test func parserUsesExplicitConfigAndAllowsArgumentOverrides() async throws {
  let directory = try makeTemporaryDirectory()
  defer { try? FileManager.default.removeItem(at: directory) }

  let configURL = directory.appendingPathComponent("formatter.json")
  try Data(
    #"{"language":"postgresql","tabWidth":4,"linesBetweenQueries":2,"indentStyle":"tabularRight"}"#
      .utf8
  )
  .write(to: configURL)

  let options = try SQLFormatterCLIParser.parse(
    arguments: [
      "--config", configURL.lastPathComponent,
      "--language", "sqlite",
      "--tab-width", "2",
    ],
    currentDirectory: directory
  )

  #expect(options.dialect == .sqlite)
  #expect(options.tabWidth == 2)
  #expect(options.linesBetweenQueries == 2)
  #expect(options.indentStyle == .tabularRight)
}

private func makeTemporaryDirectory() throws -> URL {
  let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  return url
}
