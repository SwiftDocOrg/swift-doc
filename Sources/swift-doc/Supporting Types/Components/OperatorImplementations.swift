import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct OperatorImplementations: Component {
    var symbol: Symbol
    var module: Module
    let baseURL: String

    let symbolFilter: (Symbol) -> Bool

    var implementations: [Symbol]

    init(of symbol: Symbol, in module: Module, baseURL: String, implementations: [Symbol], includingOtherSymbols symbolFilter: @escaping (Symbol) -> Bool) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL
        self.implementations = implementations
        self.symbolFilter = symbolFilter
    }


    // MARK: - Component

    var fragment: Fragment {
        guard !implementations.isEmpty else { return Fragment { "" } }

        return Fragment {
            ForEach(in: implementations) { implementation -> BlockConvertible in
                Section {
                    Heading { implementation.name }

                    Documentation(for: implementation, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter)
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

            let id = implementation.id.description.lowercased().replacingOccurrences(of: " ", with: "-")

            return #"""
                   <div role="article" class="function" id=\#(id)>
                       <h3>
                         <a href=\#("#\(id)")>\#(heading)
                         \#(unsafeUnescaped: function.genericWhereClause.map({ #"<small>\#($0.escaped)</small>"# }) ?? "")</a>
                       </h3>
                       \#(Documentation(for: implementation, in: module, baseURL: baseURL, includingOtherSymbols: symbolFilter).html)
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
