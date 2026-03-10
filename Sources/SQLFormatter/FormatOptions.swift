import Foundation

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

public enum ParameterPrefix: Character, Sendable, Hashable, CaseIterable {
  case questionMark = "?"
  case colon = ":"
  case at = "@"
  case dollar = "$"
}

public struct CustomParameterType: @unchecked Sendable {
  public let regex: String
  public let key: (@Sendable (String) -> String)?

  public init(regex: String, key: (@Sendable (String) -> String)? = nil) {
    self.regex = regex
    self.key = key
  }
}

public struct ParamTypes: Sendable {
  public var positional: Bool
  public var numbered: Set<ParameterPrefix>
  public var named: Set<ParameterPrefix>
  public var quoted: Set<ParameterPrefix>
  public var custom: [CustomParameterType]

  public init(
    positional: Bool = false,
    numbered: Set<ParameterPrefix> = [],
    named: Set<ParameterPrefix> = [],
    quoted: Set<ParameterPrefix> = [],
    custom: [CustomParameterType] = []
  ) {
    self.positional = positional
    self.numbered = numbered
    self.named = named
    self.quoted = quoted
    self.custom = custom
  }

  public static func defaults(for dialect: Dialect) -> ParamTypes {
    switch dialect.name {
    case "bigquery":
      return ParamTypes(positional: true, named: [.at], quoted: [.at])
    case "clickhouse":
      return ParamTypes(
        custom: [
          CustomParameterType(
            regex: #"\{[a-zA-Z_][a-zA-Z0-9_]*:[^{}]+\}"#,
            key: { text in
              let trimmed = String(text.dropFirst().dropLast())
              return String(trimmed.prefix { $0 != ":" })
            }
          )
        ])
    case "db2", "db2i":
      return ParamTypes(positional: true, named: [.colon])
    case "mariadb", "mysql", "tidb", "sql":
      return ParamTypes(positional: true)
    case "n1ql":
      return ParamTypes(numbered: [.dollar], named: [.dollar])
    case "plsql":
      return ParamTypes(numbered: [.colon], named: [.colon])
    case "postgresql", "redshift":
      return ParamTypes(numbered: [.dollar])
    case "sqlite":
      return ParamTypes(positional: true, numbered: [.questionMark], named: [.colon, .at, .dollar])
    case "transactsql":
      return ParamTypes(named: [.at], quoted: [.at])
    default:
      return ParamTypes()
    }
  }
}

public enum Params: Sendable {
  case positional([String])
  case named([String: String])
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
  public var params: Params?
  public var paramTypes: ParamTypes?

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
    ],
    params: Params? = nil,
    paramTypes: ParamTypes? = nil
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
    self.params = params
    self.paramTypes = paramTypes
  }

  var resolvedParamTypes: ParamTypes {
    if let paramTypes {
      return paramTypes
    }

    if params != nil {
      return ParamTypes.defaults(for: dialect)
    }

    return ParamTypes(
      positional: placeholderTypes.contains(.questionMark),
      named: legacyNamedPrefixes
    )
  }

  var resolvedPositionalParams: [String] {
    if case .positional(let values)? = params {
      return values
    }

    return positionalPlaceholders
  }

  var resolvedNamedParams: [String: String] {
    if case .named(let values)? = params {
      return namedPlaceholders.merging(values) { _, new in new }
    }

    return namedPlaceholders
  }

  private var legacyNamedPrefixes: Set<ParameterPrefix> {
    var prefixes: Set<ParameterPrefix> = []

    if placeholderTypes.contains(.colonNamed) {
      prefixes.insert(.colon)
    }
    if placeholderTypes.contains(.atNamed) {
      prefixes.insert(.at)
    }
    if placeholderTypes.contains(.dollarNamed) {
      prefixes.insert(.dollar)
    }

    return prefixes
  }
}
