import CommonMarkBuilder
import SwiftDoc
import SwiftSemantics
import HypertextLiteral

struct HomePage: Page {
    var module: Module
    let baseURL: String

    var classes: [Symbol] = []
    var enumerations: [Symbol] = []
    var structures: [Symbol] = []
    var protocols: [Symbol] = []
    var operators: [Symbol] = []
    var globalTypealias: [Symbol] = []
    var globalFunctions: [Symbol] = []
    var globalVariables: [Symbol] = []

    init(module: Module, baseURL: String) {
        self.module = module
        self.baseURL = baseURL

        for symbol in module.interface.topLevelSymbols.filter({ $0.isPublic }) {
            switch symbol.api {
            case is Class:
                classes.append(symbol)
            case is Enumeration:
                enumerations.append(symbol)
            case is Structure:
                structures.append(symbol)
            case is Protocol:
                protocols.append(symbol)
            case is Typealias:
                globalTypealias.append(symbol)
            case is Operator:
                operators.append(symbol)
            case let function as Function where function.isOperator:
                operators.append(symbol)
            case is Function:
                globalFunctions.append(symbol)
            case is Variable:
                globalVariables.append(symbol)
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
        let types = classes + enumerations + structures
        let typeNames = Set(types.map { $0.id.description })
        let protocolNames = Set(protocols.map { $0.id.description })
        let operatorNames = Set(operators.map { $0.id.description })

        let globalTypealiasNames = Set(globalTypealias.map { $0.id.description })
        let globalFunctionNames = Set(globalFunctions.map { $0.id.description })
        let globalVariableNames = Set(globalVariables.map { $0.id.description })

        return Document {
            ForEach(in: [
                ("Types", typeNames),
                ("Protocols", protocolNames),
                ("Operators", operatorNames)
            ]) { (heading, names) in
                if (!names.isEmpty) {
                    Heading { heading }
                    List(of: names.sorted()) { name in
                        Link(urlString: path(for: name, with: baseURL), text: name)
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
                            Link(urlString: path(for: name, with: baseURL), text: softbreak(name))
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
            ("Classes", classes),
            ("Structures", structures),
            ("Enumerations", enumerations),
            ("Protocols", protocols),
        ].compactMap { (heading, symbols) -> HypertextLiteral.HTML? in
            guard !symbols.isEmpty else { return nil }

            return #"""
            <section id=\#(heading.lowercased())>
                <h2>\#(heading)</h2>
                \#(listHTML(symbols: symbols))
            </section>
        """#
        })
        \#(globalsHTML)
        """#
    }

    private var globalsHTML: HypertextLiteral.HTML {
        guard !globalTypealias.isEmpty ||
            !globalFunctions.isEmpty ||
            !globalVariables.isEmpty else {
                return ""
        }

        let heading = "Globals"
        return #"""
        <section id=\#(heading.lowercased())>
            <h2>\#(heading)</h2>
            \#(globalsListHTML)
        </section>
        """#
    }

    private var globalsListHTML: HypertextLiteral.HTML {
        let globals = [
            ("Typealiases", globalTypealias),
            ("Functions", globalFunctions),
            ("Variables", globalVariables),
        ]
        return #"""
        \#(globals.compactMap { (heading, symbols) -> HypertextLiteral.HTML? in
            guard !symbols.isEmpty else { return nil }

            return #"""
            <section id=\#(heading.lowercased())>
                <h3>\#(heading)</h3>
                \#(listHTML(symbols: symbols))
            </section>
        """#
        })
        """#
    }

    private func listHTML(symbols: [Symbol]) -> HypertextLiteral.HTML {
        #"""
        <dl>
            \#(symbols.sorted().map { symbol ->  HypertextLiteral.HTML in
            let descriptor = String(describing: type(of: symbol.api)).lowercased()
            return #"""
            <dt class="\#(descriptor)">
                <a href=\#(path(for: symbol, with: baseURL)) title="\#(descriptor) - \#(symbol.id.description)">
                    \#(softbreak(symbol.id.description))
                </a>
            </dt>
            <dd>
                \#(commonmark: symbol.documentation?.summary ?? "")
            </dd>
            """#
            })
        </dl>
        """#
    }
}
