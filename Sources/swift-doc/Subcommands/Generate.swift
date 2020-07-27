import ArgumentParser
import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SQLite

#if os(Linux)
import FoundationNetworking
#endif

extension SwiftDoc {
    struct Generate: ParsableCommand {
        enum Format: String, ExpressibleByArgument {
            case commonmark
            case html
            case docset
        }

        struct Options: ParsableArguments {
            @Argument(help: "One or more paths to Swift files")
            var inputs: [String]

            @Option(name: [.long, .customShort("n")],
                    help: "The name of the module")
            var moduleName: String

            @Option(name: .shortAndLong,
                    default: ".build/documentation",
                    help: "The path for generated output")
            var output: String

            @Option(name: .shortAndLong,
                    default: .commonmark,
                    help: "The output format")
            var format: Format

            @Option(name: .customLong("base-url"),
                    default: "/",
                    help: "The base URL used for all relative URLs in generated documents.")
            var baseURL: String
        }

        static var configuration = CommandConfiguration(abstract: "Generates Swift documentation")

        @OptionGroup()
        var options: Options

        func run() throws {
            do {
                let module = try Module(name: options.moduleName, paths: options.inputs)

                switch options.format {
                case .commonmark:
                    try CommonMarkGenerator.generate(for: module, with: options)
                case .html:
                    try HTMLGenerator.generate(for: module, with: options)
                case .docset:
                    try DocSetGenerator.generate(for: module, with: options)
                }
            } catch {
                logger.error("\(error)")
            }
        }
    }
}
