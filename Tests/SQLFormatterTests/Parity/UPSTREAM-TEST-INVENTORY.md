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
- `PENDING` `test/behavesLikeMariaDbFormatter.ts`
- `PENDING` `test/behavesLikeDb2Formatter.ts`

## Known Divergences (Documented)

- `test/options/tabWidth.ts` and `test/options/useTabs.ts`: Swift currently formats `count(*)` as `count( *)`.
- `test/options/newlineBeforeSemicolon.ts` (`SELECT a FROM;` case): Swift emits semicolon on a separate line.
