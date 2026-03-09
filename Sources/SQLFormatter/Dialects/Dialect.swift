public struct Dialect: Sendable, Hashable {
  public let name: String

  public init(name: String) {
    self.name = name
  }

  public static let standardSQL = Dialect(name: "sql")
}
