import Commander
import Foundation
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftMarkup
import SwiftDoc

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let fileManager = FileManager.default
let fileAttributes: [FileAttributeKey : Any] = [.posixPermissions: 0o744]

var standardOutput = FileHandle.standardOutput
var standardError = FileHandle.standardError

command(
    Option<String>("output", default: ".build/documentation", description: "The path for generated output"),
    Argument<[String]>("inputs", description: "One or more paths to Swift files", validator: { (inputs) -> [String] in
        inputs.filter { path in
            var isDirectory: ObjCBool = false
            return fileManager.fileExists(atPath: path, isDirectory: &isDirectory) || isDirectory.boolValue
        }
    }), { output, inputs in
        do {
            let module = try Module(paths: inputs)
            
            let outputDirectoryURL = URL(fileURLWithPath: output)
            try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)

            do {
                try HomePage(module: module).write(to: outputDirectoryURL.appendingPathComponent("Home.md"))
                try SidebarPage(module: module).write(to: outputDirectoryURL.appendingPathComponent("_Sidebar.md"))
                try FooterPage().write(to: outputDirectoryURL.appendingPathComponent("_Footer.md"))

                var globals: [String: [Symbol]] = [:]
                for symbol in module.topLevelSymbols.filter({ $0.isPublic }) {
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
        } catch {
            print("Error: \(error)", to: &standardError)
            exit(EXIT_FAILURE)
        }
}).run()
