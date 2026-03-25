# PLAN: TypeScript Test Parity Expansion

## Goal
Bring this Swift port's test coverage to parity with `sql-formatter-org/sql-formatter` tests under `test/`, using upstream as source of truth.

Upstream baseline (frozen for this effort):
- Repo: `https://github.com/sql-formatter-org/sql-formatter`
- Commit: `a9849494212c0a61fb6b0c1461db84e93ab2ac96` (master)
- Inventory: 79 files, ~665 `it(...)` cases

Current Swift baseline:
- `Tests/SQLFormatterTests`: 5 files, 129 `@Test` cases
- Coverage is broad but concentrated in one large file; upstream parity matrix is not yet explicit.

## Scope
In scope:
- Port all relevant upstream tests in `test/*.test.ts`, `test/features/*.ts`, `test/options/*.ts`, `test/unit/*.test.ts`.
- Add Swift equivalents for shared behavior suites (`behavesLike*.ts`) via reusable helper functions.
- Add API parity tests for `sqlFormatter.test.ts` semantics where Swift API has equivalent behavior.

Out of scope (non-blocking parity):
- `test/perf/perf-test.js` and `test/perftest.ts` as correctness gates. These should be adapted into benchmark smoke checks under `sqlfmt-bench`, not required for `swift test` pass/fail.

## Test Architecture To Add
Create a parity-oriented layout while keeping existing tests:
- `Tests/SQLFormatterTests/Parity/Helpers/`
- `Tests/SQLFormatterTests/Parity/Features/`
- `Tests/SQLFormatterTests/Parity/Options/`
- `Tests/SQLFormatterTests/Parity/Dialects/`
- `Tests/SQLFormatterTests/Parity/API/`
- `Tests/SQLFormatterTests/Unit/`

Add core helpers:
- `assertFormat(_ sql:, _ expected:, options:)`
- `assertFormatDialect(_ sql:, dialect:, _ expected:, options:)`
- `assertFormatError(_ sql:, options:, contains:)`
- `dedent`/normalization helper matching upstream fixture style
- Shared "behaves like" helpers for SQL/PostgreSQL/MariaDB/DB2 families

## Parity Mapping Checklist

### 1) Shared behavior suites (port as Swift helper suites)
- [x] `test/behavesLikeSqlFormatter.ts`
- [x] `test/behavesLikePostgresqlFormatter.ts`
- [x] `test/behavesLikeMariaDbFormatter.ts`
- [x] `test/behavesLikeDb2Formatter.ts`

### 2) Feature suites (31 files)
- [ ] `test/features/alterTable.ts`
- [ ] `test/features/arrayAndMapAccessors.ts`
- [ ] `test/features/arrayLiterals.ts`
- [x] `test/features/between.ts`
- [x] `test/features/case.ts`
- [ ] `test/features/commentOn.ts`
- [x] `test/features/comments.ts`
- [ ] `test/features/constraints.ts`
- [x] `test/features/createTable.ts`
- [x] `test/features/createView.ts`
- [x] `test/features/deleteFrom.ts`
- [x] `test/features/disableComment.ts`
- [x] `test/features/dropTable.ts`
- [x] `test/features/identifiers.ts`
- [x] `test/features/insertInto.ts`
- [ ] `test/features/isDistinctFrom.ts`
- [ ] `test/features/join.ts`
- [x] `test/features/limiting.ts`
- [ ] `test/features/mergeInto.ts`
- [ ] `test/features/numbers.ts`
- [ ] `test/features/onConflict.ts`
- [ ] `test/features/operators.ts`
- [ ] `test/features/returning.ts`
- [ ] `test/features/schema.ts`
- [ ] `test/features/setOperations.ts`
- [x] `test/features/strings.ts`
- [x] `test/features/truncateTable.ts`
- [ ] `test/features/update.ts`
- [ ] `test/features/window.ts`
- [ ] `test/features/windowFunctions.ts`
- [x] `test/features/with.ts`

### 3) Option suites (13 files)
- [x] `test/options/dataTypeCase.ts`
- [x] `test/options/expressionWidth.ts`
- [x] `test/options/functionCase.ts`
- [x] `test/options/identifierCase.ts`
- [x] `test/options/indentStyle.ts`
- [x] `test/options/keywordCase.ts`
- [x] `test/options/linesBetweenQueries.ts`
- [x] `test/options/logicalOperatorNewline.ts`
- [x] `test/options/newlineBeforeSemicolon.ts`
- [x] `test/options/param.ts`
- [x] `test/options/paramTypes.ts`
- [x] `test/options/tabWidth.ts`
- [x] `test/options/useTabs.ts`

