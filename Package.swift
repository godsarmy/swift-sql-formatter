// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SQLFormatter",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SQLFormatter",
      targets: ["SQLFormatter"]
    ),
    .library(
      name: "SQLFormatterCLICommon",
      targets: ["SQLFormatterCLICommon"]
    ),
    .executable(
      name: "sqlfmt",
      targets: ["sqlfmt"]
    ),
    .executable(
      name: "sqlfmt-bench",
      targets: ["sqlfmt-bench"]
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "SQLFormatter"
    ),
    .target(
      name: "SQLFormatterCLICommon",
      dependencies: ["SQLFormatter"]
    ),
    .executableTarget(
      name: "sqlfmt",
      dependencies: ["SQLFormatterCLICommon"]
    ),
    .executableTarget(
      name: "sqlfmt-bench",
      dependencies: ["SQLFormatter"]
    ),
    .testTarget(
      name: "SQLFormatterTests",
      dependencies: ["SQLFormatter", "SQLFormatterCLICommon"]
    ),
  ]
)
