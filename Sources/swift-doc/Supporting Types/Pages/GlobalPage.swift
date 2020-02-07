import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct GlobalPage: Page {
    let module: Module
    let name: String
    let symbols: [Symbol]

    init(module: Module, name: String, symbols: [Symbol]) {
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
                    Heading { symbol.id.description }
                    Documentation(for: symbol)
                }
            }
        }
    }
}
