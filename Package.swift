// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-doc",
    products: [
        .executable(name: "swift-doc", targets: ["swift-doc"]),
        .library(name: "SwiftDoc", targets: ["SwiftDoc"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .revision("0.50200.0")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", .revision("902cc82abc2e8ad23b73c982eed27c63ae3d9384")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", .revision("0.2.0")),
        .package(url: "https://github.com/SwiftDocOrg/GraphViz.git", .revision("03405c13dc1c31f50c08bbec6e7587cbee1c7fb3")),
        .package(url: "https://github.com/NSHipster/HypertextLiteral.git", .upToNextMinor(from: "0.0.2")),
        .package(url: "https://github.com/SwiftDocOrg/Markup.git", .upToNextMinor(from: "0.0.3")),
        .package(url: "https://github.com/NSHipster/SwiftSyntaxHighlighter.git", .revision("1.0.0")),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", .revision("0.12.2")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.5")),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMinor(from: "1.2.0")),
        .package(url: "https://github.com/NSHipster/swift-log-github-actions.git", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift-doc",
            dependencies: ["ArgumentParser", "SwiftDoc", "SwiftSemantics", "SwiftMarkup", "CommonMarkBuilder", "HypertextLiteral", "Markup", "DCOV", "GraphViz", "SwiftSyntaxHighlighter", "SQLite", "Logging", "LoggingGitHubActions"]
        ),
        .target(
            name: "DCOV",
            dependencies: []
        ),
        .target(
            name: "SwiftDoc",
            dependencies: ["SwiftSyntax", "SwiftSemantics", "SwiftMarkup"]
        ),
        .testTarget(
            name: "SwiftDocTests",
            dependencies: ["SwiftDoc", "SwiftSyntax", "SwiftSemantics", "SwiftMarkup"]
        ),
    ]
)
