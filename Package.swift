// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-doc",
    dependencies: [
        .package(url: "https://github.com/SwiftDocOrg/CommonMark.git", .branch("master")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftMarkup.git", .upToNextMinor(from: "0.0.4")),
        .package(url: "https://github.com/SwiftDocOrg/SwiftSemantics.git", .branch("swift-5.2")),
        .package(url: "https://github.com/apple/swift-syntax.git", .revision("swift-5.2-DEVELOPMENT-SNAPSHOT-2020-03-09-a")),
        .package(url: "https://github.com/kylef/Commander.git", .upToNextMinor(from: "0.9.1")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.2")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "swift-doc",
            dependencies: ["ArgumentParser", "SwiftDoc", "SwiftSemantics", "SwiftMarkup", "CommonMarkBuilder", "DCOV"]
        ),
        .target(
            name: "DCOV",
            dependencies: []
        ),
        .target(
            name: "swift-api-inventory",
            dependencies: ["SwiftDoc", "SwiftSemantics", "Commander"]
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
