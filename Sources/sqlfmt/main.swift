import Foundation
import SQLFormatter

struct CLIOptions {
  var dialect: Dialect = .standardSQL
  var tabWidth: Int = 2
  var useTabs: Bool = false
  var keywordCase: KeywordCase = .preserve
  var linesBetweenQueries: Int = 1
  var expressionWidth: Int? = nil
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
        linesBetweenQueries: options.linesBetweenQueries,
        expressionWidth: options.expressionWidth
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
          throw CLIError.invalidArgument("Unknown dialect. Available: sql, postgresql")
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
        --dialect <sql|postgresql>
        --tab-width <n>
        --tabs
        --keyword-case <preserve|upper|lower>
        --lines-between-queries <n>
        --expression-width <n>
        -h, --help
      """

    print(help)
    exit(0)
  }
}
