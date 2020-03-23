import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct NestedTypes: Component {
    var symbol: Symbol
    var module: Module

    var nestedTypes: [Symbol]

    init(of symbol: Symbol, in module: Module) {
        precondition(symbol.api is Type)
        self.symbol = symbol
        self.module = module
        self.nestedTypes = module.interface.members(of: symbol).filter { $0.api is Type }
    }

    // MARK: - Component

    var fragment: Fragment {
        guard !nestedTypes.isEmpty else { return Fragment { "" }}

        return Fragment {
            Section {
                Heading { "Nested Types" }

                Fragment {
                    #"""
                    \#(nestedTypes.map { type in
                        if type.api is Unknown {
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

    var html: HypertextLiteral.HTML {
        return #"""

        """#
    }
}
