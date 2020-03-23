import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import Foundation
import HypertextLiteral
import GraphViz
import DOT

extension StringBuilder {
    // MARK: buildIf

    public static func buildIf(_ string: String?) -> String {
        return string ?? ""
    }

    // MARK: buildEither

    public static func buildEither(first: String) -> String {
        return first
    }

    public static func buildEither(second: String) -> String {
        return second
    }
}

struct Inheritance: Component {
    var module: Module
    var symbol: Symbol
    var inheritedTypes: [Symbol]

    init(of symbol: Symbol, in module: Module) {
        self.module = module
        self.symbol = symbol
        self.inheritedTypes = module.interface.typesInherited(by: symbol) + module.interface.typesConformed(by: symbol)
    }

    // MARK: - Component

    var fragment: Fragment {
        guard !inheritedTypes.isEmpty else { return Fragment { "" } }

        return Fragment {
            Section {
                Heading { "Inheritance" }

                Fragment {
                    #"""
                    \#(inheritedTypes.map { type in
                        if type.api is Unknown {
                            return "`\(type.id)`"
                        } else {
                            return "[`\(type.id)`](\(path(for: type)))"
                        }
                    }.joined(separator: ", "))
                    """#
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let graph = symbol.graph(in: module)
        guard !graph.edges.isEmpty else { return "" }

        let svg = try! HTML(String(data: graph.render(using: .dot, to: .svg), encoding: .utf8) ?? "")

        return #"""
        <section id="inheritance">
            <figure>
                \#(svg)

                <figcaption hidden>Inheritance graph for \#(symbol.id).</figcaption>
            </figure>
        </section>
        """#
    }
}
