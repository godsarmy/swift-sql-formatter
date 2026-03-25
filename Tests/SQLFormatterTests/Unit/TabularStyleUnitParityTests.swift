import Testing

@testable import SQLFormatter

// Upstream: test/unit/tabularStyle.test.ts :: does nothing in standard style
@Test func parity_tabularStyle_standardStyleDoesNothing() throws {
  let fromLine = try clauseLine(startingWith: "FROM", from: "SELECT id FROM users")
  #expect(fromLine == "FROM")

  let joinLine = try clauseLine(
    startingWith: "INNER JOIN",
    from: "SELECT id FROM users INNER JOIN teams ON users.team_id = teams.id"
  )
  #expect(joinLine == "INNER JOIN")

  let insertLine = try clauseLine(
    startingWith: "INSERT INTO",
    from: "INSERT INTO users SELECT id FROM archived_users"
  )
  #expect(insertLine == "INSERT INTO users")
}

// Upstream: test/unit/tabularStyle.test.ts :: formats in tabularLeft style
// Swift divergence: tabular padding keeps multi-word keywords intact, so INNER JOIN and INSERT INTO retain their inter-word spaces while clause text is padded via trailing whitespace instead of spreading spaces between words.
@Test func parity_tabularStyle_tabularLeftPadsKeywords() throws {
  let options = FormatOptions(indentStyle: .tabularLeft)

  let fromLine = try clauseLine(
    startingWith: "FROM",
    from: "SELECT id FROM users",
    options: options
  )
  #expect(fromLine.hasPrefix("FROM      "))
  #expect(fromLine.hasSuffix("users"))

  let joinLine = try clauseLine(
    startingWith: "INNER JOIN",
    from: "SELECT id FROM users INNER JOIN teams ON users.team_id = teams.id",
    options: options
  )
  #expect(joinLine.hasPrefix("INNER JOIN "))
  #expect(joinLine.hasSuffix("teams"))

  let insertLine = try clauseLine(
    startingWith: "INSERT INTO",
    from: "INSERT INTO users SELECT id FROM archived_users",
    options: options
  )
  #expect(insertLine.hasPrefix("INSERT INTO "))
  #expect(insertLine.hasSuffix("users"))
}

// Upstream: test/unit/tabularStyle.test.ts :: formats in tabularRight style
// Swift divergence: tabular padding keeps multi-word keywords intact, so INNER JOIN and INSERT INTO retain their inter-word spaces while clause padding is applied through leading/trailing whitespace.
@Test func parity_tabularStyle_tabularRightPadsKeywords() throws {
  let options = FormatOptions(indentStyle: .tabularRight)

  let fromLine = try clauseLine(
    startingWith: "FROM",
    from: "SELECT id FROM users",
    options: options
  )
  #expect(fromLine.hasPrefix("     FROM "))
  #expect(fromLine.hasSuffix("users"))

  let joinLine = try clauseLine(
    startingWith: "INNER JOIN",
    from: "SELECT id FROM users INNER JOIN teams ON users.team_id = teams.id",
    options: options
  )
  #expect(joinLine.hasPrefix("INNER JOIN "))
  #expect(joinLine.hasSuffix("teams"))

  let insertLine = try clauseLine(
    startingWith: "INSERT INTO",
    from: "INSERT INTO users SELECT id FROM archived_users",
    options: options
  )
  #expect(insertLine.hasPrefix("INSERT INTO "))
  #expect(insertLine.hasSuffix("users"))
}

private func clauseLine(
  startingWith keyword: String,
  from sql: String,
  options: FormatOptions = .default
) throws -> String {
  let formatted = try format(sql, options: options)
  for line in formatted.split(separator: "\n") {
    if line.trimmingCharacters(in: .whitespaces).hasPrefix(keyword) {
      return String(line)
    }
  }
  fatalError("Missing clause line for \(keyword)")
}
