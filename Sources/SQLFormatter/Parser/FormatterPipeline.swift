struct FormatterPipeline {
  let options: FormatOptions

  func format(tokens: [Token], originalSQL: String) throws -> String {
    let buffer = OutputBuffer(
      indentation: options.useTabs ? "\t" : String(repeating: " ", count: options.tabWidth)
    )
    _ = buffer
    return tokens.map(\.text).joined()
  }
}