### 4) Dialect integration suites (20 files)
- [ ] `test/sql.test.ts`
- [ ] `test/bigquery.test.ts`
- [ ] `test/clickhouse.test.ts`
- [ ] `test/db2.test.ts`
- [ ] `test/db2i.test.ts`
- [ ] `test/duckdb.test.ts`
- [ ] `test/hive.test.ts`
- [ ] `test/mariadb.test.ts`
- [ ] `test/mysql.test.ts`
- [ ] `test/n1ql.test.ts`
- [ ] `test/plsql.test.ts`
- [ ] `test/postgresql.test.ts`
- [ ] `test/redshift.test.ts`
- [ ] `test/singlestoredb.test.ts`
- [ ] `test/snowflake.test.ts`
- [ ] `test/spark.test.ts`
- [ ] `test/sqlite.test.ts`
- [ ] `test/tidb.test.ts`
- [ ] `test/transactsql.test.ts`
- [ ] `test/trino.test.ts`

### 5) API/top-level behavior suites
- [ ] `test/sqlFormatter.test.ts` (error messaging, deprecated option handling, invalid argument behavior, explicit dialect API)

### 6) Unit internals suites
- [ ] `test/unit/Layout.test.ts`
- [ ] `test/unit/NestedComment.test.ts`
- [ ] `test/unit/Parser.test.ts`
- [ ] `test/unit/Tokenizer.test.ts`
- [ ] `test/unit/expandPhrases.test.ts`
- [ ] `test/unit/tabularStyle.test.ts`
- [ ] Snapshot equivalence for parser/tokenizer fixtures (`__snapshots__/*.snap`) via Swift fixture files

### 7) Performance parity (non-blocking)
- [ ] `test/perftest.ts`
- [ ] `test/perf/perf-test.js`

## Implementation Phases

### Phase 0: Harness and inventory lock
1. Add a generated inventory file `Tests/SQLFormatterTests/Parity/UPSTREAM-TEST-INVENTORY.md` with upstream commit hash and checklist above.
2. Add shared parity assertion helpers and dedent utility.
3. Add naming convention: each Swift test should include upstream file + case title in comments for traceability.

### Phase 1: Options + core shared behavior
1. Port all `test/options/*.ts` to establish stable option semantics.
2. Port shared behavior from `behavesLikeSqlFormatter.ts` first.
3. Keep new tests in small files (one upstream source file per Swift file).

### Phase 2: Feature modules
1. Port all `test/features/*.ts` into feature-specific Swift files.
2. Prioritize high-volume and high-risk suites first:
   - `strings.ts` (34)
   - `comments.ts` (22)
   - `identifiers.ts` (17)
   - `case.ts` (13)
   - `limiting.ts` (9)

### Phase 3: Dialect integration
1. Add one Swift suite per dialect file.
2. Reuse family helpers for SQL/PostgreSQL/MariaDB/DB2.
3. Ensure each supported dialect in README has at least one dedicated parity suite file.

### Phase 4: API and unit internals
1. Port `sqlFormatter.test.ts` semantics where API-equivalent.
2. Port unit suites (`Layout`, `Parser`, `Tokenizer`, `NestedComment`, `expandPhrases`, `tabularStyle`).
3. Replace Jest snapshots with Swift fixture files under `Tests/SQLFormatterTests/Fixtures/` and deterministic assertions.

### Phase 5: Stabilization and cleanup
1. Remove/merge obsolete overlapping tests once parity suites fully supersede them.
2. Keep smoke tests from existing files that verify Swift-only APIs (CLI parser, DialectRegistry custom aliases, etc.).
3. Run full test suite and document any intentional deviations from upstream behavior.

## Rules For Porting Each Test
- Preserve SQL input and expected formatted output exactly unless Swift API differences require adaptation.
- If upstream test validates unsupported/deprecated JS-only options, add Swift equivalent only when behavior exists; otherwise document as N/A in parity tracker.
- Do not batch unrelated behavior changes with test ports.
- Every added parity file must pass `swift test` before merging.

## PR/Batch Plan
1. PR1: Harness + inventory + option suites.
2. PR2: Core shared behavior (`behavesLikeSqlFormatter`) + top shared features.
3. PR3: Remaining feature suites.
4. PR4: SQL family dialects (`sql/sqlite/postgresql/duckdb/redshift/trino`).
5. PR5: MariaDB family (`mariadb/mysql/tidb/singlestoredb`).
6. PR6: DB2 family + TSQL + BigQuery + ClickHouse.
7. PR7: Remaining dialects (`hive/n1ql/plsql/spark/snowflake`).
8. PR8: API + unit + snapshot fixtures + parity report.

## Definition of Done
- All applicable upstream test files listed above are mapped to Swift test files.
- `swift test` passes with no skipped parity tests.
- A parity report exists documenting:
  - total upstream cases
  - total ported cases
  - explicit N/A cases with rationale
  - any known behavior divergences
