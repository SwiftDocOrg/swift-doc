import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct TypePage: Page {
    let module: Module
    let symbol: Symbol
    let baseURL: String

    init(module: Module, symbol: Symbol, baseURL: String) {
        precondition(symbol.api is Type)
        self.module = module
        self.symbol = symbol
        self.baseURL = baseURL
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }

    var document: CommonMark.Document {
        return CommonMark.Document {
            Heading { symbol.id.description }

            Documentation(for: symbol, in: module, baseURL: baseURL)
            Relationships(of: symbol, in: module, baseURL: baseURL)
            Members(of: symbol, in: module, baseURL: baseURL)
            Requirements(of: symbol, in: module, baseURL: baseURL)
        }
    }

    var html: HypertextLiteral.HTML {
        let typeName = String(describing: type(of: symbol.api))

        return #"""
        <a name="//apple_ref/cpp/\#(typeName)/\#(symbol.id.description)" class="dashAnchor"></a>
        <h1>
            <small>\#(typeName)</small>
            <code class="name">\#(softbreak(symbol.id.description))</code>
        </h1>

        \#(Documentation(for: symbol, in: module, baseURL: baseURL).html)
        \#(Relationships(of: symbol, in: module, baseURL: baseURL).html)
        \#(Members(of: symbol, in: module, baseURL: baseURL).html)
        \#(Requirements(of: symbol, in: module, baseURL: baseURL).html)
        """#
    }
}
