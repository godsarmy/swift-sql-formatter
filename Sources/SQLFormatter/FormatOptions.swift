public struct FormatOptions: Sendable {
  public static let `default` = FormatOptions()

  public var dialect: Dialect
  public var tabWidth: Int
  public var useTabs: Bool
  public var linesBetweenQueries: Int

  public init(
    dialect: Dialect = .standardSQL,
    tabWidth: Int = 2,
    useTabs: Bool = false,
    linesBetweenQueries: Int = 1
  ) {
    self.dialect = dialect
    self.tabWidth = tabWidth
    self.useTabs = useTabs
    self.linesBetweenQueries = linesBetweenQueries
  }
}
