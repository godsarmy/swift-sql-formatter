public enum KeywordCase: Sendable {
  case preserve
  case upper
  case lower
}

public enum PlaceholderType: Sendable, Hashable {
  case questionMark
  case colonNamed
  case atNamed
  case dollarNamed
}

public struct FormatOptions: Sendable {
  public static let `default` = FormatOptions()

  public var dialect: Dialect
  public var tabWidth: Int
  public var useTabs: Bool
  public var keywordCase: KeywordCase
  public var linesBetweenQueries: Int
  public var expressionWidth: Int?
  public var positionalPlaceholders: [String]
  public var namedPlaceholders: [String: String]
  public var placeholderTypes: Set<PlaceholderType>

  public init(
    dialect: Dialect = .standardSQL,
    tabWidth: Int = 2,
    useTabs: Bool = false,
    keywordCase: KeywordCase = .preserve,
    linesBetweenQueries: Int = 1,
    expressionWidth: Int? = nil,
    positionalPlaceholders: [String] = [],
    namedPlaceholders: [String: String] = [:],
    placeholderTypes: Set<PlaceholderType> = [
      .questionMark, .colonNamed, .atNamed, .dollarNamed,
    ]
  ) {
    self.dialect = dialect
    self.tabWidth = tabWidth
    self.useTabs = useTabs
    self.keywordCase = keywordCase
    self.linesBetweenQueries = linesBetweenQueries
    self.expressionWidth = expressionWidth
    self.positionalPlaceholders = positionalPlaceholders
    self.namedPlaceholders = namedPlaceholders
    self.placeholderTypes = placeholderTypes
  }
}
