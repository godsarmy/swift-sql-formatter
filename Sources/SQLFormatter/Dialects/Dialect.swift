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
      "ASC", "DESC",
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
      "ASC", "DESC", "RECURSIVE",
    ]
  )
}
