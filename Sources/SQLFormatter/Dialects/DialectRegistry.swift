public enum DialectRegistry {
  public static var all: [Dialect] {
    [
      .standardSQL
    ]
  }

  public static func dialect(named name: String) -> Dialect? {
    let normalizedName = name.lowercased()
    return all.first { dialect in
      dialect.name.lowercased() == normalizedName
    }
  }
}
