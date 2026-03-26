# Upstream Test Inventory (Frozen Baseline)

- Upstream repo: `https://github.com/sql-formatter-org/sql-formatter`
- Upstream commit: `a9849494212c0a61fb6b0c1461db84e93ab2ac96`
- Imported by: Swift `SQLFormatter` parity test effort

## Status Legend

- `DONE`: Ported to Swift parity tests
- `PENDING`: Not ported yet
- `N/A`: Not applicable to Swift API/runtime

## Phase 0 Harness

- `DONE` Added `Tests/SQLFormatterTests/Parity/Helpers/ParityAssertions.swift`
- `DONE` Added this inventory lock file
- `DONE` Enforce upstream file + case title traceability in each parity test comment

## Options Suites

- `DONE` `test/options/keywordCase.ts` -> `Tests/SQLFormatterTests/Parity/Options/KeywordCaseParityTests.swift` (5/6 cases ported, 1 skipped due to divergence)
- `DONE` `test/options/dataTypeCase.ts` -> `Tests/SQLFormatterTests/Parity/Options/DataTypeCaseParityTests.swift`
- `DONE` `test/options/expressionWidth.ts` -> `Tests/SQLFormatterTests/Parity/Options/ExpressionWidthParityTests.swift`
- `DONE` `test/options/functionCase.ts` -> `Tests/SQLFormatterTests/Parity/Options/FunctionCaseParityTests.swift`
- `DONE` `test/options/identifierCase.ts` -> `Tests/SQLFormatterTests/Parity/Options/IdentifierCaseParityTests.swift`
- `DONE` `test/options/indentStyle.ts` -> `Tests/SQLFormatterTests/Parity/Options/IndentStyleParityTests.swift`
- `DONE` `test/options/param.ts` -> `Tests/SQLFormatterTests/Parity/Options/ParamParityTests.swift`
- `DONE` `test/options/paramTypes.ts` -> `Tests/SQLFormatterTests/Parity/Options/ParamTypesParityTests.swift`
- `DONE` `test/options/tabWidth.ts` -> `Tests/SQLFormatterTests/Parity/Options/TabWidthParityTests.swift`
- `DONE` `test/options/useTabs.ts` -> `Tests/SQLFormatterTests/Parity/Options/UseTabsParityTests.swift`
- `DONE` `test/options/linesBetweenQueries.ts` -> `Tests/SQLFormatterTests/Parity/Options/LinesBetweenQueriesParityTests.swift`
- `DONE` `test/options/logicalOperatorNewline.ts` -> `Tests/SQLFormatterTests/Parity/Options/LogicalOperatorNewlineParityTests.swift`
- `DONE` `test/options/newlineBeforeSemicolon.ts` -> `Tests/SQLFormatterTests/Parity/Options/NewlineBeforeSemicolonParityTests.swift`

## Shared Behavior Suites

- `DONE` `test/behavesLikeSqlFormatter.ts` -> `Tests/SQLFormatterTests/Parity/Helpers/SqlFormatterBehaviorParityTests.swift` (15/16 tests, 1 skipped)
- `DONE` `test/behavesLikePostgresqlFormatter.ts` -> `Tests/SQLFormatterTests/Parity/Helpers/PostgresqlBehaviorParityTests.swift` (PostgreSQL/DuckDB shared assertions; imported feature/option suites tracked separately)
- `DONE` `test/behavesLikeMariaDbFormatter.ts` -> `Tests/SQLFormatterTests/Parity/Helpers/MariaDbBehaviorParityTests.swift` (MariaDB/MySQL shared assertions; imported feature/option suites tracked separately)
- `DONE` `test/behavesLikeDb2Formatter.ts` -> `Tests/SQLFormatterTests/Parity/Helpers/Db2BehaviorParityTests.swift` (DB2/DB2i shared assertions; imported feature/option suites tracked separately)

## Feature Suites

