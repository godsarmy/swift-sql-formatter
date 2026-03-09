public enum TokenType: Sendable {
  case word
  case quoted
  case `operatorToken`
  case comment
  case whitespace
  case newline
  case punctuation
}

public struct Token: Sendable {
  public let type: TokenType
  public let text: String

  public init(type: TokenType, text: String) {
    self.type = type
    self.text = text
  }
}
