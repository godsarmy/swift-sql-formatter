import Testing

@testable import SQLFormatter

private func constraintsFixture(action: String) -> String {
  """
  CREATE TABLE foo (
    update_time datetime ON UPDATE \(action),
    delete_time datetime ON DELETE \(action),
  );
  """
}

private func constraintsExpectedOutput(action: String) -> String {
  switch action {
  case "SET NULL":
    return """
      CREATE TABLE foo( update_time datetime
      ON
      UPDATE
      SET
        NULL,
        delete_time datetime
      ON
        DELETE
      SET
        NULL,
        );
      """
  default:
    return """
      CREATE TABLE foo( update_time datetime
      ON
      UPDATE \(action),
      delete_time datetime
      ON
        DELETE \(action),
        );
      """
  }
}

// Upstream: test/features/constraints.ts :: treats ON UPDATE & ON DELETE RESTRICT as distinct keywords from ON
// Swift divergence: ON/UPDATE and ON/DELETE keywords currently break across lines.
@Test func parity_constraints_treatsOnUpdateOnDeleteRestrictAsDistinctKeywordsFromOn() throws {
  let sql = constraintsFixture(action: "RESTRICT")
  let expected = constraintsExpectedOutput(action: "RESTRICT")
  try assertFormat(sql, expected)
}

// Upstream: test/features/constraints.ts :: treats ON UPDATE & ON DELETE CASCADE as distinct keywords from ON
// Swift divergence: ON/UPDATE and ON/DELETE keywords currently break across lines.
@Test func parity_constraints_treatsOnUpdateOnDeleteCascadeAsDistinctKeywordsFromOn() throws {
  let sql = constraintsFixture(action: "CASCADE")
  let expected = constraintsExpectedOutput(action: "CASCADE")
  try assertFormat(sql, expected)
}

// Upstream: test/features/constraints.ts :: treats ON UPDATE & ON DELETE SET NULL as distinct keywords from ON
// Swift divergence: ON/UPDATE/DELETE and SET NULL tokens currently split across lines.
@Test func parity_constraints_treatsOnUpdateOnDeleteSetNullAsDistinctKeywordsFromOn() throws {
  let sql = constraintsFixture(action: "SET NULL")
  let expected = constraintsExpectedOutput(action: "SET NULL")
  try assertFormat(sql, expected)
}

// Upstream: test/features/constraints.ts :: treats ON UPDATE & ON DELETE NO ACTION as distinct keywords from ON
// Swift divergence: ON/UPDATE and ON/DELETE keywords currently break across lines.
@Test func parity_constraints_treatsOnUpdateOnDeleteNoActionAsDistinctKeywordsFromOn() throws {
  let sql = constraintsFixture(action: "NO ACTION")
  let expected = constraintsExpectedOutput(action: "NO ACTION")
  try assertFormat(sql, expected)
}

// Upstream: test/features/constraints.ts :: treats ON UPDATE & ON DELETE NOW as distinct keywords from ON
// Swift divergence: ON/UPDATE and ON/DELETE keywords currently break across lines.
@Test func parity_constraints_treatsOnUpdateOnDeleteNowAsDistinctKeywordsFromOn() throws {
  let sql = constraintsFixture(action: "NOW")
  let expected = constraintsExpectedOutput(action: "NOW")
  try assertFormat(sql, expected)
}

// Upstream: test/features/constraints.ts :: treats ON UPDATE & ON DELETE CURRENT_TIMESTAMP as distinct keywords from ON
// Swift divergence: ON/UPDATE and ON/DELETE keywords currently break across lines.
@Test func parity_constraints_treatsOnUpdateOnDeleteCurrentTimestampAsDistinctKeywordsFromOn()
  throws
{
  let sql = constraintsFixture(action: "CURRENT_TIMESTAMP")
  let expected = constraintsExpectedOutput(action: "CURRENT_TIMESTAMP")
  try assertFormat(sql, expected)
}
