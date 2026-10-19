---
type: Architecture Guidance
title: Formatter architecture
description: Design principles that keep the formatter's Swift implementation and public contracts coherent.
tags: [architecture, swift, formatter]
status: stable
generated: { by: openai/gpt-6.1-sol, at: 2026-10-19T00:58:43Z }
sources:
  - id: prior-architecture
    resource: https://github.com/godsarmy/swift-sql-formatter/blob/5ba0714fe51cc8409edd85abf8585145c843fff9/Docs/ARCHITECTURE.md
    title: Prior architecture notes
---

# Principles

- Model immutable data and lightweight state with value types; use enums for
  closed domains such as token kinds, casing, and placeholders.
- Keep parser and formatter contracts explicit and typed. Public options and
  dialect selection should not depend on ad-hoc runtime strings.
- Represent dialect behavior as `Dialect` data and resolve names through
  `DialectRegistry`.
- Traverse Swift strings with `String.Index`; source locations must remain
  correct for Unicode and line-ending inputs.
- Centralize clause recognition, layout, and output-buffer decisions so a
  formatting rule has a deterministic home.

# Maintenance implication

Treat tests as behavior contracts. When a formatter change is intentional,
update its focused coverage rather than adding a compensating rule elsewhere.
