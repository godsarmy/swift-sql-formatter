import Foundation
import SQLFormatter

public struct SQLFormatterCLIOptions: Sendable {
  public var dialect: Dialect = .standardSQL
  public var tabWidth: Int = 2
  public var useTabs: Bool = false
  public var indentStyle: IndentStyle = .standard
  public var keywordCase: KeywordCase = .preserve
  public var functionCase: KeywordCase = .preserve
  public var dataTypeCase: KeywordCase = .preserve
  public var identifierCase: KeywordCase = .preserve
  public var logicalOperatorNewline: LogicalOperatorNewline = .before
  public var linesBetweenQueries: Int = 1
  public var expressionWidth: Int? = 50
  public var newlineBeforeSemicolon: Bool = false
  public var denseOperators: Bool = false

  public init() {}

  public var formatOptions: FormatOptions {
    FormatOptions(
      dialect: dialect,
      tabWidth: tabWidth,
      useTabs: useTabs,
      indentStyle: indentStyle,
      keywordCase: keywordCase,
      functionCase: functionCase,
      dataTypeCase: dataTypeCase,
      identifierCase: identifierCase,
      logicalOperatorNewline: logicalOperatorNewline,
      linesBetweenQueries: linesBetweenQueries,
      expressionWidth: expressionWidth,
      newlineBeforeSemicolon: newlineBeforeSemicolon,
      denseOperators: denseOperators
    )
  }
}

public enum SQLFormatterCLIError: Error, CustomStringConvertible {
  case invalidArgument(String)
  case invalidConfig(String)

  public var description: String {
    switch self {
    case .invalidArgument(let message), .invalidConfig(let message):
      return message
    }
  }
}

public enum SQLFormatterCLIParser {
  public static func parse(
    arguments: [String],
    currentDirectory: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  ) throws -> SQLFormatterCLIOptions {
    var options = SQLFormatterCLIOptions()
    try loadConfigIfPresent(into: &options, arguments: arguments, currentDirectory: currentDirectory)
    try apply(arguments: arguments, to: &options)
    return options
  }

  public static var helpText: String {
    """
      sqlfmt - Format SQL from stdin

      Usage:
        cat query.sql | sqlfmt [options]

      Options:
        --dialect <\(DialectRegistry.names.joined(separator: "|"))>
        --language <\(DialectRegistry.names.joined(separator: "|"))>
        --config <path>
        --tab-width <n>
        --tabs
        --indent-style <standard|tabularLeft|tabularRight>
        --keyword-case <preserve|upper|lower>
        --function-case <preserve|upper|lower>
        --data-type-case <preserve|upper|lower>
        --identifier-case <preserve|upper|lower>
        --logical-operator-newline <before|after>
        --lines-between-queries <n>
        --expression-width <n>
        --newline-before-semicolon
        --dense-operators
        -h, --help
      """
  }

  private static func loadConfigIfPresent(
    into options: inout SQLFormatterCLIOptions,
    arguments: [String],
    currentDirectory: URL
  ) throws {
    let configURL = try resolveConfigURL(arguments: arguments, currentDirectory: currentDirectory)
    guard let configURL else {
      return
    }

    let data: Data
    do {
      data = try Data(contentsOf: configURL)
    } catch {
      throw SQLFormatterCLIError.invalidConfig("Unable to read config file at \(configURL.path)")
    }

    let object: Any
    do {
      object = try JSONSerialization.jsonObject(with: data)
    } catch {
      throw SQLFormatterCLIError.invalidConfig("Config file must contain valid JSON")
    }

    guard let config = object as? [String: Any] else {
      throw SQLFormatterCLIError.invalidConfig("Config file root must be a JSON object")
    }

    try apply(config: config, to: &options)
  }

  private static func resolveConfigURL(arguments: [String], currentDirectory: URL) throws -> URL? {
    if let configPath = try explicitConfigPath(arguments: arguments) {
      if configPath.hasPrefix("/") {
        return URL(fileURLWithPath: configPath).standardizedFileURL
      }

      return currentDirectory.appendingPathComponent(configPath).standardizedFileURL
    }

    for name in [".sql-formatter.json", ".sql-formatterrc"] {
      let candidate = currentDirectory.appendingPathComponent(name)
      if FileManager.default.fileExists(atPath: candidate.path) {
        return candidate
      }
    }

    return nil
  }

