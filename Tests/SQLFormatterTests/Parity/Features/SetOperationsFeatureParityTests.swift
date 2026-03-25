import Testing

@testable import SQLFormatter

// Upstream: test/features/setOperations.ts :: formats UNION
@Test func parity_setOperations_formatsUnion() throws {
  try assertSetOperation("UNION")
}

// Upstream: test/features/setOperations.ts :: formats UNION inside subquery
@Test func parity_setOperations_formatsUnionInsideSubquery() throws {
  try assertSetOperationInsideSubquery("UNION")
}

// Upstream: test/features/setOperations.ts :: formats UNION ALL
@Test func parity_setOperations_formatsUnionAll() throws {
  try assertSetOperation("UNION ALL")
}

// Upstream: test/features/setOperations.ts :: formats UNION ALL inside subquery
@Test func parity_setOperations_formatsUnionAllInsideSubquery() throws {
  try assertSetOperationInsideSubquery("UNION ALL")
}

// Upstream: test/features/setOperations.ts :: formats UNION DISTINCT
@Test func parity_setOperations_formatsUnionDistinct() throws {
  try assertSetOperation("UNION DISTINCT")
}

// Upstream: test/features/setOperations.ts :: formats UNION DISTINCT inside subquery
@Test func parity_setOperations_formatsUnionDistinctInsideSubquery() throws {
  try assertSetOperationInsideSubquery("UNION DISTINCT")
}

// Upstream: test/features/setOperations.ts :: formats EXCEPT
@Test func parity_setOperations_formatsExcept() throws {
  try assertSetOperation("EXCEPT")
}

// Upstream: test/features/setOperations.ts :: formats EXCEPT inside subquery
@Test func parity_setOperations_formatsExceptInsideSubquery() throws {
  try assertSetOperationInsideSubquery("EXCEPT")
}

// Upstream: test/features/setOperations.ts :: formats EXCEPT ALL
@Test func parity_setOperations_formatsExceptAll() throws {
  try assertSetOperation("EXCEPT ALL")
}

// Upstream: test/features/setOperations.ts :: formats EXCEPT ALL inside subquery
@Test func parity_setOperations_formatsExceptAllInsideSubquery() throws {
  try assertSetOperationInsideSubquery("EXCEPT ALL")
}

// Upstream: test/features/setOperations.ts :: formats EXCEPT DISTINCT
@Test func parity_setOperations_formatsExceptDistinct() throws {
  try assertSetOperation("EXCEPT DISTINCT")
}

// Upstream: test/features/setOperations.ts :: formats EXCEPT DISTINCT inside subquery
@Test func parity_setOperations_formatsExceptDistinctInsideSubquery() throws {
  try assertSetOperationInsideSubquery("EXCEPT DISTINCT")
}

// Upstream: test/features/setOperations.ts :: formats INTERSECT
@Test func parity_setOperations_formatsIntersect() throws {
  try assertSetOperation("INTERSECT")
}

// Upstream: test/features/setOperations.ts :: formats INTERSECT inside subquery
@Test func parity_setOperations_formatsIntersectInsideSubquery() throws {
  try assertSetOperationInsideSubquery("INTERSECT")
}

// Upstream: test/features/setOperations.ts :: formats INTERSECT ALL
@Test func parity_setOperations_formatsIntersectAll() throws {
  try assertSetOperation("INTERSECT ALL")
}

// Upstream: test/features/setOperations.ts :: formats INTERSECT ALL inside subquery
@Test func parity_setOperations_formatsIntersectAllInsideSubquery() throws {
  try assertSetOperationInsideSubquery("INTERSECT ALL")
}

// Upstream: test/features/setOperations.ts :: formats INTERSECT DISTINCT
@Test func parity_setOperations_formatsIntersectDistinct() throws {
  try assertSetOperation("INTERSECT DISTINCT")
}

// Upstream: test/features/setOperations.ts :: formats INTERSECT DISTINCT inside subquery
@Test func parity_setOperations_formatsIntersectDistinctInsideSubquery() throws {
  try assertSetOperationInsideSubquery("INTERSECT DISTINCT")
}

// Swift divergence: Swift keeps set operators inline with the preceding clause instead of forcing them onto their own lines.
private func assertSetOperation(_ operation: String) throws {
  try assertFormat(
    """
    SELECT * FROM foo \(operation) SELECT * FROM bar;
    """,
    """
    SELECT
      *
    FROM
      foo \(operation)
    SELECT
      *
    FROM
      bar;
    """
  )
}

// Swift divergence: Subquery bodies keep minimal indentation and operators stay inline as part of the surrounding clause.
private func assertSetOperationInsideSubquery(_ operation: String) throws {
  try assertFormat(
    """
    SELECT * FROM (SELECT * FROM foo \(operation) SELECT * FROM bar) AS tbl;
    """,
    """
    SELECT
      *
    FROM
      (
    SELECT
      *
    FROM
      foo \(operation)
    SELECT
      *
    FROM
      bar) AS tbl;
    """
  )
}
