import Testing

@testable import SQLFormatter

private struct DialectFixture {
  let name: String
  let sql: String
  let options: FormatOptions
  let expected: String
}

@Test func formatsDialectFixtures() async throws {
  let fixtures: [DialectFixture] = [
    DialectFixture(
      name: "standard bracket identifier",
      sql: "SELECT [name] FROM [users] WHERE [active] = 1",
      options: FormatOptions(dialect: .standardSQL),
      expected: """
        SELECT
          [name]
        FROM
          [users]
        WHERE
          [active] = 1
        """
    ),
    DialectFixture(
      name: "postgres returning clause",
      sql: "SELECT \"name\" FROM \"users\" RETURNING id",
      options: FormatOptions(dialect: .postgreSQL),
      expected: """
        SELECT
          "name"
        FROM
          "users"
        RETURNING
          id
        """
    ),
    DialectFixture(
      name: "postgres cast and concat",
      sql: "SELECT metadata::jsonb || payload FROM events",
      options: FormatOptions(dialect: .postgreSQL),
      expected: """
        SELECT
          metadata :: jsonb || payload
        FROM
          events
        """
    ),
    DialectFixture(
      name: "transactsql bracket identifiers",
      sql: "SELECT [my column] FROM [my table];",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          [my column]
        FROM
          [my table];
        """
    ),
    DialectFixture(
      name: "transactsql temp and special identifiers",
      sql: "SELECT @bar, #baz, @@some, ##flam FROM tbl;",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          @bar,
          #baz,
          @@some,
          ##flam
        FROM
          tbl;
        """
    ),
    DialectFixture(
      name: "transactsql scope resolution",
      sql: "SELECT hierarchyid :: GetRoot();",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          hierarchyid :: GetRoot();
        """
    ),
    DialectFixture(
      name: "transactsql double dot path",
      sql: "SELECT x FROM db..tbl",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          x
        FROM
          db..tbl
        """
    ),
    DialectFixture(
      name: "transactsql for json",
      sql: "SELECT col FOR JSON PATH, WITHOUT_ARRAY_WRAPPER",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          col FOR JSON PATH,
          WITHOUT_ARRAY_WRAPPER
        """
    ),
    DialectFixture(
      name: "transactsql option clause",
      sql: "SELECT col OPTION (MAXRECURSION 5)",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          col OPTION(MAXRECURSION 5)
        """
    ),
    DialectFixture(
      name: "transactsql into temp table",
      sql: "SELECT col INTO #temp FROM tbl",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          col INTO #temp
        FROM
          tbl
        """
    ),
    DialectFixture(
      name: "transactsql for xml",
      sql: "SELECT col FOR XML PATH('Employee'), ROOT('Employees')",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          col FOR XML PATH('Employee'),
          ROOT('Employees')
        """
    ),
    DialectFixture(
      name: "transactsql for browse",
      sql: "SELECT col FOR BROWSE",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        SELECT
          col FOR BROWSE
        """
    ),
    DialectFixture(
      name: "transactsql goto label",
      sql: "InfiniLoop: SELECT 'Hello.'; GOTO InfiniLoop;",
      options: FormatOptions(dialect: .transactSQL),
      expected: """
        InfiniLoop:
        SELECT
          'Hello.';

        GOTO InfiniLoop;
        """
    ),
    DialectFixture(
      name: "clickhouse typed placeholder",
      sql: "SELECT {foo:Uint64};",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SELECT
          {foo:Uint64};
        """
    ),
    DialectFixture(
      name: "clickhouse lambda function",
      sql: "SELECT arrayMap(x->2*x, [1,2,3]) AS result;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SELECT
          arrayMap(x -> 2 * x,
          [1,2,3]) AS result;
        """
    ),
    DialectFixture(
      name: "clickhouse map literal",
      sql: "SELECT {'foo':1,'bar':10};",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SELECT
          { 'foo' :1,
          'bar' :10};
        """
    ),
    DialectFixture(
      name: "clickhouse columns function",
      sql: "SELECT COLUMNS('a') FROM col_names",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SELECT
          COLUMNS('a')
        FROM
          col_names
        """
    ),
    DialectFixture(
      name: "clickhouse insert with cte after insert",
      sql: "INSERT INTO x WITH y AS (SELECT * FROM numbers(10)) SELECT * FROM y;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        INSERT INTO x
        WITH
          y AS (
        SELECT
          *
        FROM
          numbers(10))
        SELECT
          *
        FROM
          y;
        """
    ),
    DialectFixture(
      name: "clickhouse with before insert",
      sql: "WITH y AS (SELECT * FROM numbers(10)) INSERT INTO x SELECT * FROM y;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        WITH
          y AS (
        SELECT
          *
        FROM
          numbers(10))
        INSERT INTO x
        SELECT
          *
        FROM
          y;
        """
    ),
    DialectFixture(
      name: "clickhouse drop database cluster sync",
      sql: "DROP DATABASE IF EXISTS db ON CLUSTER my_cluster SYNC;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        DROP DATABASE IF EXISTS db
        ON
          CLUSTER my_cluster SYNC;
        """
    ),
    DialectFixture(
      name: "clickhouse system drop replica zkpath",
      sql:
        "SYSTEM DROP REPLICA 'replica1' FROM ZKPATH '/clickhouse/tables/01/mydb/my_replicated_table';",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SYSTEM DROP REPLICA 'replica1'
        FROM
          ZKPATH '/clickhouse/tables/01/mydb/my_replicated_table';
        """
    ),
    DialectFixture(
      name: "clickhouse materialized view refresh",
      sql: "CREATE MATERIALIZED VIEW mv1 REFRESH EVERY 1 HOUR AS SELECT * FROM source_table;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        CREATE MATERIALIZED VIEW mv1 REFRESH EVERY 1 HOUR AS
        SELECT
          *
        FROM
          source_table;
        """
    ),
    DialectFixture(
      name: "clickhouse rename column",
      sql: "ALTER TABLE supplier RENAME COLUMN supplier_id TO id;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        ALTER TABLE supplier RENAME COLUMN supplier_id TO id;
        """
    ),
    DialectFixture(
      name: "clickhouse show create table",
      sql: "SHOW CREATE TABLE db.table INTO OUTFILE 'file.txt' FORMAT CSV;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SHOW CREATE TABLE db.table INTO OUTFILE 'file.txt' FORMAT CSV;
        """
    ),
    DialectFixture(
      name: "clickhouse explain ast",
      sql:
        "EXPLAIN AST SELECT sum(number) FROM numbers(10) UNION ALL SELECT sum(number) FROM numbers(10) ORDER BY sum(number) ASC FORMAT TSV;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        EXPLAIN AST
        SELECT
          sum(number)
        FROM
          numbers(10) UNION ALL
        SELECT
          sum(number)
        FROM
          numbers(10)
        ORDER BY
          sum(number) ASC FORMAT TSV;
        """
    ),
    DialectFixture(
      name: "clickhouse optimize table",
      sql: "OPTIMIZE TABLE logs ON CLUSTER prod DEDUPLICATE BY user_id, timestamp;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        OPTIMIZE TABLE logs
        ON
          CLUSTER prod DEDUPLICATE BY user_id,
          timestamp;
        """
    ),
    DialectFixture(
      name: "clickhouse set role all except",
      sql: "SET ROLE ALL EXCEPT guest, readonly;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SET ROLE ALL EXCEPT guest,
        readonly;
        """
    ),
    DialectFixture(
      name: "clickhouse grant privileges",
      sql: "GRANT SELECT, INSERT ON db.tbl TO user;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        GRANT
          SELECT,
          INSERT
        ON
          db.tbl
        TO
          user;
        """
    ),
    DialectFixture(
      name: "clickhouse revoke privileges",
      sql: "REVOKE SELECT ON db.tbl FROM user;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        REVOKE
          SELECT
        ON
          db.tbl
        FROM
          user;
        """
    ),
    DialectFixture(
      name: "clickhouse system stop merges",
      sql: "SYSTEM STOP MERGES ON CLUSTER prod;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SYSTEM STOP MERGES
        ON
          CLUSTER prod;
        """
    ),
    DialectFixture(
      name: "clickhouse settings clause",
      sql: "SELECT * FROM some_table SETTINGS optimize_read_in_order=1, cast_keep_nullable=1;",
      options: FormatOptions(dialect: .clickHouse),
      expected: """
        SELECT
          *
        FROM
          some_table SETTINGS optimize_read_in_order = 1,
          cast_keep_nullable = 1;
        """
    ),
  ]

  for fixture in fixtures {
    let result = try format(fixture.sql, options: fixture.options)
    #expect(result == fixture.expected, Comment(rawValue: fixture.name))
  }
}