  private static func explicitConfigPath(arguments: [String]) throws -> String? {
    var iterator = arguments.makeIterator()

    while let argument = iterator.next() {
      guard argument == "--config" else {
        continue
      }

      guard let path = iterator.next(), !path.isEmpty else {
        throw SQLFormatterCLIError.invalidArgument("Missing value for --config")
      }

      return path
    }

    return nil
  }

  private static func apply(arguments: [String], to options: inout SQLFormatterCLIOptions) throws {
    var iterator = arguments.makeIterator()

    while let argument = iterator.next() {
      switch argument {
      case "--dialect", "--language":
        guard let value = iterator.next() else {
          throw SQLFormatterCLIError.invalidArgument("Missing value for \(argument)")
        }
        options.dialect = try parseDialect(value)
      case "--config":
        guard iterator.next() != nil else {
          throw SQLFormatterCLIError.invalidArgument("Missing value for --config")
        }
      case "--tab-width":
        guard let value = iterator.next(), let width = Int(value), width > 0 else {
          throw SQLFormatterCLIError.invalidArgument("--tab-width must be a positive integer")
        }
        options.tabWidth = width
      case "--tabs":
        options.useTabs = true
      case "--indent-style":
        guard let value = iterator.next() else {
          throw SQLFormatterCLIError.invalidArgument("Missing value for --indent-style")
        }
        options.indentStyle = try parseIndentStyle(value)
      case "--keyword-case":
        options.keywordCase = try parseKeywordCase(flag: "--keyword-case", iterator: &iterator)
      case "--function-case":
        options.functionCase = try parseKeywordCase(flag: "--function-case", iterator: &iterator)
      case "--data-type-case":
        options.dataTypeCase = try parseKeywordCase(flag: "--data-type-case", iterator: &iterator)
      case "--identifier-case":
        options.identifierCase = try parseKeywordCase(flag: "--identifier-case", iterator: &iterator)
      case "--logical-operator-newline":
        guard let value = iterator.next() else {
          throw SQLFormatterCLIError.invalidArgument("Missing value for --logical-operator-newline")
        }
        options.logicalOperatorNewline = try parseLogicalOperatorNewline(value)
      case "--lines-between-queries":
        guard let value = iterator.next(), let lines = Int(value), lines >= 0 else {
          throw SQLFormatterCLIError.invalidArgument("--lines-between-queries must be a non-negative integer")
        }
        options.linesBetweenQueries = lines
      case "--expression-width":
        guard let value = iterator.next(), let width = Int(value), width > 0 else {
          throw SQLFormatterCLIError.invalidArgument("--expression-width must be a positive integer")
        }
        options.expressionWidth = width
      case "--newline-before-semicolon":
        options.newlineBeforeSemicolon = true
      case "--dense-operators":
        options.denseOperators = true
      case "--help", "-h":
        continue
      default:
        throw SQLFormatterCLIError.invalidArgument("Unknown argument: \(argument)")
      }
    }
  }

