# Upstream Docs Feature Gap Plan

Status: completed on 2026-03-13.

After reviewing the upstream `sql-formatter` docs under `docs/` and comparing them with this repository's public API, CLI, README, and tests, these documented features were initially missing here and have now been implemented.

## Implemented features

### 1. `indentStyle` option

Upstream docs include a documented `indentStyle` option with `standard`, `tabularLeft`, and `tabularRight` modes.

- Upstream reference: `docs/indentStyle.md`
- Local evidence: `Sources/SQLFormatter/FormatOptions.swift:99` has no `indentStyle` field.
- Local evidence: `Sources/sqlfmt/main.swift:147` help output exposes no `--indent-style` flag.

Implemented:

1. Add a Swift enum for indentation style and surface it in `FormatOptions`.
2. Extend `FormatterPipeline` to support `standard`, `tabularLeft`, and `tabularRight` indentation behavior.
3. Add CLI parsing and help text for `--indent-style`.
4. Add formatter tests covering all three modes.
5. Document the option in `README.md`, including the deprecated/upstream-compatibility status.

### 2. Legacy `language`-based API parity

Upstream docs still document `language` as the runtime dialect selector for the legacy `format()` API.

- Upstream reference: `docs/language.md`
- Local evidence: `Sources/SQLFormatter/FormatOptions.swift:102` exposes `dialect`, not `language`.
- Local evidence: `Sources/SQLFormatter/SQLFormatter.swift:16` provides `format(_:options:)` and `formatDialect(_:dialect:options:)`, but no legacy `language`-named compatibility surface.
- Local evidence: `Sources/sqlfmt/main.swift:70` supports `--dialect`, but no `--language` alias.

Implemented:

1. Added a CLI `--language` alias mapped to the same dialect registry as `--dialect`.
2. Added parser tests to confirm config- and argument-based language resolution.
3. Kept `dialect` as the Swift library term while documenting `--language` as an upstream-compatible CLI alias.

### 3. CLI config file support

Upstream dialect docs explicitly note that the CLI config file uses `language`, which implies documented config-file support for the command line tool.

- Upstream reference: `docs/dialect.md`
- Local evidence: `Sources/sqlfmt/main.swift:63` parses only direct command-line flags.
- Local evidence: repository search found no config file support such as `.sql-formatter.json`, `--config`, or related parsing.

Implemented:

1. Added JSON config loading from `.sql-formatter.json`, `.sql-formatterrc`, and explicit `--config <path>`.
2. Loaded config before CLI flag parsing, with CLI flags overriding config values.
3. Supported both `language` and `dialect` config keys.
4. Added parser tests for config discovery and override precedence.
5. Documented config file usage in `README.md`.

## Not identified as gaps

The rest of the upstream docs in `docs/` appear to already be covered by the current project, including:

- dialect selection via `dialect` / `formatDialect`
- `tabWidth`, `useTabs`, `keywordCase`, `functionCase`, `dataTypeCase`, `identifierCase`
- `logicalOperatorNewline`, `linesBetweenQueries`, `expressionWidth`, `newlineBeforeSemicolon`, `denseOperators`
- placeholder replacement via legacy placeholders and `params` / `paramTypes`
- custom dialect creation and registry-based dialect lookup

## Verification

- `swift test`
