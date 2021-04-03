import ArgumentParser
import Foundation
import SwiftDoc
import SwiftSemantics
import GraphViz

extension SwiftDoc {
    struct Diagram: ParsableCommand {
        struct Options: ParsableArguments {
            @Argument(help: "One or more paths to a directory containing Swift files.")
            var inputs: [String]

            @Option(name: .long,
                    help: "The minimum access level of the symbols included in the generated diagram.")
            var minimumAccessLevel: AccessLevel = .public
        }
        
        static var configuration = CommandConfiguration(abstract: "Generates diagram of Swift symbol relationships")
        
        @OptionGroup()
        var options: Options

        func run() throws {
            let module = try Module(paths: options.inputs)
            print(diagram(of: module, including: options.minimumAccessLevel.includes(symbol:)), to: &standardOutput)
        }
    }
}

// MARK: -

fileprivate func diagram(of module: Module, including symbolFilter: (Symbol) -> Bool) -> String {
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
    

    for symbol in (module.interface.symbols.filter { $0.api is Type }).filter(symbolFilter) {
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
