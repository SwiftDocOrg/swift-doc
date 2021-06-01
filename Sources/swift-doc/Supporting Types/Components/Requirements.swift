import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct Requirements: Component {
    var symbol: Symbol
    var module: Module
    let baseURL: String
    let symbolFilter: (Symbol) -> Bool

    init(of symbol: Symbol, in module: Module, baseURL: String, includingOtherSymbols symbolFilter: @escaping (Symbol) -> Bool) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL
        self.symbolFilter = symbolFilter
    }

    var sections: [(title: String, requirements: [Symbol])] {
        return [
            ("Requirements",  module.interface.requirements(of: symbol)),
            ("Optional Requirements", module.interface.optionalRequirements(of: symbol))
        ].filter { !$0.requirements.isEmpty }
    }

    // MARK: - Component

    var fragment: Fragment {
        guard !sections.isEmpty else { return Fragment { "" } }

        return Fragment {
            ForEach(in: sections) { section -> BlockConvertible in
                Section {
                    Heading { section.title }
                    Section {
                        ForEach(in: section.requirements) { requirement in
                            Heading { requirement.name.escapingEmojiShortcodes }
                            Documentation(for: requirement, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter)
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

                    \#(section.requirements.map { member -> HypertextLiteral.HTML in
                        let descriptor = String(describing: type(of: member.api)).lowercased()

                        return #"""
                        <div role="article" class="\#(descriptor)" id=\#(member.id.description.lowercased().replacingOccurrences(of: " ", with: "-"))>
                            <h3>
                                <code>\#(softbreak(member.name))</code>
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
