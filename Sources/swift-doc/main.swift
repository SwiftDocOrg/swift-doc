import ArgumentParser
import Foundation

let fileManager = FileManager.default
let fileAttributes: [FileAttributeKey : Any] = [.posixPermissions: 0o744]

var standardOutput = FileHandle.standardOutput
var standardError = FileHandle.standardError

struct SwiftDoc: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A utility for generating documentation for Swift code.",
        subcommands: [Generate.self],
        defaultSubcommand: Generate.self
    )
}

SwiftDoc.main()
