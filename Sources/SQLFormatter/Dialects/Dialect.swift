public struct Dialect: Sendable, Hashable {
  public let name: String
  public let quotedIdentifierDelimiters: [Character: Character]
  public let punctuationCharacters: Set<Character>
  public let operatorCharacters: Set<Character>
  public let clauseKeywords: Set<String>
  public let compoundClauseKeywords: [String: Set<String>]
  public let joinModifierKeywords: Set<String>
  public let outerJoinModifierKeywords: Set<String>
  public let reservedWords: Set<String>

  public init(
    name: String,
    quotedIdentifierDelimiters: [Character: Character],
    punctuationCharacters: Set<Character>,
    operatorCharacters: Set<Character>,
    clauseKeywords: Set<String>,
    compoundClauseKeywords: [String: Set<String>],
    joinModifierKeywords: Set<String>,
    outerJoinModifierKeywords: Set<String>,
    reservedWords: Set<String>
  ) {
    self.name = name
    self.quotedIdentifierDelimiters = quotedIdentifierDelimiters
    self.punctuationCharacters = punctuationCharacters
    self.operatorCharacters = operatorCharacters
    self.clauseKeywords = clauseKeywords
    self.compoundClauseKeywords = compoundClauseKeywords
    self.joinModifierKeywords = joinModifierKeywords
    self.outerJoinModifierKeywords = outerJoinModifierKeywords
    self.reservedWords = reservedWords
  }

  public static let standardSQL = Dialect(
    name: "sql",
    quotedIdentifierDelimiters: ["\"": "\"", "`": "`", "[": "]", "'": "'"],
    punctuationCharacters: [",", "(", ")", ";", "."],
    operatorCharacters: ["=", ">", "<", "!", "+", "-", "*", "/", "%"],
    clauseKeywords: ["WITH", "SELECT", "FROM", "WHERE", "LIMIT", "HAVING", "ON"],
    compoundClauseKeywords: ["GROUP": ["BY"], "ORDER": ["BY"]],
    joinModifierKeywords: ["INNER", "CROSS", "NATURAL", "STRAIGHT"],
    outerJoinModifierKeywords: ["LEFT", "RIGHT", "FULL"],
    reservedWords: [
      "SELECT", "FROM", "WHERE", "LIMIT", "HAVING", "ON", "GROUP", "BY", "ORDER",
      "JOIN", "INNER", "LEFT", "RIGHT", "FULL", "CROSS", "NATURAL", "STRAIGHT", "OUTER",
      "ASC", "AS", "DESC",
    ]
  )

  public static let postgreSQL = Dialect(
    name: "postgresql",
    quotedIdentifierDelimiters: ["\"": "\"", "'": "'"],
    punctuationCharacters: [",", "(", ")", ";", "."],
    operatorCharacters: [
      "=", ">", "<", "!", "+", "-", "*", "/", "%", "|", "&", "#", "~", "^", "?", ":",
    ],
    clauseKeywords: ["WITH", "SELECT", "FROM", "WHERE", "LIMIT", "HAVING", "ON", "RETURNING"],
    compoundClauseKeywords: ["GROUP": ["BY"], "ORDER": ["BY"]],
    joinModifierKeywords: ["INNER", "CROSS", "NATURAL", "STRAIGHT"],
    outerJoinModifierKeywords: ["LEFT", "RIGHT", "FULL"],
    reservedWords: [
      "SELECT", "FROM", "WHERE", "LIMIT", "HAVING", "ON", "GROUP", "BY", "ORDER",
      "JOIN", "INNER", "LEFT", "RIGHT", "FULL", "CROSS", "NATURAL", "STRAIGHT", "OUTER",
      "USING", "RETURNING", "ILIKE",
      "ASC", "AS", "DESC", "RECURSIVE",
    ]
  )

  public static let bigQuery = standardSQL.copy(
    name: "bigquery",
    quotedIdentifierDelimiters: ["`": "`", "\"": "\"", "'": "'"]
  )
  public static let clickHouse = standardSQL.copy(
    name: "clickhouse",
    clauseKeywords: standardSQL.clauseKeywords.union(["GRANT", "REVOKE"]),
    compoundClauseKeywords: standardSQL.compoundClauseKeywords.merging(["INSERT": ["INTO"]]) {
      current, _ in current
    },
    reservedWords: standardSQL.reservedWords.union([
      "GRANT", "INSERT", "INTO", "REVOKE", "TO",
    ])
  )
  public static let db2 = standardSQL.copy(name: "db2")
  public static let db2i = standardSQL.copy(name: "db2i")
  public static let duckDB = postgreSQL.copy(name: "duckdb")
  public static let hive = standardSQL.copy(
    name: "hive", quotedIdentifierDelimiters: ["`": "`", "\"": "\"", "'": "'"])
  public static let mariaDB = standardSQL.copy(
    name: "mariadb", quotedIdentifierDelimiters: ["`": "`", "\"": "\"", "'": "'"])
  public static let mySQL = mariaDB.copy(name: "mysql")
  public static let tiDB = mySQL.copy(name: "tidb")
  public static let n1ql = postgreSQL.copy(name: "n1ql")
  public static let plSQL = postgreSQL.copy(name: "plsql")
  public static let redshift = postgreSQL.copy(name: "redshift")
  public static let singleStoreDB = mySQL.copy(name: "singlestoredb")
  public static let snowflake = postgreSQL.copy(name: "snowflake")
  public static let spark = standardSQL.copy(name: "spark")
  public static let sqlite = standardSQL.copy(name: "sqlite")
  public static let transactSQL = standardSQL.copy(
    name: "transactsql",
    quotedIdentifierDelimiters: ["[": "]", "\"": "\"", "'": "'"],
    clauseKeywords: standardSQL.clauseKeywords.union([
      "ALTER", "AS", "BREAK", "CREATE", "ELSE", "GO", "IF", "RETURN", "SET", "WHILE",
    ]),
    compoundClauseKeywords: standardSQL.compoundClauseKeywords.merging(["ELSE": ["IF"]]) {
      current, _ in current
    },
    reservedWords: standardSQL.reservedWords.union([
      "ALTER", "AS", "BEGIN", "BREAK", "CREATE", "ELSE", "END", "GO", "IF", "NOCOUNT",
      "OFF", "ON", "OR", "PROCEDURE", "RETURN", "SET", "WHILE",
    ])
  )
  public static let trino = postgreSQL.copy(name: "trino")

  private func copy(
    name: String,
    quotedIdentifierDelimiters: [Character: Character]? = nil,
    punctuationCharacters: Set<Character>? = nil,
    operatorCharacters: Set<Character>? = nil,
    clauseKeywords: Set<String>? = nil,
    compoundClauseKeywords: [String: Set<String>]? = nil,
    joinModifierKeywords: Set<String>? = nil,
    outerJoinModifierKeywords: Set<String>? = nil,
    reservedWords: Set<String>? = nil
  ) -> Dialect {
    Dialect(
      name: name,
      quotedIdentifierDelimiters: quotedIdentifierDelimiters ?? self.quotedIdentifierDelimiters,
      punctuationCharacters: punctuationCharacters ?? self.punctuationCharacters,
      operatorCharacters: operatorCharacters ?? self.operatorCharacters,
      clauseKeywords: clauseKeywords ?? self.clauseKeywords,
      compoundClauseKeywords: compoundClauseKeywords ?? self.compoundClauseKeywords,
      joinModifierKeywords: joinModifierKeywords ?? self.joinModifierKeywords,
      outerJoinModifierKeywords: outerJoinModifierKeywords ?? self.outerJoinModifierKeywords,
      reservedWords: reservedWords ?? self.reservedWords
    )
  }
}
