import Foundation
import SQLFormatter

private struct BenchmarkCase {
  let name: String
  let sql: String
  let options: FormatOptions
}

@main
struct SQLFormatterBenchmark {
  static func main() {
    let cases: [BenchmarkCase] = [
      BenchmarkCase(
        name: "standard-select",
        sql: "SELECT id, name FROM users WHERE active = 1 ORDER BY name LIMIT 100",
        options: .default
      ),
      BenchmarkCase(
        name: "postgres-returning",
        sql: "SELECT \"name\" FROM \"users\" WHERE active = 1 RETURNING id",
        options: FormatOptions(dialect: .postgreSQL, keywordCase: .upper)
      ),
      BenchmarkCase(
        name: "multi-query",
        sql: "SELECT id FROM users; SELECT id FROM teams; SELECT id FROM offices",
        options: FormatOptions(linesBetweenQueries: 1)
      ),
    ]

    let iterations = 500

    for benchmark in cases {
      let start = DispatchTime.now().uptimeNanoseconds

      for _ in 0..<iterations {
        _ = try? format(benchmark.sql, options: benchmark.options)
      }

      let end = DispatchTime.now().uptimeNanoseconds
      let elapsedMs = Double(end - start) / 1_000_000.0
      print(
        "\(benchmark.name): \(String(format: "%.2f", elapsedMs)) ms for \(iterations) iterations")
    }
  }
}
