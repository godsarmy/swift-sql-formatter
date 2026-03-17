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
- `PENDING` `test/options/dataTypeCase.ts`
- `PENDING` `test/options/expressionWidth.ts`
- `PENDING` `test/options/functionCase.ts`
- `PENDING` `test/options/identifierCase.ts`
- `PENDING` `test/options/indentStyle.ts`
- `DONE` `test/options/linesBetweenQueries.ts` -> `Tests/SQLFormatterTests/Parity/Options/LinesBetweenQueriesParityTests.swift`
- `PENDING` `test/options/logicalOperatorNewline.ts`
- `PENDING` `test/options/newlineBeforeSemicolon.ts`
- `PENDING` `test/options/param.ts`
- `PENDING` `test/options/paramTypes.ts`
- `DONE` `test/options/tabWidth.ts` -> `Tests/SQLFormatterTests/Parity/Options/TabWidthParityTests.swift`
- `DONE` `test/options/useTabs.ts` -> `Tests/SQLFormatterTests/Parity/Options/UseTabsParityTests.swift`

## Shared Behavior, Features, Dialects, API, Unit

- `PENDING` Not yet split into this tracker; use `PLAN-TEST.md` as source checklist until migrated.

## Known Divergences (Documented)

- `test/options/tabWidth.ts` and `test/options/useTabs.ts`: Swift currently formats `count(*)` as `count( *)`.
