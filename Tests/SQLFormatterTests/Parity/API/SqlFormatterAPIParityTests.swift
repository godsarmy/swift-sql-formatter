import Testing

@testable import SQLFormatter

// Upstream: test/sqlFormatter.test.ts :: throws error when unsupported language parameter specified
// N/A: Swift API enforces dialect selection with typed `Dialect` values.

// Upstream: test/sqlFormatter.test.ts :: when encountering unsupported characters with default dialect
// N/A: Swift tokenizer treats unfamiliar characters as identifiers rather than throwing.

// Upstream: test/sqlFormatter.test.ts :: when encountering unsupported characters with sqlite dialect
// N/A: Same as above; no dialect-specific unsupported character errors are thrown.

// Upstream: test/sqlFormatter.test.ts :: throws error when encountering incorrect SQL grammar
// N/A: Swift formatting pipeline does not validate SQL grammar beyond tokenization.

// Upstream: test/sqlFormatter.test.ts :: throws error when query argument is not string
// N/A: Swift `format(_:)` accepts only `String` so invalid arguments cannot be encoded.

// Upstream: test/sqlFormatter.test.ts :: throws error when multilineLists config option used
// N/A: The deprecated `multilineLists` option is not exposed in Swift `FormatOptions`.

// Upstream: test/sqlFormatter.test.ts :: throws error when newlineBeforeOpenParen config option used
// N/A: `newlineBeforeOpenParen` is not a supported Swift option.

// Upstream: test/sqlFormatter.test.ts :: throws error when newlineBeforeCloseParen config option used
// N/A: `newlineBeforeCloseParen` is not a supported Swift option.

// Upstream: test/sqlFormatter.test.ts :: throws error when aliasAs config option used
// N/A: `aliasAs` is not supported by Swift `FormatOptions`.

// Upstream: test/sqlFormatter.test.ts :: throws error when tabulateAlias config option used
// N/A: `tabulateAlias` is not supported by Swift `FormatOptions`.

// Upstream: test/sqlFormatter.test.ts :: throws error when commaPosition config option used
// N/A: `commaPosition` is not supported by Swift `FormatOptions`.

// Upstream: test/sqlFormatter.test.ts :: does nothing with empty input
@Test func parity_sqlFormatter_doesNothingWithEmptyInput() throws {
  try assertFormat("", "")
}

// Upstream: test/sqlFormatter.test.ts :: formatDialect allows passing Dialect config object as a dialect parameter
@Test func parity_sqlFormatter_formatDialectAcceptsDialectObject() throws {
  try assertFormatDialect(
    "SELECT [foo], `bar`;",
    dialect: .sqlite,
    """
    SELECT
      [foo],
      `bar`;
    """
  )
}

// Upstream: test/sqlFormatter.test.ts :: allows use of regex-based custom string type
// N/A: Swift dialect/tokenizer customization currently lacks regex-based string type extensions.
