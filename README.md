# Swift SQL Formatter

A Swift package for formatting SQL queries with readable indentation, clause layout, and configurable options.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/your-org/swift-sql-formatter.git", from: "0.1.0")
```

Then add the product to your target dependencies:

```swift
.product(name: "SQLFormatter", package: "swift-sql-formatter")
```

## Usage

### Simple formatting

```swift
import SQLFormatter

let sql = "SELECT id, name FROM users WHERE active = 1"
let formatted = try format(sql)
print(formatted)
```

### Reusable formatter instance

```swift
import SQLFormatter

let formatter = Formatter(options: .default)
let formatted = try formatter.format("SELECT id FROM users")
```

### Options

```swift
import SQLFormatter

let options = FormatOptions(
  dialect: .postgreSQL,
  tabWidth: 2,
  useTabs: false,
  keywordCase: .upper,
   functionCase: .upper,
   dataTypeCase: .upper,
   identifierCase: .preserve,
   logicalOperatorNewline: .after,
  linesBetweenQueries: 1,
   expressionWidth: 50,
   newlineBeforeSemicolon: false,
   denseOperators: false,
   params: .named(["1": "42"]),
   paramTypes: ParamTypes(numbered: [.dollar])
)

let formatted = try format("SELECT Cast(name AS varchar(20)) FROM users WHERE id = $1", options: options)
```

### Params API

Use `params` together with `paramTypes` when you want upstream-style placeholder configuration:

```swift
import SQLFormatter

let positional = try format(
  "SELECT ? FROM users WHERE id = ?",
  options: FormatOptions(
    params: .positional(["name", "42"]),
    paramTypes: ParamTypes(positional: true)
  )
)

let numbered = try format(
  "SELECT $1 FROM users WHERE id = $2",
  options: FormatOptions(
    dialect: .postgreSQL,
    params: .named(["1": "name", "2": "42"])
  )
)
```

### Option reference

- `dialect` chooses the SQL dialect.
- `tabWidth` and `useTabs` control indentation.
- `keywordCase`, `functionCase`, `dataTypeCase`, and `identifierCase` control token casing.
- `logicalOperatorNewline`, `linesBetweenQueries`, `expressionWidth`, `newlineBeforeSemicolon`, and `denseOperators` control layout.
- `params` and `paramTypes` provide the main placeholder API.
- `positionalPlaceholders`, `namedPlaceholders`, and `placeholderTypes` remain available for the legacy placeholder API.

### Disable formatting blocks

```sql
SELECT id FROM users
-- sql-formatter-disable
select   id,   name   from users where active=1
-- sql-formatter-enable
SELECT id FROM teams
```

## Supported dialects

- `sql`
- `bigquery`
- `clickhouse`
- `db2`
- `db2i`
- `duckdb`
- `hive`
- `mariadb`
- `mysql`
- `tidb`
- `n1ql`
- `plsql`
- `postgresql`
- `redshift`
- `singlestoredb` (`singlestore` alias)
- `snowflake`
- `spark`
- `sqlite`
- `transactsql` (`tsql` alias)
- `trino`

You can also discover dialects by name with `DialectRegistry`.

## CLI

Format SQL from stdin:

```bash
cat query.sql | swift run sqlfmt --dialect postgresql --keyword-case upper --function-case upper --logical-operator-newline after
```

Common CLI flags:

- `--dialect`
- `--tab-width`
- `--tabs`
- `--keyword-case`
- `--function-case`
- `--data-type-case`
- `--identifier-case`
- `--logical-operator-newline`
- `--lines-between-queries`
- `--expression-width`
- `--newline-before-semicolon`
- `--dense-operators`

Run quick benchmark checks:

```bash
swift run sqlfmt-bench
```

## Release workflow

- CI build and tests run on pull requests and pushes to `main`.
- A GitHub release is created automatically when a tag like `v0.1.0` is pushed.