- `DONE` `test/features/between.ts` -> `Tests/SQLFormatterTests/Parity/Features/BetweenFeatureParityTests.swift`
- `DONE` `test/features/alterTable.ts` -> `Tests/SQLFormatterTests/Parity/Features/AlterTableFeatureParityTests.swift` (5 cases ported)
- `DONE` `test/features/arrayAndMapAccessors.ts` -> `Tests/SQLFormatterTests/Parity/Features/ArrayAndMapAccessorsFeatureParityTests.swift` (7 cases ported)
- `DONE` `test/features/arrayLiterals.ts` -> `Tests/SQLFormatterTests/Parity/Features/ArrayLiteralsFeatureParityTests.swift` (5 cases ported)
- `DONE` `test/features/case.ts` -> `Tests/SQLFormatterTests/Parity/Features/CaseFeatureParityTests.swift` (13/13 upstream cases ported with documented divergences)
- `DONE` `test/features/commentOn.ts` -> `Tests/SQLFormatterTests/Parity/Features/CommentOnFeatureParityTests.swift` (2 cases ported)
- `DONE` `test/features/comments.ts` -> `Tests/SQLFormatterTests/Parity/Features/CommentsFeatureParityTests.swift` (22/22 upstream cases ported)
- `DONE` `test/features/constraints.ts` -> `Tests/SQLFormatterTests/Parity/Features/ConstraintsFeatureParityTests.swift` (6 cases ported)
- `DONE` `test/features/deleteFrom.ts` -> `Tests/SQLFormatterTests/Parity/Features/DeleteFromFeatureParityTests.swift` (2/2 upstream cases ported)
- `DONE` `test/features/join.ts` -> `Tests/SQLFormatterTests/Parity/Features/JoinFeatureParityTests.swift` (21 cases ported)
- `DONE` `test/features/disableComment.ts` -> `Tests/SQLFormatterTests/Parity/Features/DisableCommentFeatureParityTests.swift`
- `DONE` `test/features/createTable.ts` -> `Tests/SQLFormatterTests/Parity/Features/CreateTableFeatureParityTests.swift` (7 cases ported with documented divergences)
- `DONE` `test/features/createView.ts` -> `Tests/SQLFormatterTests/Parity/Features/CreateViewFeatureParityTests.swift` (5 cases ported with documented divergence on column spacing)
- `DONE` `test/features/dropTable.ts` -> `Tests/SQLFormatterTests/Parity/Features/DropTableFeatureParityTests.swift` (2 cases ported)
- `DONE` `test/features/with.ts` -> `Tests/SQLFormatterTests/Parity/Features/WithFeatureParityTests.swift`
- `DONE` `test/features/strings.ts` -> `Tests/SQLFormatterTests/Parity/Features/StringsFeatureParityTests.swift` (34 cases ported with known divergences)
- `DONE` `test/features/identifiers.ts` -> `Tests/SQLFormatterTests/Parity/Features/IdentifiersFeatureParityTests.swift` (17 cases ported with documented divergences)
- `DONE` `test/features/isDistinctFrom.ts` -> `Tests/SQLFormatterTests/Parity/Features/IsDistinctFromFeatureParityTests.swift` (1 case ported)
- `DONE` `test/features/limiting.ts` -> `Tests/SQLFormatterTests/Parity/Features/LimitingFeatureParityTests.swift` (9 cases ported with documented divergences)
- `DONE` `test/features/mergeInto.ts` -> `Tests/SQLFormatterTests/Parity/Features/MergeIntoFeatureParityTests.swift` (1 case ported)
- `DONE` `test/features/numbers.ts` -> `Tests/SQLFormatterTests/Parity/Features/NumbersFeatureParityTests.swift` (6 cases ported)
- `DONE` `test/features/onConflict.ts` -> `Tests/SQLFormatterTests/Parity/Features/OnConflictFeatureParityTests.swift` (1 case ported)
- `DONE` `test/features/operators.ts` -> `Tests/SQLFormatterTests/Parity/Features/OperatorsFeatureParityTests.swift` (5 cases ported)
- `DONE` `test/features/returning.ts` -> `Tests/SQLFormatterTests/Parity/Features/ReturningFeatureParityTests.swift` (1 case ported)
- `DONE` `test/features/insertInto.ts` -> `Tests/SQLFormatterTests/Parity/Features/InsertIntoFeatureParityTests.swift` (2 cases ported)
- `DONE` `test/features/schema.ts` -> `Tests/SQLFormatterTests/Parity/Features/SchemaFeatureParityTests.swift` (1 case ported)
- `DONE` `test/features/setOperations.ts` -> `Tests/SQLFormatterTests/Parity/Features/SetOperationsFeatureParityTests.swift` (18 cases ported)
- `DONE` `test/features/update.ts` -> `Tests/SQLFormatterTests/Parity/Features/UpdateFeatureParityTests.swift` (3 cases ported)
- `DONE` `test/features/truncateTable.ts` -> `Tests/SQLFormatterTests/Parity/Features/TruncateTableFeatureParityTests.swift` (2 cases ported)
- `DONE` `test/features/window.ts` -> `Tests/SQLFormatterTests/Parity/Features/WindowFeatureParityTests.swift` (2 cases ported)
- `DONE` `test/features/windowFunctions.ts` -> `Tests/SQLFormatterTests/Parity/Features/WindowFunctionsFeatureParityTests.swift` (1 case ported)

