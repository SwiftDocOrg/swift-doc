import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct TypealiasPage: Page {
    let module: Module
    let symbol: Symbol
    let baseURL: String

    init(module: Module, symbol: Symbol, baseURL: String) {
        precondition(symbol.api is Typealias)
        self.module = module
        self.symbol = symbol
        self.baseURL = baseURL
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }

    var document: CommonMark.Document {
        Document {
            Heading { symbol.id.description }
            Documentation(for: symbol, in: module, baseURL: baseURL)
        }
    }

    var html: HypertextLiteral.HTML {
        #"""
        <h1>
            <small>\#(String(describing: type(of: symbol.api)))</small>
            <span class="name">\#(softbreak(symbol.id.description))</span>
        </h1>

        \#(Documentation(for: symbol, in: module, baseURL: baseURL).html)
        """#
    }
}
