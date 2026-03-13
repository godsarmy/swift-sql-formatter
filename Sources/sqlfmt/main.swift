import Foundation
import SQLFormatter
import SQLFormatterCLICommon

@main
struct SQLFormatterCLI {
  static func main() {
    do {
      if CommandLine.arguments.dropFirst().contains(where: { ["--help", "-h"].contains($0) }) {
        print(SQLFormatterCLIParser.helpText)
        exit(0)
      }

      let arguments = Array(CommandLine.arguments.dropFirst())
      let options = try SQLFormatterCLIParser.parse(arguments: arguments)
      let sql = try readSTDIN()
      let formatted = try format(sql, options: options.formatOptions)
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
      throw SQLFormatterCLIError.invalidArgument("No SQL input provided on stdin")
    }
    return input
  }
}