## Dialect Suites

- `DONE` `test/bigquery.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/BigqueryDialectParityTests.swift` (42 cases ported with documented divergences)
- `DONE` `test/sql.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/SqlDialectParityTests.swift` (4 cases ported)
- `DONE` `test/sqlite.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/SqliteDialectParityTests.swift` (2 cases ported)
- `DONE` `test/clickhouse.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/ClickhouseDialectParityTests.swift` (6 cases ported)
- `DONE` `test/db2.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/Db2DialectParityTests.swift` (1 case ported)
- `DONE` `test/db2i.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/Db2iDialectParityTests.swift` (32 cases ported)
- `DONE` `test/postgresql.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/PostgresqlDialectParityTests.swift` (10 cases ported)
- `DONE` `test/duckdb.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/DuckdbDialectParityTests.swift` (7 cases ported)
- `DONE` `test/hive.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/HiveDialectParityTests.swift` (3 cases ported)
- `DONE` `test/mariadb.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/MariadbDialectParityTests.swift` (3 cases ported)
- `DONE` `test/mysql.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/MysqlDialectParityTests.swift` (3 cases ported)
- `DONE` `test/n1ql.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/N1qlDialectParityTests.swift` (6 cases ported)
- `DONE` `test/plsql.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/PlsqlDialectParityTests.swift` (7 cases ported)
- `DONE` `test/redshift.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/RedshiftDialectParityTests.swift` (8 cases ported)
- `DONE` `test/singlestoredb.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/SinglestoredbDialectParityTests.swift` (3 cases ported)
- `DONE` `test/snowflake.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/SnowflakeDialectParityTests.swift` (12 cases ported)
- `DONE` `test/spark.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/SparkDialectParityTests.swift` (6 cases ported)
- `DONE` `test/tidb.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/TidbDialectParityTests.swift` (3 cases ported)
- `DONE` `test/transactsql.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/TransactsqlDialectParityTests.swift` (18 cases ported)
- `DONE` `test/trino.test.ts` -> `Tests/SQLFormatterTests/Parity/Dialects/TrinoDialectParityTests.swift` (2 cases ported)

## API Suites

- `DONE` `test/sqlFormatter.test.ts` -> `Tests/SQLFormatterTests/Parity/API/SqlFormatterAPIParityTests.swift` (ported applicable Swift-equivalent cases; JS-only/deprecated behaviors documented as N/A)

## Unit Suites

- `DONE` `test/unit/Layout.test.ts` -> `Tests/SQLFormatterTests/Unit/LayoutUnitParityTests.swift` (20 cases ported with documented divergences)
- `DONE` `test/unit/NestedComment.test.ts` -> `Tests/SQLFormatterTests/Unit/NestedCommentUnitParityTests.swift` (11 cases ported with documented divergences)
- `DONE` `test/unit/Parser.test.ts` -> `Tests/SQLFormatterTests/Unit/ParserUnitParityTests.swift` (18 tokenizer-backed parity checks; parser-API divergence documented)
- `DONE` `test/unit/Tokenizer.test.ts` -> `Tests/SQLFormatterTests/Unit/TokenizerUnitParityTests.swift` (3 representative cases ported with whitespace-token divergence documented)
- `DONE` `test/unit/expandPhrases.test.ts` -> `Tests/SQLFormatterTests/Unit/ExpandPhrasesUnitParityTests.swift` (13 cases ported)
- `DONE` `test/unit/tabularStyle.test.ts` -> `Tests/SQLFormatterTests/Unit/TabularStyleUnitParityTests.swift` (3 cases ported with spacing divergences documented)
- `DONE` snapshot equivalence (`test/unit/__snapshots__/*.snap`) -> Swift fixture-based parity implemented via `Tests/SQLFormatterTests/Fixtures/{Parser,Tokenizer}` and `*SnapshotParityTests.swift`

## Performance Suites (non-blocking)

- `DONE` `test/perftest.ts` -> adapted as memory smoke checks in `Sources/sqlfmt-bench/main.swift`
- `DONE` `test/perf/perf-test.js` -> adapted representative mixed-query workload benchmark in `Sources/sqlfmt-bench/main.swift`

## Known Divergences (Documented)

