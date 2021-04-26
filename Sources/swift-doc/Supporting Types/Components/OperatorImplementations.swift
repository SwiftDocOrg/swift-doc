import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct OperatorImplementations: Component {
    var symbol: Symbol
    var module: Module
    let baseURL: String

    var implementations: [Symbol]

    init(of symbol: Symbol, in module: Module, baseURL: String, implementations: [Symbol]) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL
        self.implementations = implementations
    }


    // MARK: - Component

    var fragment: Fragment {
        guard !implementations.isEmpty else { return Fragment { "" } }

        return Fragment {
            ForEach(in: implementations) { implementation -> BlockConvertible in
                Section {
                    Heading { implementation.name }

                    Documentation(for: implementation, in: module, baseURL: baseURL)
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let sections = implementations.compactMap { implementation -> HypertextLiteral.HTML? in
            guard let `operator` = symbol.api as? Operator,
                  let function = implementation.api as? Function
            else { return nil }

            let heading: String
            switch `operator`.kind {
            case .infix:
                guard function.signature.input.count == 2,
                      let lhs = function.signature.input.first,
                      let rhs = function.signature.input.last
                else {
                  return nil
                }

                heading = [lhs.type, function.name, rhs.type].compactMap { $0 }.joined(separator: " ")
            case .prefix:
                guard function.signature.input.count == 1,
                      let operand = function.signature.input.first
                else {
                  return nil
                }
                heading = [function.name, operand.type].compactMap { $0 }.joined(separator: " ")

            case .postfix:
                guard function.signature.input.count == 1,
                      let operand = function.signature.input.first
                else {
                  return nil
                }
                heading = [operand.type, function.name].compactMap { $0 }.joined(separator: " ")
            }

            return #"""
                   <div role="article" class="function" id=\#(implementation.id.description.lowercased().replacingOccurrences(of: " ", with: "-"))>
                       <h3>
                         \#(heading)
                         \#(unsafeUnescaped: function.genericWhereClause.map({ #"<small>\#($0.escaped)</small>"# }) ?? "")
                       </h3>
                       \#(Documentation(for: implementation, in: module, baseURL: baseURL).html)
                   </div>
                   """#
        }

        guard !sections.isEmpty else { return "" }

        return #"""
            <section id="implementations">
                <h2>Implementations</h2>
                \#(sections)
            </section>
        """#
    }
}

fileprivate extension Function {
    var genericWhereClause: String? {
        guard !genericRequirements.isEmpty else { return nil }
        return "where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
    }
}
