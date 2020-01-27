import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct TypealiasPage: Page {
    let module: SwiftDoc.Module
    let symbol: SwiftDoc.Symbol

    init(module: SwiftDoc.Module, symbol: SwiftDoc.Symbol) {
        precondition(symbol.declaration is Typealias)
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Page

    var body: Document {
        Document {
            Symbol(symbol, in: module)
        }
    }
}
