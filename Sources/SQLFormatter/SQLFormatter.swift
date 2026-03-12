public struct Formatter: Sendable {
  public let options: FormatOptions

  public init(options: FormatOptions = .default) {
    self.options = options
  }

  public func format(_ sql: String) throws -> String {
    let tokenizer = Tokenizer(dialect: options.dialect)
    let tokens = try tokenizer.tokenize(sql)
    let pipeline = FormatterPipeline(options: options)
    return try pipeline.format(tokens: tokens, originalSQL: sql)
  }
}

public func format(_ sql: String, options: FormatOptions = .default) throws -> String {
  try Formatter(options: options).format(sql)
}

public func formatDialect(_ sql: String, dialect: Dialect, options: FormatOptions = .default)
  throws -> String
{
  var resolvedOptions = options
  resolvedOptions.dialect = dialect
  return try format(sql, options: resolvedOptions)
}
