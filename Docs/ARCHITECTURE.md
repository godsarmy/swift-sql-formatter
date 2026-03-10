# Architecture Notes

This project keeps implementation choices aligned with Swift-first design and the checklist risks.

## Swift-first modeling

- Prefer value types (`struct`) for immutable data and lightweight state containers.
- Prefer enums for closed sets (token kinds, keyword casing, placeholder kinds).
- Keep parser/formatter contracts explicit and typed (avoid stringly typed control flow).

## Avoid dynamic API assumptions

- Public configuration is expressed through `FormatOptions` with strongly typed fields.
- Placeholder behavior is controlled by `PlaceholderType` values instead of ad-hoc runtime keys.
- Dialect behavior is represented by `Dialect` data plus `DialectRegistry` lookup.

## Lexer index and Unicode safety

- Lexer traversal uses `String.Index` exclusively (never integer indexing into Swift strings).
- Source locations are tracked as line/column/offset through index walking.
- Unicode regression tests cover token locations and CRLF handling.

## Centralized formatting decisions

- Clause recognition and keyword rules are driven by `Dialect` configuration.
- Query layout behavior is centralized in `FormatterPipeline` and `OutputBuffer`.
- Tests in `Tests/SQLFormatterTests` act as behavior contracts for formatting rules.
