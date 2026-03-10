import Foundation
import SQLFormatter

struct CLIOptions {
  var dialect: Dialect = .standardSQL
  var tabWidth: Int = 2
  var useTabs: Bool = false
  var keywordCase: KeywordCase = .preserve
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
        guard let value = iterator.next() else {
          throw CLIError.invalidArgument("Missing value for --keyword-case")
        }

        switch value.lowercased() {
        case "preserve":
          options.keywordCase = .preserve
        case "upper":
          options.keywordCase = .upper
        case "lower":
          options.keywordCase = .lower
        default:
          throw CLIError.invalidArgument("--keyword-case must be preserve, upper, or lower")
        }
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
