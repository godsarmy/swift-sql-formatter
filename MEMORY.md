# Memory

- The branch is intentionally progressing via small, test-focused commits on `main`.
- After any code edits, always run `swift test --filter FormattingAPITests` first for fast validation.
- The project now has explicit/custom dialect APIs: `formatDialect`, `DialectOptions`, and `createDialect`.
- `DialectRegistry.dialect(named:additionalDialects:)` should behave case-insensitively for both built-in and custom dialect names.
- `DialectRegistry` now also supports runtime alias injection via `dialect(named:additionalDialects:additionalAliases:)` and `names(additionalDialects:additionalAliases:)`.
- Runtime aliases are normalized to lowercase, and built-in aliases intentionally take precedence on conflicts.
- Always provide a critique URL for edited files at the end of each edit session.
- Keep `Tests/SQLFormatterTests/Parity/UPSTREAM-TEST-INVENTORY.md` in sync with already-added parity files; it can lag behind active work.
- Known parity divergences to preserve in assertions: `count(*)` currently formats as `count( *)`, and invalid `SELECT a FROM;` emits `;` on its own line.
