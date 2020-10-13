import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct TypePage: Page {
    let module: Module
    let symbol: Symbol

    init(for symbol: Symbol, in module: Module) {
        precondition(symbol.api is Type)
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }
}

extension TypePage: CommonMarkRenderable {
    func render(with generator: CommonMarkGenerator) throws -> Document {
        return CommonMark.Document {
            Heading { symbol.id.description }

            Documentation(for: symbol, in: module)
//            Relationships(of: symbol, in: module
//            Members(of: symbol, in: module)
//            Requirements(of: symbol, in: module)
        }
    }
}

extension TypePage: HTMLRenderable {
    func render(with generator: HTMLGenerator) throws -> HTML {
        let typeName = String(describing: type(of: symbol.api))

        return #"""
        <a name="//apple_ref/cpp/\#(typeName)/\#(symbol.id.description)" class="dashAnchor"></a>
        <h1>
            <small>\#(typeName)</small>
            <code class="name">\#(softbreak(symbol.id.description))</code>
        </h1>

        """#
//
//        \#(Documentation(for: symbol, in: module).html)
//        \#(Relationships(of: symbol, in: module).html)
//        \#(Members(of: symbol, in: module).html)
//        \#(Requirements(of: symbol, in: module).html)
//        """#
    }
}
