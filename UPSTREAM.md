# Following sql-formatter upstream

The reviewed target is **sql-formatter v15.9.0**, commit
`63dc9f835cef4738ef107bf2306b20fd7e7a4d20`.
The previous baseline was `a9849494212c0a61fb6b0c1461db84e93ab2ac96`.
The baseline is recorded in this guide and the parity report.
[Review the upstream comparison](https://github.com/sql-formatter-org/sql-formatter/compare/a9849494212c0a61fb6b0c1461db84e93ab2ac96...63dc9f835cef4738ef107bf2306b20fd7e7a4d20).

This records the upstream changes reviewed and ported, not a claim of identical
output for all SQL. Existing Swift differences remain documented in the
[parity inventory](Tests/SQLFormatterTests/Parity/UPSTREAM-TEST-INVENTORY.md).

## 15.9.0 update audit

| Upstream change | Swift disposition |
| --- | --- |
| Transact-SQL `OPENJSON` | Already supported by generic function recognition; added function-case regression coverage. |
| PostgreSQL `>^`, `<@>`, `~>`, `#=`, `&&&`, `\|=\|` operators | Added `@` to PostgreSQL operator characters; existing operator-run recognition covers the other symbols. Added normal/dense output fixtures. |
| Trino `TIMESTAMP`/`TIME WITH`/`WITHOUT TIME ZONE` | Recognize keyword phrases without interpreting `WITH` as a new clause. |
| SQLite Tcl `$name::suffix(trailer)` parameters | Consume the complete parameter as one token, including trailer punctuation and spaces; preserve existing parameter replacement API. |
| PostgreSQL constraint triggers and event phrases | Format event, deferrability and execution clauses; keep event `OR` inline and apply keyword casing. |
| Standalone leading block comments | Existing Swift comments already occupy standalone lines. Added idempotency checks for all three new upstream examples; existing indentation/inline-comment differences remain. |
| Dense minus in BigQuery | Keep minus spaced because upstream permits dashed identifiers. Existing Swift sign/digit spacing remains. |
| Adjacent minus operators forming `--` | Insert a separating space when writing adjacent minus tokens. Regression fixtures cover all built-in dialects. |
| PostgreSQL `OPERATOR(...)` in dense mode | Tokenize the qualified operator as a unit and retain surrounding spaces. |
| Extra space after `BETWEEN` | Swift already avoids duplicate spaces. Added a regression check; existing `BETWEEN`/`CASE` line-breaking differences remain. |
| DuckDB array-slice colon | Track enclosing bracket kind and keep slice colons dense while spacing struct values. |
| Long expression-list parser performance | The Nearley persistent-list implementation does not apply to Swift's streaming pipeline. Removed repeated source-location and statement-prefix scans, and added a 2,000-column regression. |
| PostgreSQL `pg_dump` restrict/unrestrict commands | Preserve each safety guard as an opaque line. Existing table-name/parenthesis spacing remains. |
| SingleStoreDB `%` | Already recognized through the base dialect; added regression coverage. |
| Reserved-word aliases after `AS` | Prevent eligible aliases from starting clauses or logical expressions, including across comments. Preserve real `AS SELECT` statements and subsequent `SET` clauses. |
| Node package manager, build, release tools, dependency locks, authors, CI configuration | No Swift runtime equivalent; retain this package's SwiftPM/release workflow. |
| Shared upstream operator-test refactoring | Behavioral coverage captured in Swift fixtures; no JavaScript helper code to port. |

## Regression fixtures

`Tests/SQLFormatterTests/Fixtures/upstream-15.9.0.json` contains inputs, options,
and outputs captured using the published npm package `sql-formatter@15.9.0`.
The fixture runner checks exact output and formatting idempotency. For retained
Swift differences, `upstreamExpected` preserves the original upstream output,
`expected` records Swift output, and `divergence` explains the difference.
Additional tests cover replacement values, comments, statement boundaries,
source locations, and long lists.

The existing Swift formatter recognizes arbitrary callable names as functions;
upstream distinguishes known functions from callable identifiers. Consequently,
function spacing/casing can differ. Trigger fixtures explicitly set
`functionCase: lower` alongside `identifierCase: lower` and document this.

## Future updates

1. Manually review upstream releases and choose a fixed release tag.
2. Resolve that tag's exact commit and compare it with the baseline recorded above,
   focusing on `src/` and `test/`.
3. Record each behavior change in an audit table. Port upstream regression inputs,
   options, and expected outputs, then implement the Swift equivalent.
4. Compare the affected cases with that exact upstream release. Document retained
   differences explicitly rather than silently changing expected output.
5. Run `swift build`, `swift test`, and `swift run sqlfmt-bench` when performance
   changes. Keep benchmarks informational rather than using machine-dependent
   timing thresholds.
6. Once the audit is resolved, update this audit, the parity report/inventory,
   and any public behavior documentation together.

Upstream tracking and porting are manual. There is no scheduled update workflow
or automatic upstream check.

## Validation

- `swift build`: passed.
- `swift test`: 698 tests passed, including 67 upstream output fixtures and their
  idempotency checks.
- `swift run sqlfmt-bench`: memory and throughput smoke checks completed.
- Long-query output checks passed for 1,000, 2,000, and 4,000 columns; observed
  runtime scaled approximately with input size. Timing remains informational.
