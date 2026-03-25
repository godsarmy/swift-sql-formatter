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
- `DONE` `test/features/limiting.ts` -> `Tests/SQLFormatterTests/Parity/Features/LimitingFeatureParityTests.swift` (9 cases ported with documented divergences)
- `DONE` `test/features/insertInto.ts` -> `Tests/SQLFormatterTests/Parity/Features/InsertIntoFeatureParityTests.swift` (2 cases ported)
- `DONE` `test/features/schema.ts` -> `Tests/SQLFormatterTests/Parity/Features/SchemaFeatureParityTests.swift` (1 case ported)
- `DONE` `test/features/update.ts` -> `Tests/SQLFormatterTests/Parity/Features/UpdateFeatureParityTests.swift` (3 cases ported)
- `DONE` `test/features/truncateTable.ts` -> `Tests/SQLFormatterTests/Parity/Features/TruncateTableFeatureParityTests.swift` (2 cases ported)

## Known Divergences (Documented)

- `test/options/tabWidth.ts` and `test/options/useTabs.ts`: Swift currently formats `count(*)` as `count( *)`.
- `test/options/newlineBeforeSemicolon.ts` (`SELECT a FROM;` case): Swift emits semicolon on a separate line.
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
