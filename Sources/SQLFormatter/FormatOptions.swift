public enum KeywordCase: Sendable {
  case preserve
  case upper
  case lower
}

public struct FormatOptions: Sendable {
  public static let `default` = FormatOptions()

  public var dialect: Dialect
  public var tabWidth: Int
  public var useTabs: Bool
  public var keywordCase: KeywordCase
  public var linesBetweenQueries: Int
  public var expressionWidth: Int?

  public init(
    dialect: Dialect = .standardSQL,
    tabWidth: Int = 2,
    useTabs: Bool = false,
    keywordCase: KeywordCase = .preserve,
    linesBetweenQueries: Int = 1,
    expressionWidth: Int? = nil
  ) {
    self.dialect = dialect
    self.tabWidth = tabWidth
    self.useTabs = useTabs
    self.keywordCase = keywordCase
    self.linesBetweenQueries = linesBetweenQueries
    self.expressionWidth = expressionWidth
  }
}
