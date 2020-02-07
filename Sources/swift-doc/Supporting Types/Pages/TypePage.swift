import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct TypePage: Page {
    let module: Module
    let symbol: Symbol

    init(module: Module, symbol: Symbol) {
        precondition(symbol.declaration is Type)
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Page

    var body: Document {
        return Document {
            Heading { symbol.id.description }

            Documentation(for: symbol)

            Inheritance(of: symbol, in: module)

            if symbol.declaration is Protocol {
                ConformingTypes(to: symbol, in: module)
            } else if symbol.declaration is Type {
                NestedTypes(of: symbol, in: module)
            }

            Members(of: symbol, in: module)
            Requirements(of: symbol, in: module)
        }
    }
}
