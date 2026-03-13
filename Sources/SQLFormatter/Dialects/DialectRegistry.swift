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
    Array(Set(canonicalNames(additionalDialects: additionalDialects) + aliases.keys)).sorted()
  }

  public static func dialect(named name: String) -> Dialect? {
    dialect(named: name, additionalDialects: [])
  }

  public static func dialect(named name: String, additionalDialects: [Dialect]) -> Dialect? {
    let normalizedName = name.lowercased()
    let candidateDialects = additionalDialects + all
    let canonicalName = aliases[normalizedName] ?? normalizedName

    return candidateDialects.first { dialect in
      dialect.name.lowercased() == canonicalName
    }
  }

  private static let aliases: [String: String] = [
    "postgres": "postgresql",
    "singlestore": "singlestoredb",
    "tsql": "transactsql",
  ]
}
