import ArgumentParser
import Foundation
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftMarkup
import SwiftDoc

extension SwiftDoc {
    struct Generate: ParsableCommand {
        struct Options: ParsableArguments {
            @Argument(help: "One or more paths to Swift files")
            var inputs: [String]

            @Option(name: .shortAndLong,
                    default: ".build/documentation",
                    help: "The path for generated output")
            var output: String
        }

        static var configuration = CommandConfiguration(abstract: "Generates Swift documentation")

        @OptionGroup()
        var options: Options

        func run() throws {
            let module = try Module(paths: options.inputs)

            let outputDirectoryURL = URL(fileURLWithPath: options.output)
            try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)

            do {
                try HomePage(module: module).write(to: outputDirectoryURL.appendingPathComponent("Home.md"))
                try SidebarPage(module: module).write(to: outputDirectoryURL.appendingPathComponent("_Sidebar.md"))
                try FooterPage().write(to: outputDirectoryURL.appendingPathComponent("_Footer.md"))

                var globals: [String: [Symbol]] = [:]
                for symbol in module.interface.topLevelSymbols.filter({ $0.isPublic }) {
                    switch symbol.declaration {
                    case is Class:
                        try TypePage(module: module, symbol: symbol).write(to: outputDirectoryURL.appendingPathComponent("\(path(for: symbol.id.description)).md"))
                    case is Enumeration:
                        try TypePage(module: module, symbol: symbol).write(to: outputDirectoryURL.appendingPathComponent("\(path(for: symbol.id.description)).md"))
                    case is Structure:
                        try TypePage(module: module, symbol: symbol).write(to: outputDirectoryURL.appendingPathComponent("\(path(for: symbol.id.description)).md"))
                    case let `protocol` as Protocol:
                        try TypePage(module: module, symbol: symbol).write(to: outputDirectoryURL.appendingPathComponent("\(path(for: `protocol`.name)).md"))
                    case let `typealias` as Typealias:
                        try TypealiasPage(module: module, symbol: symbol).write(to: outputDirectoryURL.appendingPathComponent("\(path(for: `typealias`.name)).md"))
                    case let function as Function where !function.isOperator:
                        globals[function.name, default: []] += [symbol]
                    case let variable as Variable:
                        globals[variable.name, default: []] += [symbol]
                    default:
                        continue
                    }
                }

                for (name, symbols) in globals {
                    try GlobalPage(module: module, name: name, symbols: symbols).write(to: outputDirectoryURL.appendingPathComponent("\(path(for: name)).md"))
                }
            }
        }
    }
}
