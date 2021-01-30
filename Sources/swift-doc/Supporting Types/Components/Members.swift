import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct Members: Component {
    var symbol: Symbol
    var module: Module
    let baseURL: String

    var members: [Symbol]

    var typealiases: [Symbol]
    var initializers: [Symbol]
    var cases: [Symbol]
    var properties: [Symbol]
    var methods: [Symbol]
    var genericallyConstrainedMembers: [[GenericRequirement] : [Symbol]]

    init(of symbol: Symbol, in module: Module, baseURL: String) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL

        self.members = module.interface.members(of: symbol)
            .filter { $0.extension?.genericRequirements.isEmpty != false }
            .filter { $0.isPublic }

        self.typealiases = members.filter { $0.api is Typealias }
        self.initializers = members.filter { $0.api is Initializer }
        self.cases = members.filter { $0.api is Enumeration.Case }
        self.properties = members.filter { $0.api is Variable }
        self.methods = members.filter { $0.api is Function }
        self.genericallyConstrainedMembers = Dictionary(grouping: members) { $0.`extension`?.genericRequirements ?? [] }.filter { !$0.key.isEmpty }
    }

    var sections: [(title: String, members: [Symbol])] {
        return [
            (symbol.api is Protocol ? "Associated Types" : "Nested Type Aliases", typealiases),
            ("Initializers", initializers),
            ("Enumeration Cases", cases),
            ("Properties", properties),
            ("Methods", methods)
        ].filter { !$0.members.isEmpty }
    }

    // MARK: - Component

    var fragment: Fragment {
        guard !members.isEmpty else { return Fragment { "" } }

        return Fragment {
            ForEach(in: sections) { section -> BlockConvertible in
                Section {
                    Heading { section.title }
                    
                    Section {
                        ForEach(in: section.members) { member in
                            Heading {
                                Code { member.name }
                            }
                            Documentation(for: member, in: module, baseURL: baseURL)
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
                                    Documentation(for: member, in: module, baseURL: baseURL)
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

                        return #"""
                        <div role="article" class="\#(descriptor)" id=\#(member.id.description.lowercased().replacingOccurrences(of: " ", with: "-"))>
                            <h3>
                                <code>\#(softbreak(member.name))</code>
                            </h3>
                            \#(Documentation(for: member, in: module, baseURL: baseURL).html)
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
                            \#(Documentation(for: member, in: module, baseURL: baseURL).html)
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
