import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral
import Foundation

struct OperatorPage: Page {
    let module: Module
    let symbol: Symbol
    let implementations: [Symbol]
    let baseURL: String
    let datesLocale: Locale

    init(module: Module, symbol: Symbol, baseURL: String, datesLocale: Locale, includingImplementations symbolFilter: (Symbol) -> Bool) {
        precondition(symbol.api is Operator)
        self.module = module
        self.symbol = symbol
        self.implementations = module.interface.functionsByOperator[symbol]?.filter(symbolFilter).sorted() ?? []
        self.baseURL = baseURL
        self.datesLocale = datesLocale
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }

    var document: CommonMark.Document {
        return CommonMark.Document {
            Heading { symbol.id.description }

            Documentation(for: symbol, in: module, baseURL: baseURL)
        }
    }

    var html: HypertextLiteral.HTML {
        return #"""
        <h1>
            <small>\#(symbol.kind)</small>
            <code class="name">\#(softbreak(symbol.id.description))</code>
        </h1>

        \#(Documentation(for: symbol, in: module, baseURL: baseURL).html)
        \#(OperatorImplementations(of: symbol, in: module, baseURL: baseURL, implementations: implementations).html)
        """#
    }
}

