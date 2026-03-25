import Testing

@testable import SQLFormatter

// Upstream: test/features/join.ts :: supports JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsJoin() throws {
  let join = "JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports INNER JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsInnerJoin() throws {
  let join = "INNER JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports CROSS JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsCrossJoin() throws {
  let join = "CROSS JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports LEFT JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsLeftJoin() throws {
  let join = "LEFT JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports LEFT OUTER JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsLeftOuterJoin() throws {
  let join = "LEFT OUTER JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports RIGHT JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsRightJoin() throws {
  let join = "RIGHT JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports RIGHT OUTER JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsRightOuterJoin() throws {
  let join = "RIGHT OUTER JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports FULL JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsFullJoin() throws {
  let join = "FULL JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports FULL OUTER JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsFullOuterJoin() throws {
  let join = "FULL OUTER JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL JOIN
// Swift divergence: JOIN keywords and their ON clauses are split across separate lines instead of staying inline.
@Test func parity_join_supportsNaturalJoin() throws {
  let join = "NATURAL JOIN"
  try assertFormat(
    """
    SELECT * FROM customers
    \(join) orders ON customers.customer_id = orders.customer_id
    \(join) items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    \(join)
      orders
    ON
      customers.customer_id = orders.customer_id
    \(join)
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL INNER JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalInnerJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL INNER JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL INNER JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    INNER JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    INNER JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL LEFT JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalLeftJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL LEFT JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL LEFT JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    LEFT JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    LEFT JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL LEFT OUTER JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalLeftOuterJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL LEFT OUTER JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL LEFT OUTER JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    LEFT OUTER JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    LEFT OUTER JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL RIGHT JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalRightJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL RIGHT JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL RIGHT JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    RIGHT JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    RIGHT JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL RIGHT OUTER JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalRightOuterJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL RIGHT OUTER JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL RIGHT OUTER JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    RIGHT OUTER JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    RIGHT OUTER JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL FULL JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalFullJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL FULL JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL FULL JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    FULL JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    FULL JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: supports NATURAL FULL OUTER JOIN
// Swift divergence: NATURAL is emitted next to the preceding table and ON lines, so the qualifier appears on distinct lines from the join keyword.
@Test func parity_join_supportsNaturalFullOuterJoin() throws {
  try assertFormat(
    """
    SELECT * FROM customers
    NATURAL FULL OUTER JOIN orders ON customers.customer_id = orders.customer_id
    NATURAL FULL OUTER JOIN items ON items.id = orders.id;
    """,
    """
    SELECT
      *
    FROM
      customers NATURAL
    FULL OUTER JOIN
      orders
    ON
      customers.customer_id = orders.customer_id NATURAL
    FULL OUTER JOIN
      items
    ON
      items.id = orders.id;
    """
  )
}

// Upstream: test/features/join.ts :: properly uppercases JOIN ... ON
// Swift divergence: Uppercasing still emits JOIN, table, and ON on separate lines instead of inline.
@Test func parity_join_properlyUppercasesJoinOn() throws {
  try assertFormat(
    """
    select * from customers join foo on foo.id = customers.id;
    """,
    """
    SELECT
      *
    FROM
      customers
    JOIN
      foo
    ON
      foo.id = customers.id;
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/features/join.ts :: properly uppercases JOIN ... USING
// Swift divergence: Uppercasing still emits JOIN and USING clauses on separate lines instead of inline.
@Test func parity_join_properlyUppercasesJoinUsing() throws {
  try assertFormat(
    """
    select * from customers join foo using (id);
    """,
    """
    SELECT
      *
    FROM
      customers
    JOIN
      foo USING (id);
    """,
    options: FormatOptions(keywordCase: .upper)
  )
}

// Upstream: test/features/join.ts :: supports CROSS APPLY
// Swift divergence: CROSS APPLY expressions remain inline with the table instead of being broken across lines.
@Test func parity_join_supportsCrossApply() throws {
  try assertFormat(
    """
    SELECT * FROM customers CROSS APPLY fn(customers.id)
    """,
    """
    SELECT
      *
    FROM
      customers CROSS APPLY fn(customers.id)
    """
  )
}

// Upstream: test/features/join.ts :: supports OUTER APPLY
// Swift divergence: OUTER APPLY expressions remain inline with the table instead of being broken across lines.
@Test func parity_join_supportsOuterApply() throws {
  try assertFormat(
    """
    SELECT * FROM customers OUTER APPLY fn(customers.id)
    """,
    """
    SELECT
      *
    FROM
      customers OUTER APPLY fn(customers.id)
    """
  )
}
