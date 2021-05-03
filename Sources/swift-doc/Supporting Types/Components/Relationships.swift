import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import Foundation
import HypertextLiteral
import GraphViz

fileprivate typealias SVG = HypertextLiteral.HTML

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

struct Relationships: Component {
    var module: Module
    var symbol: Symbol
    let baseURL: String
    var inheritedTypes: [Symbol]
    let symbolFilter: (Symbol) -> Bool

    init(of symbol: Symbol, in module: Module, baseURL: String, includingChildren symbolFilter: @escaping (Symbol) -> Bool) {
        self.module = module
        self.symbol = symbol
        self.inheritedTypes = module.interface.typesInherited(by: symbol) + module.interface.typesConformed(by: symbol)
        self.baseURL = baseURL
        self.symbolFilter = symbolFilter
    }

    var graphHTML: HypertextLiteral.HTML? {
        var graph = symbol.graph(in: module, baseURL: baseURL, includingChildren: symbolFilter)
        guard !graph.edges.isEmpty else { return nil }

        graph.aspectRatio = 0.125
        graph.center = true
        graph.overlap = "compress"

        let algorithm: LayoutAlgorithm = graph.nodes.count > 3 ? .neato : .dot

        do {
            let data = try _await { graph.render(using: algorithm, to: .svg, completion: $0) }
            return SVG(String(data: data, encoding: .utf8) ?? "")
        } catch {
            logger.warning("Failed to generate relationship graph for \(symbol.id). Please ensure that GraphViz binaries are accessible from your PATH. (\(error))")
            return nil
        }
    }

    var sections: [(title: String, symbols: [Symbol])] {
        return [
            ("Member Of", [module.interface.relationshipsBySubject[symbol.id]?.filter { $0.predicate == .memberOf }.first?.object].compactMap { $0 }),
            ("Nested Types", module.interface.members(of: symbol).filter { $0.api is Type }),
            ("Superclass", module.interface.typesInherited(by: symbol)),
            ("Subclasses", module.interface.typesInheriting(from: symbol)),
            ("Conforms To", module.interface.typesConformed(by: symbol)),
            ("Types Conforming to <code>\(softbreak(symbol.id.description))</code>", module.interface.typesConforming(to: symbol)),
        ].map { (title: $0.0, symbols: $0.1.filter { $0.isPublic }) }.filter { !$0.symbols.isEmpty }
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
                    return "[`\(type.id)`](\(path(for: type, with: baseURL)))"
                        }
                    }.joined(separator: ", "))
                    """#
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        guard !sections.isEmpty else { return "" }

        return #"""
        <section id="relationships">
            <h2 hidden>Relationships</h2>
                \#(graphHTML.flatMap { (graphHTML) -> HypertextLiteral.HTML in
                    return #"""
                    <figure>
                        \#(graphHTML)

                        <figcaption hidden>Inheritance graph for \#(symbol.id).</figcaption>
                    </figure>
                    """#
                } ?? "")
                \#(sections.compactMap { (heading, symbols) -> HypertextLiteral.HTML? in
                    let partitioned = symbols.filter { !($0.api is Unknown) } + symbols.filter { ($0.api is Unknown) }

                    return #"""
                    <h3>\#(unsafeUnescaped: heading)</h3>
                    <dl>
                        \#(partitioned.map { symbol -> HypertextLiteral.HTML in
                            let descriptor = String(describing: type(of: symbol.api)).lowercased()
                            if symbol.api is Unknown {
                                return #"""
                                <dt class="\#(descriptor)"><code>\#(symbol.id)</code></dt>
                                """#
                            } else {
                                return #"""
                                <dt class="\#(descriptor)"><code><a href="\#(path(for: symbol, with: baseURL))">\#(symbol.id)</a></code></dt>
                                <dd>\#(commonmark: symbol.documentation?.summary?.description ?? "")</dd>
                                """#
                            }
                        })
                    </dl>
                    """#
                })
        </section>
        """#
    }
}
