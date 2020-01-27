import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct GlobalPage: Page {
    let module: SwiftDoc.Module
    let name: String
    let symbols: [SwiftDoc.Symbol]

    init(module: SwiftDoc.Module, name: String, symbols: [SwiftDoc.Symbol]) {
        self.module = module
        self.name = name
        self.symbols = symbols
    }

    // MARK: - Page

    var body: Document {
        return Document {
            Heading { name }

            Section {
                ForEach(in: symbols) { symbol in
                    Symbol(symbol, in: module)
                }
            }
        }
    }
}
