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
    var globalTypealiases: [Symbol] = []
    var globalFunctions: [Symbol] = []
    var globalVariables: [Symbol] = []

    let externalTypes: [String]

    init(module: Module, externalTypes: [String], baseURL: String, symbolFilter: (Symbol) -> Bool) {
        self.module = module
        self.baseURL = baseURL

        self.externalTypes = externalTypes

        for symbol in module.interface.topLevelSymbols.filter(symbolFilter) {
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
            case is Function:
                globalFunctions.append(symbol)
            case is Variable:
                globalVariables.append(symbol)
            default:
                continue
            }
        }

        classes.sort()
        enumerations.sort()
        structures.sort()
        protocols.sort()
        globalTypealiases.sort()
        operators.sort(by: { (lhs, rhs) in
            guard let lo = lhs.api as? Operator, let ro = rhs.api as? Operator else { return false }
            return (lo.kind, lo.name) > (ro.kind, ro.name)
        })
        globalFunctions.sort()
        globalVariables.sort()
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
                ("Global Typealiases", globalTypealiases),
                ("Global Functions", globalFunctions),
                ("Global Variables", globalVariables),
                ("Operators", operators),
            ]) { (heading, symbols) in
                if (!symbols.isEmpty) {
                    Heading { heading }

                    List(of: symbols) { symbol in
                        Abstract(for: symbol, baseURL: baseURL).fragment
                    }
                }
            }

            if !externalTypes.isEmpty {
                Heading { "Extensions"}

                List(of: externalTypes.sorted()) { typeName in
                    List.Item {
                        Paragraph {
                            Link(urlString: path(for: route(for: typeName), with: baseURL), text: typeName)
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
            ("Typealiases", globalTypealiases),
            ("Functions", globalFunctions),
            ("Variables", globalVariables),
            ("Operators", operators),
        ].compactMap { (heading, symbols) -> HypertextLiteral.HTML? in
            guard !symbols.isEmpty else { return nil }

            return #"""
            <section id=\#(heading.lowercased())>
                <h2>\#(heading)</h2>
                <dl>
                    \#(symbols.map { Abstract(for: $0, baseURL: baseURL).html })
                </dl>
            </section>
        """#
        })
        \#((externalTypes.isEmpty ? "" :
            #"""
            <section id="extensions">
                <h2>Extensions</h2>
                <dl>
                \#(externalTypes.sorted().map {
                    #"""
                    <dt class="extension">
                        <a href="\#(path(for: route(for: $0), with: baseURL))">\#($0)</a>
                    </dt>
                    <dd></dd>
                    """# as HypertextLiteral.HTML
                })
                </dl>
            <section>
            """#
        ) as HypertextLiteral.HTML)
        """#
    }
}
