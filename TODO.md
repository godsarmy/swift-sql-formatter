## Swift SQL Formatter Port Plan

### Direction

- Port from the TypeScript project first; use the Java port as a reference for strong typing and API translation.
- Target idiomatic Swift, not a line-by-line Java or TypeScript rewrite.
- Build behavior parity through tests, starting with standard SQL and expanding dialects incrementally.

### Goals

- Provide a simple public API:
  - `format(_ sql: String, options: FormatOptions = .default) throws -> String`
- Keep the formatter deterministic and testable.
- Make dialect support data-driven so new dialects are mostly configuration additions.

### Architecture

- `SQLFormatter.swift`
  - Public entry points.
- `FormatOptions.swift`
  - Indentation, casing, line-break, placeholder, and dialect options.
- `Errors.swift`
  - Parse/tokenization errors with line/column.
- `Tokens/`
  - Token types and token model.
- `Lexer/`
  - SQL tokenizer.
- `Dialects/`
  - Dialect definitions and registry.
- `Parser/`
  - Formatting state / token stream traversal.
- `Formatter/`
  - Output builder, indentation, newline logic.
- `Tests/`
  - Unit, fixture, and end-to-end behavior tests.

### Implementation Order

1. Scaffold SwiftPM package with library and test targets.
2. Define core models:
   - `Token`
   - `TokenType`
   - `FormatOptions`
   - `Dialect`
   - `FormatError`
3. Implement tokenizer for standard SQL.
4. Implement formatter state machine for core clauses:
   - `SELECT`
   - `FROM`
   - `WHERE`
   - `GROUP BY`
   - `ORDER BY`
   - `LIMIT`
   - joins
5. Implement output builder rules:
   - indentation
   - line breaks
   - keyword casing
   - multiple-query separation
6. Add placeholder replacement.
7. Add comments and formatter disable/enable block handling.
8. Add dialect registry and convert standard SQL into a dialect definition.
9. Add a second dialect to validate extensibility, preferably PostgreSQL or MySQL.
10. Expand to remaining dialects and options.

### Test Strategy

- Port tests from the TypeScript project as the primary behavior contract.
- Use three layers of tests:
  - tokenizer tests
  - formatter rule tests
  - full fixture/end-to-end tests
- Prioritize coverage for:
  - nested subqueries
  - CTEs
  - comments
  - placeholders
  - quoted identifiers
  - multiline expressions
  - multiple queries separated by `;`

### Milestones

- Milestone 1
  - SwiftPM package
  - public `format()` API
  - standard SQL basic clause formatting
- Milestone 2
  - core options parity
  - indentation and keyword case controls
- Milestone 3
  - placeholders
  - comments
  - multi-query input
- Milestone 4
  - dialect system
  - 2-3 supported dialects
- Milestone 5
  - broader test parity with TypeScript fixtures
- Milestone 6
  - CLI and package polish

### Risks

- A direct Java port may preserve Java-specific design that feels unnatural in Swift.
- A direct TypeScript port may carry over dynamic-language assumptions.
- Most complexity will be in tokenization and newline/indentation decisions, not the public API.

### Swift-Specific Notes

- Prefer enums and value types where possible.
- Keep dialect definitions immutable.
- Use a centralized output builder to avoid scattered formatting logic.
- Be careful with `String.Index` and Unicode handling in the lexer.
- Favor pure functions and small state objects over large mutable classes.

### First Practical Steps

- Initialize the Swift package.
- Create the core model files.
- Port a minimal tokenizer.
- Port a minimal formatter for `SELECT ... FROM ... WHERE ...`.
- Bring over a small set of fixture tests from the TypeScript project.
