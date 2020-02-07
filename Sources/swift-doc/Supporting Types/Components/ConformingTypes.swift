import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct ConformingTypes: Component {
    var symbol: Symbol
    var module: Module

    init(to symbol: Symbol, in module: Module) {
        precondition(symbol.declaration is Protocol)
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        guard symbol.declaration is Protocol else { return Fragment { "" } }
        let conformingTypes = module.typesConforming(to: symbol)
        guard !conformingTypes.isEmpty else { return Fragment { "" }}

        return Fragment {
            Section {
                Heading { "Conforming Types" }

                Fragment {
                    #"""
                    \#(conformingTypes.map { type in
                        if type.declaration is Unknown {
                            return "`\(type.id)`"
                        } else {
                            return "[`\(type.id)`](\(path(for: type.id)))"
                        }
                    }.joined(separator: ", "))
                    """#
                }
            }
        }
    }
}
