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
  linesBetweenQueries: 1,
  expressionWidth: 80,
  positionalPlaceholders: ["42"],
  namedPlaceholders: ["column": "name"],
  placeholderTypes: [.questionMark, .colonNamed]
)

let formatted = try format("SELECT :column FROM users WHERE id = ?", options: options)
```

### Disable formatting blocks

```sql
SELECT id FROM users
-- sql-formatter-disable
select   id,   name   from users where active=1
-- sql-formatter-enable
SELECT id FROM teams
```

## Supported dialects

- `Dialect.standardSQL`
- `Dialect.postgreSQL`

You can also discover dialects by name with `DialectRegistry`.

## CLI

Format SQL from stdin:

```bash
cat query.sql | swift run sqlfmt --dialect postgresql --keyword-case upper
```

Run quick benchmark checks:

```bash
swift run sqlfmt-bench
```

## Release workflow

- CI build and tests run on pull requests and pushes to `main`.
- A GitHub release is created automatically when a tag like `v0.1.0` is pushed.