- `test/options/tabWidth.ts` and `test/options/useTabs.ts`: Swift currently formats `count(*)` as `count( *)`.
- `test/options/newlineBeforeSemicolon.ts` (`SELECT a FROM;` case): Swift emits semicolon on a separate line.
- `test/sqlFormatter.test.ts`: several JS runtime/deprecated option behaviors are N/A in Swift (typed dialect selection, no deprecated JS flags, no regex-based custom string type extension, and different invalid-input surface area).
- `test/unit/Layout.test.ts`: Swift `OutputBuffer` newline/no-space trimming semantics differ from upstream in some retroactive whitespace-removal and indent-token interactions.
- `test/unit/NestedComment.test.ts`: Swift tokenizer closes block comments at first `*/`; nested-comment handling differs from upstream helper expectations.
- `test/unit/Parser.test.ts`: no direct public parser AST API parity surface in Swift tests; parity is approximated via tokenizer-backed structural checks.
- `test/unit/Tokenizer.test.ts`: Swift tokenizer exposes whitespace/newline tokens explicitly, unlike upstream token snapshots.
- `test/unit/tabularStyle.test.ts`: Swift tabular styles retain different trailing/padding spaces for some multi-word clauses.
- `test/behavesLikeMariaDbFormatter.ts`: current formatting differs for `@\`name\`` variables, `:=`, `*.*`, and ON DUPLICATE KEY / REPLACE tuple wrapping.
- `test/behavesLikeDb2Formatter.ts`: current formatting differs for prefixed literals (`G'...'`), comment indentation under `FROM`, and `ALTER COLUMN` / `WITH CS` line breaking.
- `test/features/between.ts`: Swift breaks `BETWEEN ... AND ...` across lines and also expands comment/case layouts differently from upstream.
- `test/features/case.ts`: Swift keeps many CASE chains inline (including nested/tabular variants), emits CASE comments on standalone lines, and preserves lowercase case/else/end tokens in one upper-case option scenario.
- `test/features/comments.ts`: Swift emits many inline/indented comments as standalone unindented lines compared with upstream.
- `test/features/disableComment.ts`: disabled inline segment under `SELECT` is currently emitted without expression indentation.
- `test/features/with.ts`: CTE body indentation and parameterized CTE parentheses spacing differ from upstream.
- `test/features/strings.ts`: Swift accepts both doubling and backslash escapes for single/double quotes (no parse errors), lowercase hex/bit prefixes are separated from literals while uppercase prefixes stay contiguous (including double-quote variants), dollar-quoted strings are reformatted with SQL layout/newlines, and lowercase raw-string prefixes currently trigger unterminated token errors.
- `test/features/identifiers.ts`: Swift accepts both repeated-quote and backslash escaping across double-quoted and `U&` double-quoted identifiers (so upstream parse-error cases now pass) and emits whitespace between `U&` prefixes and their quoted identifiers.
- `test/features/limiting.ts`: Swift splits multi-value LIMIT expressions (including tabular styles) and comments onto separate lines and keeps FETCH/OFFSET clauses adjacent to their previous clauses instead of breaking them onto their own lines.
- `test/features/createView.ts`: Swift keeps the column list adjacent to the view identifier (no space before the opening parenthesis) and emits columns on separate lines without extra indentation before the SELECT clause.
- `test/features/createTable.ts`: Swift keeps the column list adjacent to the table identifier (no space before the opening parenthesis), breaks `CREATE OR REPLACE` across lines while the inline column layout stays compact, and the tabularLeft indent style currently does not reproduce upstream spacing around the CREATE TABLE header.
- `test/features/commentOn.ts`: Swift breaks COMMENT ON TABLE/COLUMN clause keywords (`COMMENT`, `ON`, `TABLE/COLUMN`) onto separate lines compared with upstream’s more compact form.
- `test/features/constraints.ts`: Swift line-breaks `ON UPDATE/DELETE` clauses aggressively and splits `SET NULL` into separate tokens/lines.
- `test/features/schema.ts`: Swift emits `SET` and `SCHEMA` on separate lines instead of the single-line clause upstream expects.
- `test/features/join.ts`: Swift places many JOIN qualifiers and `ON` predicates on more lines (including NATURAL variants and APPLY forms) than upstream.
- `test/features/update.ts`: Swift keeps `UPDATE ... AS (...)` body indentation flatter and splits `WHERE CURRENT OF` across lines.
- `test/features/alterTable.ts`: Swift keeps ALTER TABLE action variants mostly on single lines where upstream breaks clauses into multiple lines.
- `test/features/arrayAndMapAccessors.ts`: Swift inserts spaces before bracket accessors and emits comments around accessors differently than upstream.
- `test/features/arrayLiterals.ts`: Swift keeps array literals more inline and differs in keyword/data-type casing behavior for ARRAY forms.
- `test/features/isDistinctFrom.ts`: Swift breaks `IS DISTINCT FROM` around `FROM` with additional line splitting.
- `test/features/mergeInto.ts`: Swift splits MERGE clause boundaries differently (more/earlier line breaks) than upstream.
- `test/features/numbers.ts`: Swift differs around exponent/sign spacing and underscore-separated numeric literal formatting.
- `test/features/onConflict.ts`: Swift splits VALUES/ON CONFLICT boundaries differently from upstream layout.
- `test/features/operators.ts`: Swift formats `IN`/`NOT IN`/`ANY` with denser token spacing and multiline argument layout differences.
- `test/features/returning.ts`: Swift keeps RETURNING closer to VALUES row content where upstream breaks it to its own clause line.
- `test/features/setOperations.ts`: Swift keeps many set operators more inline and subquery set-operation blocks less indented than upstream.
- `test/features/window.ts`: Swift keeps WINDOW clause specifications more inline than upstream’s broken-out layout.
- `test/features/windowFunctions.ts`: Swift lays out OVER/ROWS BETWEEN frames differently from upstream clause wrapping.
- `test/sql.test.ts`: Swift accepts unknown tokens/curly braces as identifiers and keeps ALTER COLUMN clauses flatter than upstream.
- `test/bigquery.test.ts`: Swift differs broadly in spacing/line breaks for hyphenated identifiers, prefixed strings, parametric type punctuation, CREATE/ALTER forms, and PIVOT/UNPIVOT/UNNEST; one triple-quoted prefixed-string variant currently errors instead of formatting.
- `test/sqlite.test.ts`: Swift keeps `REPLACE INTO` table target on one line and splits `ON CONFLICT` keywords differently.
- `test/clickhouse.test.ts`: Swift differs in map/lambda/ternary spacing, insert+WITH placement, and DROP/RENAME clause wrapping.
- `test/db2.test.ts`: Swift formats non-standard `FOR` clause constructs with different clause splitting than upstream.
- `test/db2i.test.ts`: Swift differs across nested comments, LIMIT/FETCH wrapping, EXCEPTION JOIN layout, operator density/spacing, and data-type casing behavior.
- `test/postgresql.test.ts`: Swift differs in spacing/line breaks for array slices, `OPERATOR()` usage, `FOR UPDATE`, OR REPLACE bodies, and COMMENT ON formatting.
- `test/duckdb.test.ts`: Swift differs for prefix alias spacing, struct literal spacing, large literal wrapping, JSON casing, and `IS NOT NULL` casing.
- `test/hive.test.ts`: Swift differs for substitution variable escaping and SORT/CLUSTER/DISTRIBUTE BY clause grouping/line breaks.
- `test/mariadb.test.ts`: Swift emits whitespace between `@` and quoted variable names and keeps ALTER COLUMN clauses flatter.
- `test/mysql.test.ts`: Swift emits whitespace between `@` and quoted variable names and keeps ALTER COLUMN clauses flatter.
- `test/n1ql.test.ts`: Swift keeps many INSERT/USE KEYS/NEST/UNNEST and object-literal forms significantly more inline than upstream.
- `test/plsql.test.ts`: Swift differs in spacing around special identifiers/parameters, Q literals, recursive CTE formatting, and FOR UPDATE placement.
- `test/redshift.test.ts`: Swift differs for `::` spacing, line-comment placement, temp table naming layout, DIST/SORT key wrapping, ALTER COLUMN line breaks, and QUALIFY positioning.
- `test/singlestoredb.test.ts`: Swift inserts spacing around `::%` path operator compared with upstream’s compact form.
- `test/snowflake.test.ts`: Swift differs on colon path operator spacing, QUALIFY placement, lambda formatting, CASE layout, and ALTER COLUMN clause stacking.
- `test/spark.test.ts`: Swift differs for WINDOW/OVER wrapping, substitution variable handling, SORT/CLUSTER/DISTRIBUTE clause layout, and ALTER COLUMN flattening.
- `test/tidb.test.ts`: Swift emits whitespace between `@` and quoted variable names and keeps ALTER COLUMN clauses flatter.
- `test/transactsql.test.ts`: Swift differs in line breaking for scope resolution, `INTO`/`OPTION`/`FOR` clauses, GO blocks, and some identifier casing/spacing cases.
- `test/trino.test.ts`: Swift differs in row-pattern (`MATCH_RECOGNIZE`) clause wrapping.
