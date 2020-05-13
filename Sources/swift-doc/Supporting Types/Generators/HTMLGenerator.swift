import Foundation
import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol

enum HTMLGenerator: Generator {
    static func generate(for module: Module, with options: SwiftDoc.Generate.Options) throws {
        assert(options.format == .html)

        let outputDirectoryURL = URL(fileURLWithPath: options.output)
        try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)

        var pages: [String: Page] = [:]

        var globals: [String: [Symbol]] = [:]
        for symbol in module.interface.topLevelSymbols.filter({ $0.isPublic }) {
            switch symbol.api {
            case is Class, is Enumeration, is Structure, is Protocol:
                pages[route(for: symbol)] = TypePage(module: module, symbol: symbol, baseURL: options.baseURL)
            case let `typealias` as Typealias:
                pages[route(for: `typealias`.name)] = TypealiasPage(module: module, symbol: symbol, baseURL: options.baseURL)
            case let function as Function where !function.isOperator:
                globals[function.name, default: []] += [symbol]
            case let variable as Variable:
                globals[variable.name, default: []] += [symbol]
            default:
                continue
            }
        }

        for (name, symbols) in globals {
            pages[route(for: name)] = GlobalPage(module: module, name: name, symbols: symbols, baseURL: options.baseURL)
        }

        guard !pages.isEmpty else {
            logger.warning("No public API symbols were found at the specified path. No output was written.")
            return
        }

        let cssData = try fetchRemoteCSS()
        let cssURL = outputDirectoryURL.appendingPathComponent("all.css")
        try writeFile(cssData, to: cssURL)

        if pages.count == 1, let page = pages.first?.value {
            let filename = "index.html"
            let url = outputDirectoryURL.appendingPathComponent(filename)
            try page.write(to: url, baseURL: options.baseURL)
        } else {
            pages["Home"] = HomePage(module: module, baseURL: options.baseURL)

            try pages.map { $0 }.parallelForEach {
                let filename: String
                if $0.key == "Home" {
                    filename = "index.html"
                } else {
                    filename = "\($0.key)/index.html"
                }

                let url = outputDirectoryURL.appendingPathComponent(filename)
                try $0.value.write(to: url, baseURL: options.baseURL)
            }
        }
    }
}

// MARK: -

fileprivate extension Page {
    func write(to url: URL, baseURL: String) throws {
        let data = layout(self).description.data(using: .utf8)
        guard let filedata = data else { return }
        try writeFile(filedata, to: url)
    }
}
