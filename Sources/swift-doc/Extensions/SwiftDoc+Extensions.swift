import SwiftDoc
import SwiftSemantics
import GraphViz
import DOT
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

        if !(api is Unknown) {
            node.href = "/" + path(for: self)
        }

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

    func graph(in module: Module) -> Graph {
        var graph = Graph(directed: true)

        let relationships = module.interface.relationships.filter {
            ($0.predicate == .inheritsFrom || $0.predicate == .conformsTo) &&
            ($0.subject == self || $0.object == self)
        }

        var symbolNode = self.node
        symbolNode.strokeWidth = 3.0
        symbolNode.class = [symbolNode.class, "current"].compactMap { $0 }.joined(separator: " ")

        graph.append(symbolNode)

        for node in Set(relationships.flatMap { [$0.subject.node, $0.object.node] }) where node.id != symbolNode.id {
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
