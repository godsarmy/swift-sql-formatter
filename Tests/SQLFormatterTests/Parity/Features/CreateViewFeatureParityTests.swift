import Testing

@testable import SQLFormatter

// Upstream: test/features/createView.ts :: formats CREATE VIEW
@Test func parity_createView_formatsCreateView() throws {
  try assertFormat(
    "CREATE VIEW my_view AS SELECT id, fname, lname FROM tbl;",
    """
      CREATE VIEW my_view AS
      SELECT
        id,
        fname,
        lname
      FROM
        tbl;
    """
  )
}

// Swift divergence: column lists stay adjacent to the view name (no space before '(') and split each column onto its own line without extra indentation.
// Upstream: test/features/createView.ts :: formats CREATE VIEW with columns
@Test func parity_createView_formatsCreateViewWithColumns() throws {
  try assertFormat(
    "CREATE VIEW my_view (id, fname, lname) AS SELECT * FROM tbl;",
    """
      CREATE VIEW my_view(id,
      fname,
      lname) AS
      SELECT
        *
      FROM
        tbl;
    """
  )
}

// Upstream: test/features/createView.ts :: formats CREATE OR REPLACE VIEW
@Test func parity_createView_formatsCreateOrReplaceView() throws {
  try assertFormat(
    "CREATE OR REPLACE VIEW v1 AS SELECT 42;",
    """
      CREATE OR REPLACE VIEW v1 AS
      SELECT
        42;
    """
  )
}

// Upstream: test/features/createView.ts :: formats CREATE MATERIALIZED VIEW
@Test func parity_createView_formatsMaterializedView() throws {
  try assertFormat(
    "CREATE MATERIALIZED VIEW mat_view AS SELECT 42;",
    """
      CREATE MATERIALIZED VIEW mat_view AS
      SELECT
        42;
    """
  )
}

// Upstream: test/features/createView.ts :: formats short CREATE VIEW IF NOT EXISTS
@Test func parity_createView_formatsCreateViewIfNotExists() throws {
  try assertFormat(
    "CREATE VIEW IF NOT EXISTS my_view AS SELECT 42;",
    """
      CREATE VIEW IF NOT EXISTS my_view AS
      SELECT
        42;
    """
  )
}
