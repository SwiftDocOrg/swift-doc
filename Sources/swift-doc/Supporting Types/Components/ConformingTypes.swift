import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct ConformingTypes: Component {
    var symbol: Symbol
    var module: Module

    init(to symbol: Symbol, in module: Module) {
        precondition(symbol.api is Protocol)
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var fragment: Fragment {
        guard symbol.api is Protocol else { return Fragment { "" } }
        let conformingTypes = module.interface.typesConforming(to: symbol)
        guard !conformingTypes.isEmpty else { return Fragment { "" }}

        return Fragment {
            Section {
                Heading { "Conforming Types" }

                Fragment {
                    #"""
                    \#(conformingTypes.map { type in
                        if type.api is Unknown {
                            return "`\(type.id)`"
                        } else {
                            return "[`\(type.id)`](\(path(for: type)))"
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
