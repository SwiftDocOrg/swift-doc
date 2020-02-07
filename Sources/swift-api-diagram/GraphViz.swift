import SwiftSemantics
import SwiftDoc

fileprivate extension String {
    func indented(by spaces: Int = 2) -> String {
        return String(repeating: " ", count: spaces) + self
    }
}

// MARK: -

enum GraphViz {
    static func diagram(of module: Module) -> String {
        var lines: [String] = []

        var classClusters: [Symbol: Set<Symbol>] = [:]
        for baseClass in module.baseClasses {
            var superclasses = Set(CollectionOfOne(baseClass))

            while !superclasses.isEmpty {
                let subclasses = Set(superclasses.flatMap { module.typesInheriting(from: $0) }
                                                 .filter { $0.isPublic })
                defer { superclasses = subclasses }
                classClusters[baseClass, default: []].formUnion(subclasses)
            }
        }

        for (baseClass, cluster) in classClusters {
            var clusterLines: [String] = []

            for subclass in cluster {
                if subclass.declaration.modifiers.contains(where: { $0.name == "final" }) {
                    clusterLines.append(#""\#(subclass.id)" [shape=box,peripheries=2];"#)
                } else {
                    clusterLines.append(#""\#(subclass.id)" [shape=box];"#)
                }

                for superclass in module.typesInherited(by: subclass) {
                    clusterLines.append(#""\#(subclass.id)" -> "\#(superclass.id)";"#)
                }
            }

            if cluster.count > 1 {
                clusterLines = (
                    ["", "subgraph cluster_\(baseClass.id.description.replacingOccurrences(of: ".", with: "_")) {"] +
                    clusterLines.map { $0.indented() } +
                    ["}", ""]
                )
            }

            lines.append(contentsOf: clusterLines)
        }

        lines.append("")

        for symbol in (module.symbols.filter { $0.isPublic && $0.declaration is Type }) {
            for inherited in module.typesConformed(by: symbol) {
                lines.append(#""\#(symbol.id)" -> "\#(inherited.id)";"#)
            }
        }

        lines = ["digraph \(module.name) {"] +
                    lines.map { $0.indented() } +
                ["}"]

        return lines.joined(separator: "\n")
    }
}
