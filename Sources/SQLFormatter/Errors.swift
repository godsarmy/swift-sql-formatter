public enum FormatError: Error, Equatable, Sendable {
  case unsupportedFeature(String)
  case unterminatedQuotedToken
}
