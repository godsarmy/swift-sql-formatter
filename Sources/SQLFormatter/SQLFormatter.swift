public func format(_ sql: String, options: FormatOptions = .default) throws -> String {
  let tokenizer = Tokenizer(dialect: options.dialect)
  let tokens = try tokenizer.tokenize(sql)
  let pipeline = FormatterPipeline(options: options)
  return try pipeline.format(tokens: tokens, originalSQL: sql)
}
