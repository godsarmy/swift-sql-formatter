import Testing

@testable import SQLFormatter

@Test func formatReturnsOriginalSQLForCurrentScaffold() async throws {
  let sql = "SELECT * FROM people"

  let result = try format(sql)

  #expect(result == sql)
}

@Test func defaultDialectIsStandardSQL() async throws {
  let options = FormatOptions.default

  #expect(options.dialect == .standardSQL)
  #expect(options.tabWidth == 2)
  #expect(options.useTabs == false)
  #expect(options.linesBetweenQueries == 1)
}
