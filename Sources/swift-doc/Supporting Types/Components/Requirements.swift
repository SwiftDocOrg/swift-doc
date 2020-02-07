import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct Requirements: Component {
    var symbol: Symbol
    var module: Module

    init(of symbol: Symbol, in module: Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var body: Fragment {
        let sections: [(title: String, requirements: [Symbol])] = [
            ("Requirements",  module.requirements(of: symbol)),
            ("Optional Requirements", module.optionalRequirements(of: symbol))
        ].filter { !$0.requirements.isEmpty}
        guard !sections.isEmpty else { return Fragment { "" } }

        return Fragment {
            ForEach(in: sections) { section -> BlockConvertible in
                Section {
                    Heading { section.title }
                    ForEach(in: section.requirements) { requirement in
                        Heading { requirement.name }
                        Documentation(for: requirement)
                    }
                }
            }
        }
    }
}
