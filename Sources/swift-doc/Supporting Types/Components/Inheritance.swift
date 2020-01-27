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
    var inheritance: [String]
    var conditionallyConstrainedExtensions: [Extension] = []

    init(of symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        self.module = module
        self.inheritance = module.inheritance(of: symbol) ?? []
        self.conditionallyConstrainedExtensions = module.extendedSymbols.keys.filter { $0.extendedType == symbol.declaration.qualifiedName }.filter { !$0.genericRequirements.isEmpty && !$0.inheritance.isEmpty }
    }

    init(of extension: Extension, in module: SwiftDoc.Module) {
        self.module = module
        self.inheritance = `extension`.inheritance
        self.conditionallyConstrainedExtensions = []
    }

    // MARK: - Component

    var body: Fragment {
        guard !inheritance.isEmpty else { return Fragment { "" } }

        return Fragment {
            Section {
                if !inheritance.isEmpty {
                    Heading { "Inheritance" }

                    Fragment {
                        #"""
                        \#(inheritance.map {
                            if module.hasDeclaration(named: $0) {
                                return "[`\($0)`](\(path(for: $0)))"
                            } else {
                                return "`\($0)`"
                            }
                        }.joined(separator: ", "))
                        """#
                    }
                }

                if !conditionallyConstrainedExtensions.isEmpty {
                    Section {
                        Heading { "Generically Constrained Inheritance" }

                        ForEach(in: conditionallyConstrainedExtensions) { `extension` in
                            Section {
                                Heading { "where \(`extension`.genericRequirements.map { $0.description }.joined(separator: ", "))" }

                                Inheritance(of: `extension`, in: module)
                            }
                        }
                    }
                }
            }
        }
    }
}
