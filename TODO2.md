# TODO2 - Upstream docs gap analysis

Compared this project against every page currently under `sql-formatter-org/sql-formatter/docs`:

- `dataTypeCase.md`
- `denseOperators.md`
- `dialect.md`
- `expressionWidth.md`
- `functionCase.md`
- `identifierCase.md`
- `indentStyle.md`
- `keywordCase.md`
- `language.md`
- `linesBetweenQueries.md`
- `logicalOperatorNewline.md`
- `newlineBeforeSemicolon.md`
- `paramTypes.md`
- `params.md`
- `tabWidth.md`
- `useTabs.md`

## Already covered

- [x] `keywordCase`
- [x] `tabWidth`
- [x] `useTabs`
- [x] `linesBetweenQueries`
- [x] Basic `expressionWidth`
- [x] Basic placeholder substitution via `positionalPlaceholders` and `namedPlaceholders`
- [x] Basic dialect switching, but only for `sql` and `postgresql`

## Missing or partial features

### P0 - dialect parity

- [x] Add more upstream dialects beyond `sql` and `postgresql`.
  - Current registry is limited in `Sources/SQLFormatter/Dialects/DialectRegistry.swift` and `Sources/SQLFormatter/Dialects/Dialect.swift`.
  - Upstream docs advertise: `bigquery`, `clickhouse`, `db2`, `db2i`, `duckdb`, `hive`, `mariadb`, `mysql`, `tidb`, `n1ql`, `plsql`, `redshift`, `singlestoredb`, `snowflake`, `spark`, `sqlite`, `transactsql`/`tsql`, `trino`.
- [ ] Decide whether to match upstream's newer explicit dialect API in Swift.
  - Today `FormatOptions.dialect` already accepts a `Dialect`, which is close, but there is no documented custom dialect builder/story.
- [x] Add CLI parity for dialect selection naming.
  - `Sources/sqlfmt/main.swift` only accepts `--dialect <sql|postgresql>`.
  - Upstream CLI/docs use language/dialect names across the full dialect set.

### P1 - missing formatting options

- [x] Add `functionCase` option.
  - Needs function-call detection so only function identifiers change case.
- [x] Add `dataTypeCase` option.
  - Needs data type classification distinct from generic identifiers.
- [x] Add `identifierCase` option.
  - Upstream marks this experimental; safest to land after token classification improves.
- [x] Add `logicalOperatorNewline` option (`before` vs `after`).
  - Current `FormatterPipeline` always places logical operators in leading position style.
- [x] Add `newlineBeforeSemicolon` option.
  - Current `FormatterPipeline` always emits `;` inline.
- [x] Add `denseOperators` option.
  - Current operator formatting in `Sources/SQLFormatter/Parser/FormatterPipeline.swift` always inserts spaces.

### P1 - placeholder and params parity

- [x] Expand placeholder parsing beyond the current four `PlaceholderType` cases in `Sources/SQLFormatter/FormatOptions.swift`.
  - Missing numbered placeholders such as `?1`, `:1`, `$1`.
  - Missing quoted placeholders such as `@"name"`, `@[name]`, `` @`name` ``.
  - Missing dialect-specific placeholder syntaxes like ClickHouse `{name:Type}`.
- [x] Add upstream-style `paramTypes` configuration.
  - Upstream supports enabling/disabling positional, numbered, named, quoted, and custom regex-based placeholder syntaxes.
  - Local API only exposes a fixed `Set<PlaceholderType>`.
- [x] Add upstream-style `params` convenience API.
  - Current split between `positionalPlaceholders` and `namedPlaceholders` covers simple replacement, but not the full upstream placeholder matrix.
- [x] Define dialect defaults for placeholder support.
  - Upstream behavior varies by dialect; local defaults are currently global.

### P2 - semantic differences worth tightening

- [x] Align `expressionWidth` semantics more closely with upstream.
  - Upstream documents a default width of `50` and frames the rule around parenthesized expressions.
  - Local `FormatOptions.expressionWidth` defaults to `nil`, so wrapping is opt-in.
- [ ] Review whether `linesBetweenQueries` validation should match upstream wording/behavior exactly.
  - Local CLI allows `0`; this appears compatible, but should be verified against library-level validation semantics.

### P3 - optional / low priority parity

- [x] Decide whether to implement deprecated `indentStyle`.
  - Upstream explicitly marks it deprecated and caveated.
  - Chosen direction: skip for now unless strict parity is required.

## Suggested implementation order

1. Dialect expansion and alias coverage.
2. Placeholder parsing overhaul plus `paramTypes`/`params` parity.
3. Formatting switches: `logicalOperatorNewline`, `newlineBeforeSemicolon`, `denseOperators`.
4. Case-conversion options: `functionCase`, `dataTypeCase`, `identifierCase`.
5. Expression-width behavior alignment.
6. Re-evaluate deprecated `indentStyle`.

## Likely touch points

- `Sources/SQLFormatter/FormatOptions.swift`
- `Sources/SQLFormatter/Dialects/Dialect.swift`
- `Sources/SQLFormatter/Dialects/DialectRegistry.swift`
- `Sources/SQLFormatter/Lexer/Tokenizer.swift`
- `Sources/SQLFormatter/Parser/FormatterPipeline.swift`
- `Sources/sqlfmt/main.swift`
- `README.md`
- `Tests/SQLFormatterTests/FormattingAPITests.swift`
- `Tests/SQLFormatterTests/DialectFixtureTests.swift`
- `Tests/SQLFormatterTests/TypeScriptParityFixtureTests.swift`

## Recommendation

- Treat dialect coverage and placeholder parity as the biggest missing areas.
- Treat `indentStyle` as intentionally deferred unless upstream compatibility becomes the primary goal.
