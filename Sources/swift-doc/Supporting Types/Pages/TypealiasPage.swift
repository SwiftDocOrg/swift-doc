import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct TypealiasPage: Page {
    let module: Module
    let symbol: Symbol

    init(module: Module, symbol: Symbol) {
        precondition(symbol.declaration is Typealias)
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Page

    var body: Document {
        Document {
            Heading { symbol.id.description }
            Documentation(for: symbol)
        }
    }
}
