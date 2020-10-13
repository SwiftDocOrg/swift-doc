import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct TypealiasPage: Page {
    let module: Module
    let symbol: Symbol

    init(for symbol: Symbol, in module: Module) {
        precondition(symbol.api is Typealias)
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }
}

extension TypealiasPage: CommonMarkRenderable {
    func render(with generator: CommonMarkGenerator) throws -> Document {
        Document {
            Heading { symbol.id.description }
//            Documentation(for: symbol, in: module)
        }
    }
}

extension TypealiasPage: HTMLRenderable {
    func render(with generator: HTMLGenerator) throws -> HTML {
        #"""
        <h1>
            <small>\#(String(describing: type(of: symbol.api)))</small>
            <span class="name">\#(softbreak(symbol.id.description))</span>
        </h1>
        """#

//        \#(Documentation(for: symbol, in: module).html)
//        """#
    }
}
