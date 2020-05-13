import Foundation
import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol

enum CommonMarkGenerator: Generator {
    static func generate(for module: Module, with options: SwiftDoc.Generate.Options) throws {
        assert(options.format == .commonmark)

        let module = try Module(name: options.moduleName, paths: options.inputs)

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

        if pages.count == 1, let page = pages.first?.value {
            let filename = "Home.md"
            let url = outputDirectoryURL.appendingPathComponent(filename)
            try page.write(to: url, baseURL: options.baseURL)
        } else {
            pages["Home"] = HomePage(module: module, baseURL: options.baseURL)
            pages["_Sidebar"] = SidebarPage(module: module, baseURL: options.baseURL)
            pages["_Footer"] = FooterPage(baseURL: options.baseURL)

            try pages.map { $0 }.parallelForEach {
                let filename = "\($0.key).md"
                let url = outputDirectoryURL.appendingPathComponent(filename)
                try $0.value.write(to: url, baseURL: options.baseURL)
            }
        }
    }
}

// MARK: -

fileprivate extension Page {
    func write(to url: URL, baseURL: String) throws {
        guard let data = document.render(format: .commonmark).data(using: .utf8) else { return }
        try writeFile(data, to: url)
    }
}
