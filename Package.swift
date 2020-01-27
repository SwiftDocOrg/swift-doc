// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-doc",
    dependencies: [
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", .branch("master")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", .upToNextMinor(from: "0.0.4")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.9.1")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift-doc",
            dependencies: ["SwiftDoc", "SwiftSemantics", "SwiftMarkup", "CommonMarkBuilder", "Commander"]
        ),
        .target(
            name: "swift-dcov",
            dependencies: ["SwiftSyntax", "SwiftSemantics", "SwiftMarkup", "SwiftDoc", "Commander"]
        ),
        .target(
            name: "swift-api-inventory",
            dependencies: ["SwiftDoc", "SwiftSemantics", "Commander"]
        ),
        .target(
            name: "SwiftDoc",
            dependencies: ["SwiftSyntax", "SwiftSemantics", "SwiftMarkup"]
        ),
    ]
)
