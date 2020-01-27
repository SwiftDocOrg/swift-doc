import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct TypePage: Page {
    let module: SwiftDoc.Module
    let symbol: SwiftDoc.Symbol

    init(module: SwiftDoc.Module, symbol: SwiftDoc.Symbol) {
        precondition(symbol.declaration is Type)
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Page

    var body: Document {
        Document {
            Symbol(symbol, in: module)

            Inheritance(of: symbol, in: module)

            if symbol.declaration is Protocol {
                ConformingTypes(to: symbol, in: module)
            } else if symbol.declaration is Type {
                NestedTypes(of: symbol, in: module)
            }

            Members(of: symbol, in: module)
            GenericallyConstrainedMembers(of: symbol, in: module)
        }
    }
}
