import SwiftDoc
import SwiftSemantics
import GraphViz
import struct Foundation.URL

extension Symbol {
    var node: Node {
        var node = Node(id.description)
        node.fontName = "Menlo"
        node.shape = .box
        node.style = .rounded

        node.width = 3
        node.height = 0.5
        node.fixedSize = .shape

        switch api {
        case let `class` as Class:
            node.class = "class"
            if `class`.modifiers.contains(where: { $0.name == "final" }) {
                node.strokeWidth = 2.0
            }
        case is Enumeration:
            node.class = "enumeration"
        case is Structure:
            node.class = "structure"
        case is Protocol:
            node.class = "protocol"
        case is Unknown:
            node.class = "unknown"
        default:
            break
        }

        return node
    }

    func graph(in module: Module, baseURL: String, includingChildren symbolFilter: (Symbol) -> Bool) -> Graph {
        var graph = Graph(directed: true)

        do {
            var node = self.node

            if !(api is Unknown) && symbolFilter(self) {
                node.href = path(for: self, with: baseURL)
            }

            node.strokeWidth = 3.0
            node.class = [node.class, "current"].compactMap { $0 }.joined(separator: " ")

            graph.append(node)
        }

        let relationships = module.interface.relationships.filter {
            ($0.predicate == .inheritsFrom || $0.predicate == .conformsTo) &&
            ($0.subject == self || $0.object == self)
        }

        for symbol in Set(relationships.flatMap { [$0.subject, $0.object] }) {
            guard self != symbol else { continue }
            var node = symbol.node

            if !(symbol.api is Unknown) && symbolFilter(symbol) {
                node.href = path(for: symbol, with: baseURL)
            }
            graph.append(node)
        }

        for relationship in relationships {
            let edge = relationship.edge
            graph.append(edge)
        }

        return graph
    }
}

extension Relationship {
    var edge: Edge {
        let from = subject.node
        let to = object.node

        var edge = Edge(from: from.id, to: to.id)
        edge.class = predicate.rawValue
        edge.preferredEdgeLength = 1.5

        return edge
    }
}
