import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import Foundation

extension StringBuilder {
    // MARK: buildIf

    public static func buildIf(_ string: String?) -> String {
        return string ?? ""
    }

    // MARK: buildEither

    public static func buildEither(first: String) -> String {
        return first
    }

    public static func buildEither(second: String) -> String {
        return second
    }
}

struct Inheritance: Component {
    var module: Module
    var symbol: Symbol

    init(of symbol: Symbol, in module: Module) {
        self.module = module
        self.symbol = symbol
    }

    // MARK: - Component

    var body: Fragment {
        let inheritedTypes = module.interface.typesInherited(by: symbol) + module.interface.typesConformed(by: symbol)
        guard !inheritedTypes.isEmpty else { return Fragment { "" } }

        return Fragment {
            Section {
                Heading { "Inheritance" }

                Fragment {
                    #"""
                    \#(inheritedTypes.map { type in
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
