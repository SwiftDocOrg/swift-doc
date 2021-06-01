import CommonMarkBuilder
import SwiftDoc
import HypertextLiteral
import SwiftMarkup
import SwiftSemantics

struct ExternalTypePage: Page {

    let module: Module
    let externalType: String
    let baseURL: String

    let typealiases: [Symbol]
    let initializers: [Symbol]
    let properties: [Symbol]
    let methods: [Symbol]

    let symbolFilter: (Symbol) -> Bool

    init(module: Module, externalType: String, symbols: [Symbol], baseURL: String, includingOtherSymbols symbolFilter: @escaping (Symbol) -> Bool) {
        self.module = module
        self.externalType = externalType
        self.baseURL = baseURL
        self.symbolFilter = symbolFilter

        self.typealiases = symbols.filter { $0.api is Typealias }
        self.initializers = symbols.filter { $0.api is Initializer }
        self.properties = symbols.filter { $0.api is Variable }
        self.methods = symbols.filter { $0.api is Function }
    }

    var title: String { externalType }

    var sections: [(title: String, members: [Symbol])] {
        return [
            ("Nested Type Aliases", typealiases),
            ("Initializers", initializers),
            ("Properties", properties),
            ("Methods", methods),
        ].filter { !$0.members.isEmpty }
    }

    var document: CommonMark.Document {
        Document {
            Heading { "Extensions on \(externalType)" }
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
        }
    }
    var html: HypertextLiteral.HTML {
        #"""
        <h1>
            <small>Extensions on</small>
            <code class="name">\#(externalType)</code>
        </h1>
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
        """#
    }
}
