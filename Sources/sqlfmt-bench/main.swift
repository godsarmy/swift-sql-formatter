import Foundation
import SQLFormatter

private struct BenchmarkCase {
  let name: String
  let sql: String
  let options: FormatOptions
  let iterations: Int
}

@main
struct SQLFormatterBenchmark {
  static func main() {
    runMemorySmokeChecks()

    let cases: [BenchmarkCase] = [
      BenchmarkCase(
        name: "standard-select",
        sql: "SELECT id, name FROM users WHERE active = 1 ORDER BY name LIMIT 100",
        options: .default,
        iterations: 100
      ),
      BenchmarkCase(
        name: "postgres-returning",
        sql: "SELECT \"name\" FROM \"users\" WHERE active = 1 RETURNING id",
        options: FormatOptions(dialect: .postgreSQL, keywordCase: .upper),
        iterations: 100
      ),
      BenchmarkCase(
        name: "multi-query",
        sql: "SELECT id FROM users; SELECT id FROM teams; SELECT id FROM offices",
        options: FormatOptions(linesBetweenQueries: 1),
        iterations: 100
      ),
      BenchmarkCase(
        name: "perf-test-mysql-batch",
        sql: makePerfTestBatchSQL(),
        options: FormatOptions(dialect: .mySQL),
        iterations: 1
      ),
    ]

    for benchmark in cases {
      let start = DispatchTime.now().uptimeNanoseconds

      for _ in 0..<benchmark.iterations {
        _ = try? format(benchmark.sql, options: benchmark.options)
      }

      let end = DispatchTime.now().uptimeNanoseconds
      let elapsedMs = Double(end - start) / 1_000_000.0
      print(
        "\(benchmark.name): \(String(format: "%.2f", elapsedMs)) ms for \(benchmark.iterations) iterations"
      )
    }
  }

  // Adapted from upstream test/perftest.ts (non-blocking memory smoke checks).
  private static func runMemorySmokeChecks() {
    print("memory-smoke: starting")

    let baselineMB = currentRSSInMB()
    _ = try? format("", options: .default)
    let afterEmptyMB = currentRSSInMB()

    let largeListSQL = makeLargeSelectListSQL(count: 2_000)
    _ = try? format(largeListSQL, options: .default)
    let afterLargeMB = currentRSSInMB()

    let deltaEmptyMB = max(0, afterEmptyMB - baselineMB)
    let deltaLargeMB = max(0, afterLargeMB - afterEmptyMB)

    print("memory-smoke.empty-query: baseline=\(baselineMB) MB, delta=\(deltaEmptyMB) MB")
    print("memory-smoke.large-query: size=\(largeListSQL.count) chars, delta=\(deltaLargeMB) MB")
  }

  private static func currentRSSInMB() -> Int {
    #if os(Linux)
      guard let contents = try? String(contentsOfFile: "/proc/self/statm", encoding: .utf8) else {
        return -1
      }

      let parts = contents.split(separator: " ")
      guard parts.count > 1, let residentPages = Int(parts[1]) else {
        return -1
      }

      let pageSize = Int(sysconf(Int32(_SC_PAGESIZE)))
      return residentPages * pageSize / (1024 * 1024)
    #else
      return -1
    #endif
  }

  private static func makeLargeSelectListSQL(count: Int) -> String {
    let values = Array(repeating: "myid", count: count)
    return "SELECT \(values.joined(separator: ", "))"
  }

  // Adapted from upstream test/perf/perf-test.js representative query batch.
  private static func makePerfTestBatchSQL() -> String {
    let block =
      """
      select supplier_name,city from (select * from suppliers join addresses on suppliers.address_id=addresses.id) as suppliers where supplier_id>500 order by supplier_name asc,city desc;
      ALTER TABLE Album ADD CONSTRAINT FK_AlbumArtistId FOREIGN KEY (ArtistId) REFERENCES Artist (ArtistId) ON DELETE NO ACTION ON UPDATE NO ACTION;
      CREATE TABLE Customer ( CustomerId INT NOT NULL AUTO_INCREMENT, FirstName NVARCHAR(40) NOT NULL, LastName NVARCHAR(20) NOT NULL, Company NVARCHAR(80), Address NVARCHAR(70), City NVARCHAR(40), State NVARCHAR(40), Country NVARCHAR(40), PostalCode NVARCHAR(10), Phone NVARCHAR(24), Fax NVARCHAR(24), Email NVARCHAR(60) NOT NULL, SupportRepId INT, CONSTRAINT PK_Customer PRIMARY KEY  (CustomerId));
      INSERT INTO Track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES ('Jump Around', 258, 1, 17, 'E. Schrody/L. Muggerud', 217835, 8715653, 0.99);
      INSERT INTO Track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES ('Salutations', 258, 1, 17, 'E. Schrody/L. Dimant', 69120, 2767047, 0.99);
      INSERT INTO Track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES ('Put Your Head Out', 258, 1, 17, 'E. Schrody/L. Freese/L. Muggerud', 182230, 7291473, 0.99);
      INSERT INTO Track (Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES ('Top O'' The Morning To Ya', 258, 1, 17, 'E. Schrody/L. Dimant', 216633, 8667599, 0.99);
      INSERT INTO Invoice (CustomerId, InvoiceDate, BillingAddress, BillingCity, BillingState, BillingCountry, BillingPostalCode, Total) VALUES (48, '2013/8/2', 'Lijnbaansgracht 120bg', 'Amsterdam', 'VV', 'Netherlands', '1016', 1.98);
      """

    return Array(repeating: block, count: 2).joined(separator: "\n")
  }
}
