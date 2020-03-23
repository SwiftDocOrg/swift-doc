import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct TypePage: Page {
    let module: Module
    let symbol: Symbol

    init(module: Module, symbol: Symbol) {
        precondition(symbol.api is Type)
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Page

    var title: String {
        return symbol.id.description
    }

    var document: CommonMark.Document {
        return Document {
            Heading { symbol.id.description }

            Documentation(for: symbol, in: module)

            Inheritance(of: symbol, in: module)

            if symbol.api is Protocol {
                ConformingTypes(to: symbol, in: module)
            } else if symbol.api is Type {
                NestedTypes(of: symbol, in: module)
            }

            Members(of: symbol, in: module)
            Requirements(of: symbol, in: module)
        }
    }

    var html: HypertextLiteral.HTML {
//        print(symbol.api, module.interface.relationshipsBySubject[symbol.id])
//        print("")
        return #"""
        <h1>
            <small>\#(String(describing: type(of: symbol.api)))</small>
            <code class="name">\#(softbreak(symbol.id.description))</code>
        </h1>

        \#(Documentation(for: symbol, in: module).html)
        \#(Inheritance(of: symbol, in: module).html)
        \#(Members(of: symbol, in: module).html)
        \#(Requirements(of: symbol, in: module).html)
        """#
    }
}
