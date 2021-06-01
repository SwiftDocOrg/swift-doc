import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct Members: Component {
    var symbol: Symbol
    var module: Module
    let baseURL: String

    let symbolFilter: (Symbol) -> Bool

    var members: [Symbol]

    var typealiases: [Symbol]
    var initializers: [Symbol]
    var cases: [Symbol]
    var properties: [Symbol]
    var methods: [Symbol]
    let operatorImplementations: [Symbol]
    var genericallyConstrainedMembers: [[GenericRequirement] : [Symbol]]
    let defaultImplementations: [Symbol]

    init(of symbol: Symbol, in module: Module, baseURL: String, symbolFilter: @escaping (Symbol) -> Bool) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL

        self.symbolFilter = symbolFilter

        self.members = module.interface.members(of: symbol)
            .filter { $0.extension?.genericRequirements.isEmpty != false }
            .filter(symbolFilter)

        self.typealiases = members.filter { $0.api is Typealias }
        self.initializers = members.filter { $0.api is Initializer }
        self.cases = members.filter { $0.api is Enumeration.Case }
        self.properties = members.filter { $0.api is Variable }
        self.methods = members.filter { ($0.api as? Function)?.isOperator == false }
        self.operatorImplementations = members.filter { ($0.api as? Function)?.isOperator == true }
        self.genericallyConstrainedMembers = Dictionary(grouping: members) { $0.`extension`?.genericRequirements ?? [] }.filter { !$0.key.isEmpty }
        self.defaultImplementations = module.interface.defaultImplementations(of: symbol).filter(symbolFilter)
    }

    var sections: [(title: String, members: [Symbol])] {
        return [
            (symbol.api is Protocol ? "Associated Types" : "Nested Type Aliases", typealiases),
            ("Initializers", initializers),
            ("Enumeration Cases", cases),
            ("Properties", properties),
            ("Methods", methods),
            ("Operators", operatorImplementations),
            ("Default Implementations", defaultImplementations),
        ].filter { !$0.members.isEmpty }
    }

    // MARK: - Component

    var fragment: Fragment {
        guard !members.isEmpty || !defaultImplementations.isEmpty else { return Fragment { "" } }

        return Fragment {
            ForEach(in: sections) { section -> BlockConvertible in
                Section {
                    Heading { section.title }
                    
                    Section {
                        ForEach(in: section.members) { member in
                            Heading {
                                Code { member.name }
                            }
                            Documentation(for: member, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter)
                        }
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
                                    Documentation(for: member, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        return #"""
        \#(sections.map { section -> HypertextLiteral.HTML in
            #"""
                <section id=\#(section.title.lowercased())>
                    <h2>\#(section.title)</h2>
            
                    \#(section.members.map { member -> HypertextLiteral.HTML in
                        let descriptor = String(describing: type(of: member.api)).lowercased()
                        let id = member.id.description.lowercased().replacingOccurrences(of: " ", with: "-")

                        return #"""
                        <div role="article" class="\#(descriptor)" id=\#(id)>
                            <h3>
                                <code><a href=\#("#\(id)")>\#(softbreak(member.name))</a></code>
                            </h3>
                            \#(Documentation(for: member, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter).html)
                        </div>
                        """#
                    })
                </section>
            """#
        })

        \#((genericallyConstrainedMembers.isEmpty ? "" :
            #"""
            <section id="generically-constrained-members">
                <h2>Generically Constrained Members</h2>

                \#(genericallyConstrainedMembers.map { (requirements, members) -> HypertextLiteral.HTML in
                    #"""
                    <section>
                        <h3>where \#(requirements.map { softbreak($0.description) }.joined(separator: ", "))</h3>
                        \#(members.map { member -> HypertextLiteral.HTML in
                            #"""
                            <h4>\#(softbreak(member.name))</h4>
                            \#(Documentation(for: member, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter).html)
                            """#
                        })
                    </section>
                    """#
                })
            </section>
            """#
        ) as HypertextLiteral.HTML)
        """#
    }
}
