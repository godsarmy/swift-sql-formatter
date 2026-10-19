import Foundation
import Testing

@testable import SQLFormatter

private struct Upstream159Fixture: Decodable {
  struct Options: Decodable {
    var denseOperators: Bool?
    var keywordCase: String?
    var functionCase: String?
    var dataTypeCase: String?
    var identifierCase: String?
  }

  var name: String
  var sql: String
  var language: String
  var options: Options
  var expected: String
  var upstreamExpected: String
  var divergence: String?
}

private func fixtureCase(_ value: String?) -> KeywordCase {
  switch value {
  case "upper": return .upper
  case "lower": return .lower
  default: return .preserve
  }
}

// Captured from npm sql-formatter@15.9.0. Differences from upstream are explicit in the fixture.
@Test func upstream159_regressionFixtures() throws {
  let url = try #require(Bundle.module.url(forResource: "upstream-15.9.0", withExtension: "json"))
  let fixtures = try JSONDecoder().decode([Upstream159Fixture].self, from: Data(contentsOf: url))
  for fixture in fixtures {
    let dialect = try #require(DialectRegistry.dialect(named: fixture.language))
    let options = FormatOptions(
      dialect: dialect,
      keywordCase: fixtureCase(fixture.options.keywordCase),
      functionCase: fixtureCase(fixture.options.functionCase),
      dataTypeCase: fixtureCase(fixture.options.dataTypeCase),
      identifierCase: fixtureCase(fixture.options.identifierCase),
      denseOperators: fixture.options.denseOperators ?? false
    )
    let actual = try format(fixture.sql, options: options)
    #expect(actual == fixture.expected, "\(fixture.name)")
    #expect(try format(actual, options: options) == actual, "Idempotency: \(fixture.name)")
    if fixture.divergence == nil {
      #expect(
        fixture.expected == fixture.upstreamExpected, "Undocumented divergence: \(fixture.name)")
    }
  }
}

@Test func upstream159_sqliteTclParameterReplacement() throws {
  let options = FormatOptions(
    dialect: .sqlite,
    params: .named(["foo::bar(extra)": "42", "p(x=y)": "'value'", "name": "'John'"])
  )
  #expect(
    try format("SELECT $foo::bar(extra), $p(x=y), $name;", options: options)
      == "SELECT\n  42,\n  'value',\n  'John';")
}

@Test func upstream159_aliasDoesNotConsumeFollowingStatementClause() throws {
  #expect(try format("UPDATE tbl AS set SET x = 1;") == "UPDATE tbl AS set\nSET\n  x = 1;")
  #expect(
    try format("CREATE TABLE t AS SELECT id FROM tbl;")
      == "CREATE TABLE t AS\nSELECT\n  id\nFROM\n  tbl;")
  let options = FormatOptions(keywordCase: .upper, identifierCase: .lower)
  #expect(
    try format("select ID as SET from T;", options: options)
      == "SELECT\n  id AS set\nFROM\n  t;")
}

@Test func upstream159_aliasAcrossComments() throws {
  // Existing Swift comment layout is retained; SET must still be treated as an identifier.
  let result = try format("SELECT id AS /* alias */ set FROM tbl;")
  #expect(result == "SELECT\n  id AS\n/* alias */\nset\nFROM\n  tbl;")
}

@Test func upstream159_commentPlacementIsIdempotent() throws {
  // Standalone Swift comment layout differs from upstream and is intentionally retained.
  let inputs = [
    "SELECT /* comment */ foo FROM tbl",
    "SELECT foo /* c */, /* c */ bar FROM /* c */ tbl1 JOIN /* c */ tbl2",
    "CREATE TABLE /* c */ tbl (/* c */ id INT, /* c */ first_name TEXT, last_name TEXT)",
  ]
  for sql in inputs {
    let result = try format(sql)
    #expect(try format(result) == result)
  }
}

@Test func upstream159_betweenDoesNotDuplicateSpaces() throws {
  // Existing Swift BETWEEN/CASE line breaking is retained.
  let result = try format("SELECT CASE WHEN foo BETWEEN 1 AND 2 THEN 3 END")
  #expect(result == "SELECT\n  CASE WHEN foo BETWEEN 1\n  AND 2 THEN 3 END")
}

@Test func upstream159_tokenLocationsAfterUnicodeAndCRLF() throws {
  let tokens = try Tokenizer(dialect: .postgreSQL).tokenize("SELECT café\r\nFROM t")
  let from = try #require(tokens.first { $0.text == "FROM" })
  #expect(from.location.line == 2)
  #expect(from.location.column == 1)
  #expect(from.location.offset == 13)
}

@Test func upstream159_longExpressionList() throws {
  let columns = (0..<2000).map { "col\($0)" }
  let result = try format("SELECT " + columns.joined(separator: ",") + " FROM tbl;")
  #expect(result == "SELECT\n  " + columns.joined(separator: ",\n  ") + "\nFROM\n  tbl;")
}
