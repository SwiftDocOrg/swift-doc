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

        var baseClasses: Set<String> = []
        var inheritanceMappings: [String: String] = [:]

        let symbols = module.symbols.filter { $0.declaration.isPublic }

        let classes = symbols.filter { $0.declaration is Class }
        for `class` in classes {
            if let declaration = `class`.declaration as? Class,
                let firstInheritedType = declaration.inheritance.first
            {
                if classes.contains(where: { $0.declaration.name.hasSuffix(firstInheritedType) }) {
                    inheritanceMappings[`class`.declaration.qualifiedName] = firstInheritedType
                }
            } else {
                baseClasses.insert(`class`.declaration.qualifiedName)
            }
        }

        var classClusters: [String: Set<String>] = [:]
        for baseClass in baseClasses {
            var cluster: Set<String> = [baseClass]

            var previousCount = -1
            while cluster.count > previousCount {
                previousCount = cluster.count
                for (subclass, superclass) in inheritanceMappings {
                    if cluster.contains(superclass) {
                        cluster.insert(subclass)
                    }
                }
            }

            classClusters[baseClass] = cluster
        }

        for (baseClass, cluster) in classClusters {
            var clusterLines: [String] = []

            for className in cluster {
                if let `class` = classes.first(where: { $0.declaration.qualifiedName == className }),
                    let declaration = `class`.declaration as? Class,
                    declaration.modifiers.contains(where: { $0.name == "final" }) == true
                {
                    clusterLines.append(#""\#(className)" [shape=box,peripheries=2];"#)
                } else {
                    clusterLines.append(#""\#(className)" [shape=box];"#)
                }
            }

            if cluster.count > 1 {
                for (subclassName, superclassName) in inheritanceMappings {
                    if cluster.contains(superclassName) {
                        clusterLines.append(#""\#(subclassName)" -> "\#(superclassName)";"#)
                    }
                }

                clusterLines = (
                    ["", "subgraph cluster_\(baseClass) {"] +
                    clusterLines.map { $0.indented() } +
                    ["}", ""]
                )
            }

            lines.append(contentsOf: clusterLines)
        }

        lines.append("")

        for symbol in (symbols.filter { $0.declaration is Type }) {
            guard let type = symbol.declaration as? Type else { continue }
            for item in type.inheritance {
                guard !inheritanceMappings.values.contains(item) else { continue }
                for inherited in item.split(separator: "&").map({ String($0).trimmingCharacters(in: .whitespacesAndNewlines) }) {
                    lines.append(#""\#(type.qualifiedName)" -> "\#(inherited)";"#)
                }
            }
        }

        lines = ["digraph \(module.name) {"] +
                    lines.map { $0.indented() } +
                ["}"]

        return lines.joined(separator: "\n")
    }
}
