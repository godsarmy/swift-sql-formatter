# AGENTS.md

Guidance for coding agents working in this repository.

## Project scope

- This project is a Swift port of `sql-formatter` with a library target (`SQLFormatter`) and CLI targets (`sqlfmt`, `sqlfmt-bench`).
- Preserve behavior parity with existing tests and documented options in `README.md`.

## Repository map

- `Sources/SQLFormatter/`: core library code (dialects, lexer, parser, formatter, options).
- `Sources/sqlfmt/`: CLI entry point.
- `Sources/sqlfmt-bench/`: benchmark utility.
- `Tests/SQLFormatterTests/`: unit and parity tests.

## Build and test commands

- Build: `swift build`
- Run tests: `swift test`
- Run formatter CLI: `swift run sqlfmt --dialect postgresql`
- Run benchmark utility: `swift run sqlfmt-bench`

## Coding expectations

- Write idiomatic Swift; avoid line-by-line ports from other languages.
- Keep formatting behavior deterministic; avoid ad-hoc rule placement.
- Prefer small, focused changes that include test updates when behavior changes.
- Keep public API changes intentional and reflected in `README.md`.

## Testing expectations

- Add or update tests in `Tests/SQLFormatterTests/` for any functional behavior change.
- Prefer fixture/parity style tests for formatter output.
- Ensure local `swift test` passes before finalizing changes.

## Safety rules

- Do not remove or rewrite unrelated user changes.
- Avoid destructive git commands.
- If a task is ambiguous, follow existing conventions in tests and README first.

## Change checklist

- Code compiles.
- Tests pass.
- Docs updated when public behavior changes.
- New options or dialect behavior are covered by tests.
