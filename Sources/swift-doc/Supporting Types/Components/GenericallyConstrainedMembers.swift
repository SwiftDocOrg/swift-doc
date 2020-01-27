import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct GenericallyConstrainedMembers: Component {
    var symbol: SwiftDoc.Symbol
    var module: SwiftDoc.Module

    init(of symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        let extensions = module.extendedSymbols.keys.filter { $0.extendedType == symbol.declaration.qualifiedName }
        var genericallyConstrainedMembers: [SwiftDoc.Symbol] = []
        for `extension` in extensions where !`extension`.genericRequirements.isEmpty {
            genericallyConstrainedMembers.append(contentsOf: module.extendedSymbols[`extension`] ?? [])
        }

        guard !genericallyConstrainedMembers.isEmpty else { return Fragment { "" } }

        return Fragment {
            Section {
                Heading { "Generically Constrained Members" }

                ForEach(in: extensions.filter { !$0.genericRequirements.isEmpty }) { `extension` in
                    Section {
                        Heading { "where \(`extension`.genericRequirements.map { $0.description }.joined(separator: ", "))"}

                        Section {
                            ForEach(in: module.extendedSymbols[`extension`] ?? []) { member in
                                Symbol(member, in: module)
                            }
                        }
                    }
                }
            }
        }
    }
}
