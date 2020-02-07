import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct Members: Component {
    var symbol: Symbol
    var module: Module

    init(of symbol: Symbol, in module: Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        let members = module.members(of: symbol).filter { $0.extension?.genericRequirements.isEmpty != false }
        guard !members.isEmpty else { return Fragment { "" } }

        let typealiases = members.filter { $0.declaration is Typealias }
        let cases = members.filter { $0.declaration is Enumeration.Case }
        let initializers = members.filter { $0.declaration is Initializer }
        let properties = members.filter { $0.declaration is Variable }
        let methods = members.filter { $0.declaration is Function }
        let genericallyConstrainedMembers = Dictionary(grouping: members) { $0.`extension`?.genericRequirements ?? [] }.filter { !$0.key.isEmpty }

        let sections: [(title: String, members: [Symbol])] = [
            (symbol.declaration is Protocol ? "Associated Types" : "Nested Type Aliases", typealiases),
            ("Enumeration Cases", cases),
            ("Initializers", initializers),
            ("Properties", properties),
            ("Methods", methods)
        ].filter { !$0.members.isEmpty }

        return Fragment {
            ForEach(in: sections) { section -> BlockConvertible in
                Section {
                    Heading { section.title }
                    ForEach(in: section.members) { member in
                        Heading { member.name }
                        Documentation(for: member)
                    }
                }
            }

            if !genericallyConstrainedMembers.isEmpty {
                Section {
                    Heading { "Generically Constrained Members" }

                    ForEach(in: genericallyConstrainedMembers) { (requirements, members) in
                        Section {
                            Heading { "where \(requirements.map { $0.description }.joined(separator: ", "))"}

                            Section {
                                ForEach(in: members) { member in
                                    Heading { member.name }
                                    Documentation(for: member)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
