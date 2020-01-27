import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct Members: Component {
    var symbol: SwiftDoc.Symbol
    var module: SwiftDoc.Module

    init(of symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        let extensions = module.extendedSymbols.keys.filter { $0.extendedType == symbol.declaration.qualifiedName }

        var members = module.members(of: symbol)
        if !(symbol.declaration is Protocol) {
            members = members.filter({ $0.declaration.isPublic })
        }

        for `extension` in extensions where `extension`.genericRequirements.isEmpty {
            for member in module.extendedSymbols[`extension`] ?? [] {
                if !member.declaration.isPublic, `extension`.isPublic  {
                    members.append(member)
                }
            }
        }

        let typealiases = members.filter { $0.declaration is Typealias }
        let cases = members.filter { $0.declaration is Enumeration.Case }
        let initializers = members.filter { $0.declaration is Initializer }
        let properties = members.filter { $0.declaration is Variable }
        let methods = members.filter { $0.declaration is Function }

        guard !members.isEmpty else { return Fragment { "" } }

        return Fragment {
            if !typealiases.isEmpty {
                Section {
                    Heading { symbol.declaration is Protocol ? "Associated Types" : "Nested Type Aliases" }
                    ForEach(in: typealiases) { `typealias` in
                        Symbol(`typealias`, in: module)
                    }
                }
            }

            if !cases.isEmpty {
                Section {
                    Heading { "Enumeration Cases" }
                    ForEach(in: cases) { `case` in
                        Symbol(`case`, in: module)
                    }
                }
            }

            if !initializers.isEmpty {
                Section {
                    Heading { symbol.declaration is Protocol ? "Required Initializers" : "Initializers" }
                    ForEach(in: initializers) { initializer in
                        Symbol(initializer, in: module)
                    }
                }
            }

            if !properties.isEmpty {
                Section {
                    Heading { symbol.declaration is Protocol ? "Required Properties" : "Properties" }
                    ForEach(in: properties) { property in
                        Symbol(property, in: module)
                    }
                }
            }

            if !methods.isEmpty {
                Section {
                    Heading { symbol.declaration is Protocol ? "Required Methods" : "Methods" }
                    ForEach(in: methods) { method in
                        Symbol(method, in: module)
                    }
                }
            }
        }
    }
}
