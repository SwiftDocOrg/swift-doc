import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct ConformingTypes: Component {
    var symbol: SwiftDoc.Symbol
    var module: SwiftDoc.Module

    init(to symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        precondition(symbol.declaration is Protocol)
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        guard let `protocol` = symbol.declaration as? Protocol else { return Fragment { "" } }
        let names = module.namesOfTypesConforming(to: `protocol`)
        guard !names.isEmpty else { return Fragment { "" }}

        return Fragment {
            Section {
                Heading { "Conforming Types" }

                Fragment {
                    #"""
                    \#(names.map { name in
                        if module.hasDeclaration(named: name) {
                            return "[`\(name)`](\(path(for: name)))"
                        } else {
                            return "`\(name)`"
                        }
                    }.joined(separator: ", "))
                    """#
                }
            }
        }
    }
}
