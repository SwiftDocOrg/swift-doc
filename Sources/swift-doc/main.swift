import ArgumentParser
import Foundation
import Logging
import LoggingGitHubActions

LoggingSystem.bootstrap { label in
    if ProcessInfo.processInfo.environment["GITHUB_ACTIONS"] == "true" {
        return GitHubActionsLogHandler.standardOutput(label: label)
    } else {
        return StreamLogHandler.standardOutput(label: label)
    }
}

let logger = Logger(label: "org.swiftdoc.swift-doc")

let fileManager = FileManager.default

var standardOutput = FileHandle.standardOutput
var standardError = FileHandle.standardError

struct SwiftDoc: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "swift doc",
        abstract: "A utility for generating documentation for Swift code.",
        version: "1.0.0-rc.1",
        subcommands: [Generate.self, Coverage.self, Diagram.self]
    )
}

SwiftDoc.main()
