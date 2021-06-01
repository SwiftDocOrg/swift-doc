import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct TypePage: Page {
    let module: Module
    let symbol: Symbol
    let baseURL: String
    let symbolFilter: (Symbol) -> Bool

    init(module: Module, symbol: Symbol, baseURL: String, includingChildren symbolFilter: @escaping (Symbol) -> Bool) {
        precondition(symbol.api is Type)
        self.module = module
        self.symbol = symbol
        self.baseURL = baseURL
        self.symbolFilter = symbolFilter
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }

    var document: CommonMark.Document {
        return CommonMark.Document {
            Heading { symbol.id.description }

            Documentation(for: symbol, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter)
            Relationships(of: symbol, in: module, baseURL: baseURL, includingChildren: symbolFilter)
            Members(of: symbol, in: module, baseURL: baseURL, symbolFilter: symbolFilter)
            Requirements(of: symbol, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter)
        }
    }

    var html: HypertextLiteral.HTML {
        return #"""
        <h1>
            <small>\#(String(describing: type(of: symbol.api)))</small>
            <code class="name">\#(softbreak(symbol.id.description))</code>
        </h1>

        \#(Documentation(for: symbol, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter).html)
        \#(Relationships(of: symbol, in: module, baseURL: baseURL, includingChildren: symbolFilter).html)
        \#(Members(of: symbol, in: module, baseURL: baseURL, symbolFilter: symbolFilter).html)
        \#(Requirements(of: symbol, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter).html)
        """#
    }
}
