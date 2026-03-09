## Swift SQL Formatter Port Checklist

### Direction

- [x] Port from the TypeScript project first; use the Java port as a reference for strong typing and API translation.
- [x] Target idiomatic Swift, not a line-by-line Java or TypeScript rewrite.
- [x] Use tests as the behavior contract, starting with standard SQL and expanding dialects incrementally.

### Current Scaffold

- [x] Initialize SwiftPM package.
- [x] Add a public `format(_ sql: String, options: FormatOptions = .default) throws -> String` entry point.
- [x] Create initial source layout for `Dialects`, `Lexer`, `Formatter`, `Parser`, and `Tokens`.
- [x] Add a starter test target under `Tests/SQLFormatterTests`.

### Phase 1 - Core API and Models

- [x] Create `FormatOptions`.
- [x] Create `Dialect`.
- [x] Create `FormatError`.
- [x] Create `Token` and `TokenType`.
- [x] Decide final public API shape beyond the initial `format()` function.
- [x] Define line/column tracking model for parse errors.

### Phase 2 - Standard SQL Tokenizer

- [x] Tokenize whitespace and newlines separately.
- [x] Tokenize words, identifiers, strings, numbers, operators, and punctuation.
- [x] Support quoted identifiers and string literals.
- [ ] Support line and block comments.
- [ ] Track token locations for diagnostics.
- [x] Add tokenizer unit tests.

### Phase 3 - Formatter Engine

- [x] Build output buffer utilities for spaces, indentation, and newlines.
- [ ] Add indentation state management.
- [ ] Implement clause-aware formatting for:
  - [x] `SELECT`
  - [x] `FROM`
  - [x] `WHERE`
  - [ ] `GROUP BY`
  - [ ] `ORDER BY`
  - [ ] `LIMIT`
  - [ ] joins
- [ ] Add multiple-query separation.
- [x] Add formatter rule tests.

### Phase 4 - Options Parity

- [ ] Support `tabWidth`.
- [ ] Support `useTabs`.
- [ ] Support keyword casing.
- [ ] Support `linesBetweenQueries`.
- [ ] Add expression width / line-wrapping strategy.
- [ ] Add option coverage tests.

### Phase 5 - Placeholders and Comments

- [ ] Add positional placeholder replacement.
- [ ] Add named placeholder replacement.
- [ ] Add configurable placeholder types.
- [ ] Support formatter disable/enable comment blocks.
- [ ] Add tests for placeholders and comments.

### Phase 6 - Dialect System

- [ ] Convert standard SQL rules into dialect configuration.
- [ ] Add dialect registry.
- [ ] Add PostgreSQL or MySQL as the second dialect.
- [ ] Validate dialect-specific quoting, operators, and reserved words.
- [ ] Add dialect fixture tests.

### Phase 7 - Test Parity

- [ ] Port a small starter set of TypeScript fixtures.
- [ ] Add end-to-end formatting fixtures.
- [ ] Prioritize tricky coverage:
  - [ ] nested subqueries
  - [ ] CTEs
  - [ ] comments
  - [ ] placeholders
  - [ ] quoted identifiers
  - [ ] multiline expressions
  - [ ] multiple queries separated by `;`
- [ ] Expand fixture coverage as features land.

### Phase 8 - Package Polish

- [ ] Add README usage examples.
- [ ] Add a CLI target if needed.
- [ ] Add basic benchmark/perf checks.
- [ ] Prepare release/versioning workflow.

### Risks

- [ ] Avoid copying Java structure where Swift value types or enums are better.
- [ ] Avoid carrying over TypeScript dynamic assumptions into Swift API design.
- [ ] Watch lexer complexity around `String.Index` and Unicode correctness.
- [ ] Keep formatting decisions centralized to avoid inconsistent output rules.

### Immediate Next Steps

- [x] Replace the placeholder tokenizer with a real standard SQL tokenizer.
- [x] Replace the passthrough formatter pipeline with basic clause formatting.
- [x] Add the first meaningful API and formatter tests.
- [ ] Import a few TypeScript fixtures as parity targets.
