import CommonMarkBuilder
import SwiftDoc
import SwiftSemantics
import HypertextLiteral

struct HomePage: Page {
    var module: Module

    var types: [Symbol] = []
    var protocols: [Symbol] = []
    var operatorNames: Set<String> = []
    var globalTypealiasNames: Set<String> = []
    var globalFunctionNames: Set<String> = []
    var globalVariableNames: Set<String> = []

    init(module: Module) {
        self.module = module

        for symbol in module.interface.topLevelSymbols.filter({ $0.isPublic }) {
            switch symbol.api {
            case is Class,
                 is Enumeration,
                 is Structure:
                types.append(symbol)
            case is Protocol:
                protocols.append(symbol)
            case let `typealias` as Typealias:
                globalTypealiasNames.insert(`typealias`.name)
            case let `operator` as Operator:
                operatorNames.insert(`operator`.name)
            case let function as Function where !function.isOperator:
                operatorNames.insert(function.name)
            case let function as Function:
                globalFunctionNames.insert(function.name)
            case let variable as Variable:
                globalVariableNames.insert(variable.name)
            default:
                continue
            }
        }
    }

    // MARK: - Page

    var title: String {
        return module.name
    }

    var document: CommonMark.Document {
        let typeNames = Set(types.map { $0.id.description })
        let protocolNames = Set(protocols.map { $0.id.description })

        return Document {
            ForEach(in: [
                ("Types", typeNames),
                ("Protocols", protocolNames),
                ("Operators", operatorNames)
            ]) { (heading, names) in
                if (!names.isEmpty) {
                    Heading { heading }
                    List(of: names.sorted()) { name in
                        Link(urlString: path(for: name), text: name)
                    }
                }
            }

            if !globalTypealiasNames.isEmpty ||
                !globalFunctionNames.isEmpty ||
                !globalVariableNames.isEmpty
            {
                Heading { "Globals" }

                Section {
                    ForEach(in: [
                          ("Typealiases", globalTypealiasNames),
                          ("Functions", globalFunctionNames),
                          ("Variables", globalVariableNames)
                      ]) { (heading, names) in
                        if (!names.isEmpty) {
                          Heading { heading }
                            
                          List(of: names.sorted()) { name in
                            Link(urlString: path(for: name), text: softbreak(name))
                          }
                        }
                    }
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        return #"""
        \#([
            ("Types", types),
            ("Protocols", protocols),
        ].compactMap { (heading, symbols) -> HypertextLiteral.HTML? in
            guard !symbols.isEmpty else { return nil }

            return #"""
            <h2>\#(heading)</h2>
            <ul>
                \#(symbols.sorted().map { symbol ->  HypertextLiteral.HTML in
                let descriptor = String(describing: type(of: symbol.api))
                return #"""
                <li class="\#(descriptor.lowercased())">
                    <a href=\#(path(for: symbol)) title="\#(descriptor) - \#(symbol.id.description)">
                        \#(symbol.id.description)
                    </a>
                </li>
                """# as HypertextLiteral.HTML
                })
            </ul>
        """# as HypertextLiteral.HTML
        })
        """#
    }
}
