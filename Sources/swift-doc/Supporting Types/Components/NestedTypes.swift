import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct NestedTypes: Component {
    var symbol: Symbol
    var module: Module

    init(of symbol: Symbol, in module: Module) {
        precondition(symbol.declaration is Type)
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        let nestedTypes = module.interface.members(of: symbol).filter { $0.declaration is Type }
        guard !nestedTypes.isEmpty else { return Fragment { "" }}

        return Fragment {
            Section {
                Heading { "Nested Types" }

                Fragment {
                    #"""
                    \#(nestedTypes.map { type in
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
