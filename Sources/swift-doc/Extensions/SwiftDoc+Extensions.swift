import SwiftDoc
import SwiftSemantics
import GraphViz
import DOT
import struct Foundation.URL

extension Symbol {
    var node: Node {
        var node = Node(id.description)
        node.fontName = "Menlo"

        if !(api is Unknown) {
            node.href = "/" + path(for: self)
        }

        switch api {
        case let `class` as Class:
            node.shape = .ellipse
            if `class`.modifiers.contains(where: { $0.name == "final" }) {
                node.strokeWidth = 2.0
            }
        case is Structure:
            node.shape = .box
            node.style = .rounded
        case is Protocol:
            node.shape = .ellipse
            node.style = .dashed
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
        switch predicate {
        case .conformsTo:
            edge.style = .dashed
        default:
            break
        }

        return edge
    }
}
