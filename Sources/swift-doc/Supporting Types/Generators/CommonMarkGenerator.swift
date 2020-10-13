import Foundation
import CommonMark
import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol

final class CommonMarkGenerator: Generator {
    var router: Router
    var options: SwiftDocCommand.Generate.Options

    init(with options: SwiftDocCommand.Generate.Options) {
        self.options = options
        self.router = { routable in
            switch routable {
            case let symbol as Symbol:
                var urlComponents = URLComponents()
                if symbol.id.pathComponents.isEmpty {
                    urlComponents.appendPathComponent(symbol.id.escaped)
                } else {
                    symbol.id.pathComponents.forEach { urlComponents.appendPathComponent($0) }
                    urlComponents.fragment = symbol.id.escaped.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                }
                return urlComponents.path
            default:
                return "\(routable)"
            }
        }
    }

    func generate(for module: Module) throws {
        assert(options.format == .commonmark)

        let module = try Module(name: options.moduleName, paths: options.inputs)

        let outputDirectoryURL = URL(fileURLWithPath: options.output)
        try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)

        var pages: [String: Page & CommonMarkRenderable] = [:]

        var globals: [String: [Symbol]] = [:]
        for symbol in module.interface.topLevelSymbols.filter({ $0.isPublic }) {
            switch symbol.api {
            case is Class, is Enumeration, is Structure, is Protocol:
                pages[router(symbol)] = TypePage(for: symbol, in: module)
            case is Typealias:
                pages[router(symbol)] = TypealiasPage(for: symbol, in: module)
            case let function as Function where !function.isOperator:
                globals[function.name, default: []] += [symbol]
            case let variable as Variable:
                globals[variable.name, default: []] += [symbol]
            default:
                continue
            }
        }

        for (name, symbols) in globals {
            pages[router(symbols.first!)] = GlobalPage(for: symbols, named: name, in: module)
        }

        guard !pages.isEmpty else {
            logger.warning("No public API symbols were found at the specified path. No output was written.")
            return
        }

        if pages.count == 1, let page = pages.first?.value {
            pages = ["Home": page]
        } else {
            pages["Home"] = HomePage(module: module)
            pages["_Sidebar"] = SidebarPage(module: module)
            pages["_Footer"] = FooterPage()
        }

        try pages.map { $0 }.parallelForEach {
            try write(page: $0.value, to: $0.key)
        }
    }

    private func write(page: Page & CommonMarkRenderable, to route: String) throws {
        guard let data = try page.render(with: self).render(format: .commonmark).data(using: .utf8) else { fatalError("Unable to render page \(page)") }
        let filename = "\(route).md"
        let url = URL(fileURLWithPath: options.output).appendingPathComponent(filename)
        try data.write(to: url)
    }
}

// MARK: -

protocol CommonMarkRenderable {
    func render(with generator: CommonMarkGenerator) throws -> Document
}
