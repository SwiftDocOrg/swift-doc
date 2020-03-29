// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-doc",
    products: [
        .library(name: "SwiftDoc", targets: ["SwiftDoc"]),
        .executable(name: "swift-doc", targets: ["swift-doc"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", .revision("0.50200.0")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .branch("swift-5.2")),
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", .branch("master")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", .upToNextMinor(from: "0.0.4")),
        .package(url: "https://github.com/SwiftDocOrg/GraphViz.git", .upToNextMinor(from: "0.1.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift-doc",
            dependencies: ["ArgumentParser", "SwiftDoc", "SwiftSemantics", "SwiftMarkup", "CommonMarkBuilder", "DCOV", "GraphViz"]
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
