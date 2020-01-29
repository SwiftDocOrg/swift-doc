import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct NestedTypes: Component {
    var symbol: SwiftDoc.Symbol
    var module: SwiftDoc.Module

    init(of symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        precondition(symbol.declaration is Type)
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        let types = module.members(of: symbol).filter { $0.declaration is Type }
        guard !types.isEmpty else { return Fragment { "" }}

        return Fragment {
            Section {
                Heading { "Nested Types" }

                List(of: types.map { $0.declaration.qualifiedName }) { (name) -> ListItemConvertible in
                    if module.hasDeclaration(named: name) {
                        return Link(urlString: "\(path(for: name)).md", text: name)
                    } else {
                        return Text(literal: name)
                    }
                }
            }
        }
    }
}
