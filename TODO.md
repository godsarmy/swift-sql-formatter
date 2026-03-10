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
- [x] Support line and block comments.
- [x] Track token locations for diagnostics.
- [x] Add tokenizer unit tests.

### Phase 3 - Formatter Engine

- [x] Build output buffer utilities for spaces, indentation, and newlines.
- [x] Add indentation state management.
- [x] Implement clause-aware formatting for:
  - [x] `SELECT`
  - [x] `FROM`
  - [x] `WHERE`
  - [x] `GROUP BY`
  - [x] `ORDER BY`
  - [x] `LIMIT`
  - [x] joins
- [x] Add multiple-query separation.
- [x] Add formatter rule tests.

### Phase 4 - Options Parity

- [x] Support `tabWidth`.
- [x] Support `useTabs`.
- [x] Support keyword casing.
- [x] Support `linesBetweenQueries`.
- [x] Add expression width / line-wrapping strategy.
- [x] Add option coverage tests.

### Phase 5 - Placeholders and Comments

- [x] Add positional placeholder replacement.
- [x] Add named placeholder replacement.
- [x] Add configurable placeholder types.
- [x] Support formatter disable/enable comment blocks.
- [x] Add tests for placeholders and comments.

### Phase 6 - Dialect System

- [x] Convert standard SQL rules into dialect configuration.
- [x] Add dialect registry.
- [x] Add PostgreSQL or MySQL as the second dialect.
- [x] Validate dialect-specific quoting, operators, and reserved words.
- [x] Add dialect fixture tests.

### Phase 7 - Test Parity

- [x] Port a small starter set of TypeScript fixtures.
- [x] Add end-to-end formatting fixtures.
- [x] Prioritize tricky coverage:
  - [x] nested subqueries
  - [x] CTEs
  - [x] comments
  - [x] placeholders
  - [x] quoted identifiers
  - [x] multiline expressions
  - [x] multiple queries separated by `;`
- [x] Expand fixture coverage as features land.

### Phase 8 - Package Polish

- [x] Add README usage examples.
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
- [x] Import a few TypeScript fixtures as parity targets.
