# TypeScript Parity Report

Baseline upstream:
- Repository: `sql-formatter-org/sql-formatter`
- Commit: `a9849494212c0a61fb6b0c1461db84e93ab2ac96`
- Baseline inventory note: ~665 upstream `it(...)` cases

Current Swift parity status:
- Parity/unit parity test files added: 78
- Ported parity test cases (`@Test`) across parity + unit parity suites: 563
- Plan checklist status: all phases complete; performance parity is implemented as non-blocking smoke/benchmark coverage under `sqlfmt-bench`.

## Coverage by suite type

- Options suites: complete
- Shared behavior suites: complete
- Feature suites: complete
- Dialect integration suites: complete
- API parity suite (`sqlFormatter.test.ts`): complete for Swift-equivalent semantics
- Unit suites (`Layout`, `NestedComment`, `Parser`, `Tokenizer`, `expandPhrases`, `tabularStyle`): complete
- Snapshot equivalence (`test/unit/__snapshots__/*.snap`): complete via Swift fixture-based snapshot tests
- Performance parity (`test/perftest.ts`, `test/perf/perf-test.js`): complete as non-blocking memory/throughput smoke checks in `Sources/sqlfmt-bench/main.swift`

## Explicit N/A cases

The following upstream API behaviors were treated as N/A for Swift and documented in parity tests/inventory:

- JS runtime argument-shape validation that does not map to Swift’s typed API surface
- Deprecated JS formatting options (`multilineLists`, `newlineBeforeOpenParen`, `newlineBeforeCloseParen`, `aliasAs`, `tabulateAlias`, `commaPosition`)
- Regex-based custom string type extension patterns that do not have an equivalent extension point in current Swift API

## Known divergences

Known behavior divergences are documented in:
- `Tests/SQLFormatterTests/Parity/UPSTREAM-TEST-INVENTORY.md` ("Known Divergences")

These include established formatter differences (line breaking, spacing, comment/layout behavior, tokenization surface differences, and dialect-specific formatting differences) where Swift expectations intentionally follow current implementation.
