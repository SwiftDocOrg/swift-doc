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

extension SwiftDocCommand {
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
                    default: URL(fileURLWithPath: "/"), parsing: .next, help: "The base URL used for all relative URLs in generated documents.", transform: { string in
                return URL(fileURLWithPath: string)
            })
            var baseURL: URL

            @Flag(default: false, inversion: .prefixedNo)
            var inlineCSS: Bool
        }

        static var configuration = CommandConfiguration(abstract: "Generates Swift documentation")

        @OptionGroup()
        var options: Options

        func run() throws {
            do {
                let module = try Module(name: options.moduleName, paths: options.inputs)

                switch options.format {
                case .commonmark:
                    try CommonMarkGenerator(with: options).generate(for: module)
                case .html:
                    try HTMLGenerator(with: options).generate(for: module)
                case .docset:
                    try DocSetGenerator(with: options).generate(for: module)
                }
            } catch {
                logger.error("\(error)")
            }
        }
    }
}
