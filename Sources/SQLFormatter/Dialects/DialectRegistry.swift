public enum DialectRegistry {
  public static var all: [Dialect] {
    [
      .standardSQL,
      .bigQuery,
      .clickHouse,
      .db2,
      .db2i,
      .duckDB,
      .hive,
      .mariaDB,
      .mySQL,
      .tiDB,
      .n1ql,
      .plSQL,
      .postgreSQL,
      .redshift,
      .singleStoreDB,
      .snowflake,
      .spark,
      .sqlite,
      .transactSQL,
      .trino,
    ]
  }

  public static var canonicalNames: [String] {
    canonicalNames(additionalDialects: [])
  }

  public static func canonicalNames(additionalDialects: [Dialect]) -> [String] {
    let names = (additionalDialects + all).map { dialect in
      dialect.name.lowercased()
    }

    return Array(Set(names)).sorted()
  }

  public static var names: [String] {
    names(additionalDialects: [])
  }

  public static func names(additionalDialects: [Dialect]) -> [String] {
    names(additionalDialects: additionalDialects, additionalAliases: [:])
  }

  public static func names(additionalDialects: [Dialect], additionalAliases: [String: String])
    -> [String]
  {
    let mergedAliases = mergedAliases(with: additionalAliases)
    return Array(Set(canonicalNames(additionalDialects: additionalDialects) + mergedAliases.keys))
      .sorted()
  }

  public static func dialect(named name: String) -> Dialect? {
    dialect(named: name, additionalDialects: [])
  }

  public static func dialect(named name: String, additionalDialects: [Dialect]) -> Dialect? {
    dialect(named: name, additionalDialects: additionalDialects, additionalAliases: [:])
  }

  public static func dialect(
    named name: String,
    additionalDialects: [Dialect],
    additionalAliases: [String: String]
  ) -> Dialect? {
    let normalizedName = name.lowercased()
    let candidateDialects = additionalDialects + all
    let canonicalName = resolveCanonicalName(
      for: normalizedName,
      aliases: mergedAliases(with: additionalAliases)
    )

    return candidateDialects.first { dialect in
      dialect.name.lowercased() == canonicalName
    }
  }

  private static let aliases: [String: String] = [
    "postgres": "postgresql",
    "singlestore": "singlestoredb",
    "tsql": "transactsql",
  ]

  private static func mergedAliases(with additionalAliases: [String: String]) -> [String: String] {
    aliases.merging(
      additionalAliases.reduce(into: [String: String]()) { result, entry in
        result[entry.key.lowercased()] = entry.value.lowercased()
      }
    ) { current, _ in
      current
    }
  }

  private static func resolveCanonicalName(for name: String, aliases: [String: String]) -> String {
    var seen = Set<String>()
    var current = name

    while let next = aliases[current], !seen.contains(current) {
      seen.insert(current)
      current = next
    }

    return current
  }
}
