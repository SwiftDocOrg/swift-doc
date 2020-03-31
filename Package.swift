// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-doc",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .revision("swift-5.2-DEVELOPMENT-SNAPSHOT-2020-03-09-a")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .branch("swift-5.2")),
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", .branch("master")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", .upToNextMinor(from: "0.0.5")),
        .package(url: "https://github.com/SwiftDocOrg/GraphViz.git", .revision("03405c13dc1c31f50c08bbec6e7587cbee1c7fb3")),
        .package(url: "https://github.com/NSHipster/HypertextLiteral.git", .upToNextMinor(from: "0.0.2")),
        .package(url: "https://github.com/SwiftDocOrg/Markup.git", .revision("bcc9bff98749f8ed92221375591a1afd61b02f1a")),
        .package(url: "https://github.com/NSHipster/SwiftSyntaxHighlighter.git", .revision("fe39b4ec07e1e37872adf4b506d223ab27cf8cea")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.0.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift-doc",
            dependencies: ["ArgumentParser", "SwiftDoc", "SwiftSemantics", "SwiftMarkup", "CommonMarkBuilder", "HypertextLiteral", "Markup", "DCOV", "GraphViz", "SwiftSyntaxHighlighter"]
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
