import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct GlobalPage: Page {
    let module: Module
    let name: String
    let symbols: [Symbol]

    init(for symbols: [Symbol], named name: String, in module: Module) {
        self.name = name
        self.symbols = symbols
        self.module = module
    }

    // MARK: - Page

    var title: String {
        return name
    }
}

extension GlobalPage: CommonMarkRenderable {
    func render(with generator: CommonMarkGenerator) throws -> Document {
        Document {
            ForEach(in: symbols) { symbol in
                Heading { symbol.id.description }
//                Documentation(for: symbol, in: module)
            }
        }
    }
}

extension GlobalPage: HTMLRenderable {
    func render(with generator: HTMLGenerator) throws -> HTML {
        return ""
//        let description: String
//
//        let descriptions = Set(symbols.map { String(describing: type(of: $0.api)) })
//        if descriptions.count == 1 {
//            description = descriptions.first!
//        } else {
//            description = "Global"
//        }
//
//        return #"""
//        <h1>
//        <small>\#(description)</small>
//        <span class="name">\#(softbreak(name))</span>
//        </h1>
//
//        \#(symbols.map { symbol in
//        Documentation(for: symbol, in: module).html
//        })
//        """#
    }
}
