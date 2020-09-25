import ArgumentParser
import Foundation
import SwiftDoc
import SwiftSemantics
import GraphViz
import DOT


extension SwiftDoc {
    struct Diagram: ParsableCommand {
        struct Options: ParsableArguments {
            @Argument(help: "One or more paths to Swift files")
            var inputs: [String]
        }
        
        static var configuration = CommandConfiguration(abstract: "Generates diagram of Swift symbol relationships")
        
        @OptionGroup()
        var options: Options
        
        func run() throws {
            let module = try Module(paths: options.inputs)
            print(diagram(of: module), to: &standardOutput)
        }
    }
}

// MARK: -

fileprivate func diagram(of module: Module) -> String {
    var graph = Graph(directed: true)
    
    for (baseClass, subclasses) in module.interface.classHierarchies {
        var subgraph = Subgraph(id: "cluster_\(baseClass.id.description.replacingOccurrences(of: ".", with: "_"))")

        for subclass in subclasses {
            var subclassNode = Node("\(subclass.id)")
            subclassNode.shape = .box

            if subclass.api.modifiers.contains(where: { $0.name == "final" }) {
                subclassNode.strokeWidth = 2.0
            }

            subgraph.append(subclassNode)
            
            for superclass in module.interface.typesInherited(by: subclass) {
                let superclassNode = Node("\(superclass.id)")
                subgraph.append(superclassNode)

                let edge = Edge(from: subclassNode, to: superclassNode)
                subgraph.append(edge)
            }
        }
        
        if subclasses.count > 1 {
            graph.append(subgraph)
        } else {
            subgraph.nodes.forEach { graph.append($0) }
            subgraph.edges.forEach { graph.append($0) }
        }
    }
    

    for symbol in (module.interface.symbols.filter { $0.isPublic && $0.api is Type }) {
        let symbolNode = Node("\(symbol.id)")
        graph.append(symbolNode)

        for inherited in module.interface.typesConformed(by: symbol) {
            let inheritedNode = Node("\(inherited.id.description)")
            let edge = Edge(from: symbolNode, to: inheritedNode)

            graph.append(inheritedNode)
            graph.append(edge)
        }
    }

    let encoder = DOTEncoder()
    let dot = encoder.encode(graph)

    return dot
}
