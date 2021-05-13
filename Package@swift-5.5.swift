// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-doc",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "swift-doc", targets: ["swift-doc"]),
        .library(name: "SwiftDoc", targets: ["SwiftDoc"])
    ],
    dependencies: [
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .revision("release/5.5")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .revision("0.3.2")),
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/SwiftDocOrg/GraphViz.git", .upToNextMinor(from: "0.4.1")),
        .package(url: "https://github.com/NSHipster/HypertextLiteral.git", .upToNextMinor(from: "0.0.2")),
        .package(url: "https://github.com/SwiftDocOrg/Markup.git", .upToNextMinor(from: "0.1.2")),
        .package(url: "https://github.com/NSHipster/SwiftSyntaxHighlighter.git", .revision("1.2.4")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.2")),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMinor(from: "1.4.2")),
        .package(name: "LoggingGitHubActions", url: "https://github.com/NSHipster/swift-log-github-actions.git", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift-doc",
            dependencies: [
                .target(name: "SwiftDoc"),
                .target(name: "DCOV"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSemantics", package: "SwiftSemantics"),
                .product(name: "SwiftMarkup", package: "SwiftMarkup"),
                .product(name: "CommonMarkBuilder", package: "CommonMark"),
                .product(name: "HypertextLiteral", package: "HypertextLiteral"),
                .product(name: "Markup", package: "Markup"),
                .product(name: "GraphViz", package: "GraphViz"),
                .product(name: "SwiftSyntaxHighlighter", package: "SwiftSyntaxHighlighter"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "LoggingGitHubActions", package: "LoggingGitHubActions")
            ]
        ),
        .target(
            name: "DCOV",
            dependencies: []
        ),
        .target(
            name: "SwiftDoc",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                .product(name: "SwiftSemantics", package: "SwiftSemantics"),
                .product(name: "SwiftMarkup", package: "SwiftMarkup"),
                .product(name: "SwiftSyntaxHighlighter", package: "SwiftSyntaxHighlighter")
            ]
        ),
        .testTarget(
            name: "SwiftDocTests",
            dependencies: [
                .target(name: "SwiftDoc"),
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                .product(name: "SwiftSemantics", package: "SwiftSemantics"),
                .product(name: "SwiftMarkup", package: "SwiftMarkup")
            ]
        ),
        .testTarget(
            name: "EndToEndTests",
            dependencies: [
                .target(name: "swift-doc"),
            ]
        ),
    ]
)
