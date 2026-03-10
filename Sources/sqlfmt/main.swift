import Foundation
import SQLFormatter

struct CLIOptions {
  var dialect: Dialect = .standardSQL
  var tabWidth: Int = 2
  var useTabs: Bool = false
  var keywordCase: KeywordCase = .preserve
  var functionCase: KeywordCase = .preserve
  var dataTypeCase: KeywordCase = .preserve
  var identifierCase: KeywordCase = .preserve
  var logicalOperatorNewline: LogicalOperatorNewline = .before
  var linesBetweenQueries: Int = 1
  var expressionWidth: Int? = nil
  var newlineBeforeSemicolon: Bool = false
  var denseOperators: Bool = false
}

enum CLIError: Error {
  case invalidArgument(String)
}

@main
struct SQLFormatterCLI {
  static func main() {
    do {
      var options = CLIOptions()
      try parseArguments(into: &options)
      let sql = try readSTDIN()

      let formatOptions = FormatOptions(
        dialect: options.dialect,
        tabWidth: options.tabWidth,
        useTabs: options.useTabs,
        keywordCase: options.keywordCase,
        functionCase: options.functionCase,
        dataTypeCase: options.dataTypeCase,
        identifierCase: options.identifierCase,
        logicalOperatorNewline: options.logicalOperatorNewline,
        linesBetweenQueries: options.linesBetweenQueries,
        expressionWidth: options.expressionWidth,
        newlineBeforeSemicolon: options.newlineBeforeSemicolon,
        denseOperators: options.denseOperators
      )

      let formatted = try format(sql, options: formatOptions)
      FileHandle.standardOutput.write(Data(formatted.utf8))
      FileHandle.standardOutput.write(Data("\n".utf8))
    } catch {
      FileHandle.standardError.write(Data("\(error)\n".utf8))
      exit(1)
    }
  }

  private static func readSTDIN() throws -> String {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    guard let input = String(data: data, encoding: .utf8), !input.isEmpty else {
      throw CLIError.invalidArgument("No SQL input provided on stdin")
    }
    return input
  }

  private static func parseArguments(into options: inout CLIOptions) throws {
    var iterator = CommandLine.arguments.dropFirst().makeIterator()

    while let argument = iterator.next() {
      switch argument {
      case "--help", "-h":
        printHelpAndExit()
      case "--dialect":
        guard let value = iterator.next(), let dialect = DialectRegistry.dialect(named: value)
        else {
          throw CLIError.invalidArgument(
            "Unknown dialect. Available: \(DialectRegistry.names.joined(separator: ", "))"
          )
        }
        options.dialect = dialect
      case "--tab-width":
        guard let value = iterator.next(), let width = Int(value), width > 0 else {
          throw CLIError.invalidArgument("--tab-width must be a positive integer")
        }
        options.tabWidth = width
      case "--tabs":
        options.useTabs = true
      case "--keyword-case":
        options.keywordCase = try parseKeywordCase(flag: "--keyword-case", iterator: &iterator)
      case "--function-case":
        options.functionCase = try parseKeywordCase(flag: "--function-case", iterator: &iterator)
      case "--data-type-case":
        options.dataTypeCase = try parseKeywordCase(flag: "--data-type-case", iterator: &iterator)
      case "--identifier-case":
        options.identifierCase = try parseKeywordCase(
          flag: "--identifier-case", iterator: &iterator)
      case "--logical-operator-newline":
        guard let value = iterator.next() else {
          throw CLIError.invalidArgument("Missing value for --logical-operator-newline")
        }

        switch value.lowercased() {
        case "before":
          options.logicalOperatorNewline = .before
        case "after":
          options.logicalOperatorNewline = .after
        default:
          throw CLIError.invalidArgument("--logical-operator-newline must be before or after")
        }
      case "--lines-between-queries":
        guard let value = iterator.next(), let lines = Int(value), lines >= 0 else {
          throw CLIError.invalidArgument("--lines-between-queries must be a non-negative integer")
        }
        options.linesBetweenQueries = lines
      case "--expression-width":
        guard let value = iterator.next(), let width = Int(value), width > 0 else {
          throw CLIError.invalidArgument("--expression-width must be a positive integer")
        }
        options.expressionWidth = width
      case "--newline-before-semicolon":
        options.newlineBeforeSemicolon = true
      case "--dense-operators":
        options.denseOperators = true
      default:
        throw CLIError.invalidArgument("Unknown argument: \(argument)")
      }
    }
  }

  private static func parseKeywordCase(
    flag: String,
    iterator: inout IndexingIterator<ArraySlice<String>>
  ) throws -> KeywordCase {
    guard let value = iterator.next() else {
      throw CLIError.invalidArgument("Missing value for \(flag)")
    }

    switch value.lowercased() {
    case "preserve":
      return .preserve
    case "upper":
      return .upper
    case "lower":
      return .lower
    default:
      throw CLIError.invalidArgument("\(flag) must be preserve, upper, or lower")
    }
  }

  private static func printHelpAndExit() -> Never {
    let help = """
      sqlfmt - Format SQL from stdin

      Usage:
        cat query.sql | sqlfmt [options]

      Options:
        --dialect <\(DialectRegistry.names.joined(separator: "|"))>
        --tab-width <n>
        --tabs
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

    print(help)
    exit(0)
  }
}
