public struct SourceLocation: Equatable, Sendable {
  public let line: Int
  public let column: Int
  public let offset: Int

  public init(line: Int, column: Int, offset: Int) {
    self.line = line
    self.column = column
    self.offset = offset
  }
}

public enum FormatError: Error, Equatable, Sendable {
  case unsupportedFeature(String)
  case unterminatedQuotedToken(at: SourceLocation)
  case unterminatedBlockComment(at: SourceLocation)
}