  private static func apply(config: [String: Any], to options: inout SQLFormatterCLIOptions) throws {
    if let dialectName = stringValue(for: ["dialect", "language"], in: config) {
      options.dialect = try parseDialect(dialectName)
    }
    if let tabWidth = intValue(for: "tabWidth", in: config) {
      guard tabWidth > 0 else {
        throw SQLFormatterCLIError.invalidConfig("tabWidth must be a positive integer")
      }
      options.tabWidth = tabWidth
    }
    if let useTabs = boolValue(for: ["useTabs", "tabs"], in: config) {
      options.useTabs = useTabs
    }
    if let indentStyle = stringValue(for: ["indentStyle"], in: config) {
      options.indentStyle = try parseIndentStyle(indentStyle, source: "config")
    }
    if let keywordCase = stringValue(for: ["keywordCase"], in: config) {
      options.keywordCase = try parseKeywordCase(keywordCase, flag: "keywordCase")
    }
    if let functionCase = stringValue(for: ["functionCase"], in: config) {
      options.functionCase = try parseKeywordCase(functionCase, flag: "functionCase")
    }
    if let dataTypeCase = stringValue(for: ["dataTypeCase"], in: config) {
      options.dataTypeCase = try parseKeywordCase(dataTypeCase, flag: "dataTypeCase")
    }
    if let identifierCase = stringValue(for: ["identifierCase"], in: config) {
      options.identifierCase = try parseKeywordCase(identifierCase, flag: "identifierCase")
    }
    if let logicalOperatorNewline = stringValue(for: ["logicalOperatorNewline"], in: config) {
      options.logicalOperatorNewline = try parseLogicalOperatorNewline(
        logicalOperatorNewline,
        source: "config"
      )
    }
    if let linesBetweenQueries = intValue(for: "linesBetweenQueries", in: config) {
      guard linesBetweenQueries >= 0 else {
        throw SQLFormatterCLIError.invalidConfig("linesBetweenQueries must be a non-negative integer")
      }
      options.linesBetweenQueries = linesBetweenQueries
    }
    if let expressionWidth = intValue(for: "expressionWidth", in: config) {
      guard expressionWidth > 0 else {
        throw SQLFormatterCLIError.invalidConfig("expressionWidth must be a positive integer")
      }
      options.expressionWidth = expressionWidth
    }
    if let newlineBeforeSemicolon = boolValue(for: ["newlineBeforeSemicolon"], in: config) {
      options.newlineBeforeSemicolon = newlineBeforeSemicolon
    }
    if let denseOperators = boolValue(for: ["denseOperators"], in: config) {
      options.denseOperators = denseOperators
    }
  }

  private static func parseDialect(_ value: String) throws -> Dialect {
    guard let dialect = DialectRegistry.dialect(named: value) else {
      throw SQLFormatterCLIError.invalidArgument(
        "Unknown dialect. Available: \(DialectRegistry.names.joined(separator: ", "))"
      )
    }

    return dialect
  }

  private static func parseIndentStyle(_ value: String, source: String = "argument") throws -> IndentStyle {
    switch value {
    case "standard":
      return .standard
    case "tabularLeft":
      return .tabularLeft
    case "tabularRight":
      return .tabularRight
    default:
      let prefix = source == "config" ? "indentStyle" : "--indent-style"
      throw SQLFormatterCLIError.invalidArgument(
        "\(prefix) must be standard, tabularLeft, or tabularRight"
      )
    }
  }

  private static func parseKeywordCase(
    flag: String,
    iterator: inout IndexingIterator<[String]>
  ) throws -> KeywordCase {
    guard let value = iterator.next() else {
      throw SQLFormatterCLIError.invalidArgument("Missing value for \(flag)")
    }

    return try parseKeywordCase(value, flag: flag)
  }

  private static func parseKeywordCase(_ value: String, flag: String) throws -> KeywordCase {
    switch value.lowercased() {
    case "preserve":
      return .preserve
    case "upper":
      return .upper
    case "lower":
      return .lower
    default:
      throw SQLFormatterCLIError.invalidArgument("\(flag) must be preserve, upper, or lower")
    }
  }

  private static func parseLogicalOperatorNewline(_ value: String, source: String = "argument") throws
    -> LogicalOperatorNewline
  {
    switch value.lowercased() {
    case "before":
      return .before
    case "after":
      return .after
    default:
      let prefix = source == "config" ? "logicalOperatorNewline" : "--logical-operator-newline"
      throw SQLFormatterCLIError.invalidArgument("\(prefix) must be before or after")
    }
  }

  private static func stringValue(for keys: [String], in config: [String: Any]) -> String? {
    for key in keys {
      if let value = config[key] as? String {
        return value
      }
    }

    return nil
  }

  private static func intValue(for key: String, in config: [String: Any]) -> Int? {
    if let value = config[key] as? Int {
      return value
    }
    if let value = config[key] as? NSNumber {
      return value.intValue
    }
    return nil
  }

  private static func boolValue(for keys: [String], in config: [String: Any]) -> Bool? {
    for key in keys {
      if let value = config[key] as? Bool {
        return value
      }
      if let value = config[key] as? NSNumber {
        return value.boolValue
      }
    }

    return nil
  }
}
