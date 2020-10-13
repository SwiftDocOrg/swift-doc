import Foundation
import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import HypertextLiteral

final class HTMLGenerator: Generator {
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

    func pages(for module: Module) throws -> [String: Page] {
        var pages: [String: Page] = [:]

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

        return pages
    }

    func generate(for module: Module) throws {
        assert(options.format == .html)

        let outputDirectoryURL = URL(fileURLWithPath: options.output)
        try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)

        var pages = try self.pages(for: module)

        guard !pages.isEmpty else {
            logger.warning("No public API symbols were found at the specified path. No output was written.")
            return
        }

        if !options.inlineCSS {
            let cssURL = outputDirectoryURL.appendingPathComponent("all.css")
            try writeFile(css, to: cssURL)
        }

        if pages.count == 1, let page = pages.first?.value {
            pages = ["Home": page]
        } else {
            pages["Home"] = HomePage(module: module)
            pages["_Sidebar"] = SidebarPage(module: module)
            pages["_Footer"] = FooterPage()
        }

        try pages.map { $0 }.parallelForEach {
//            try write(page: $0.value, to: $0.key)
        }

        if pages.count == 1, let page = pages.first?.value {
            let filename = "index.html"
            let url = outputDirectoryURL.appendingPathComponent(filename)
            try page.write(to: url, with: options)
        } else {
            pages["Home"] = HomePage(module: module)

            try pages.map { $0 }.parallelForEach {
                let filename: String
                if $0.key == "Home" {
                    filename = "index.html"
                } else {
                    filename = "\($0.key)/index.html"
                }

                let url = outputDirectoryURL.appendingPathComponent(filename)
                try $0.value.write(to: url, with: options)
            }
        }
    }

    func write(page: Page & HTMLRenderable, to url: URL) throws {
        
    }
}

// MARK: -

fileprivate extension Page {
    func write(to url: URL, with options: SwiftDocCommand.Generate.Options) throws {
//        var html = layout(self, with: options).description
//        if let range = html.range(of: "</head>") {
//            html.insert(contentsOf: """
//            <style>\(String(data: css, encoding: .utf8)!)</style>
//
//            """, at: range.lowerBound)
//        }
//
//        let data = html.data(using: .utf8)
//        guard let filedata = data else { return }
//        try writeFile(filedata, to: url)
    }
}

fileprivate class Stylesheet {
    static var css: Data! = {
        let url = URL(string: "https://raw.githubusercontent.com/SwiftDocOrg/swift-doc/master/Resources/all.min.css")!
        return try! Data(contentsOf: url)
    }()
}

fileprivate var _css: Data?
fileprivate var css: Data {
    if let css = _css {
        return css
    } else {
        let url = URL(string: "https://raw.githubusercontent.com/SwiftDocOrg/swift-doc/master/Resources/all.min.css")!
        _css = try! Data(contentsOf: url)
        return _css!
    }
}

protocol HTMLRenderable {
    func render(with generator: HTMLGenerator) throws -> HypertextLiteral.HTML
}
