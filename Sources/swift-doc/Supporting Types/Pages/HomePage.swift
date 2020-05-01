import CommonMarkBuilder
import SwiftDoc
import SwiftSemantics
import HypertextLiteral

struct HomePage: Page {
    var module: Module

    var classes: [Symbol] = []
    var enumerations: [Symbol] = []
    var structures: [Symbol] = []
    var protocols: [Symbol] = []
    var operators: [Symbol] = []
    var globalTypealiases: [Symbol] = []
    var globalFunctions: [Symbol] = []
    var globalVariables: [Symbol] = []

    init(module: Module) {
        self.module = module

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
                globalTypealiases.append(symbol)
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
        return Document {
            ForEach(in: [
                ("Types", classes + enumerations + structures),
                ("Protocols", protocols),
                ("Operators", operators),
                ("Global Typealiases", globalTypealiases),
                ("Global Functions", globalFunctions),
                ("Global Variables", globalVariables),
            ]) { (heading, symbols) in
                if (!symbols.isEmpty) {
                    Heading { heading }

                    // FIXME: HTMLBlock doesn't render for some reason
                    Paragraph {
                        RawHTML {
                            listHTML(symbols: symbols).description
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
        guard !globalTypealiases.isEmpty ||
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
            ("Typealiases", globalTypealiases),
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
                <a href=\#(path(for: symbol)) title="\#(descriptor) - \#(symbol.id.description)">
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
