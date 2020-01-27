import CommonMarkBuilder
import SwiftDoc
import SwiftSemantics

struct HomePage: Page {
    var module: Module

    init(module: Module) {
        self.module = module
    }

    // MARK: - Page

    var body: Document {
        var typeNames: Set<String> = []
        var protocolNames: Set<String> = []
        var operatorNames: Set<String> = []
        var globalTypealiasNames: Set<String> = []
        var globalFunctionNames: Set<String> = []
        var globalVariableNames: Set<String> = []

        for symbol in module.topLevelSymbols.filter({ $0.declaration.isPublic }) {
            switch symbol.declaration {
            case let `class` as Class:
                typeNames.insert(`class`.qualifiedName)
            case let enumeration as Enumeration:
                typeNames.insert(enumeration.qualifiedName)
            case let structure as Structure:
                typeNames.insert(structure.qualifiedName)
            case let `protocol` as Protocol:
                protocolNames.insert(`protocol`.name)
            case let `typealias` as Typealias:
                globalTypealiasNames.insert(`typealias`.name)
            case let `operator` as Operator:
                operatorNames.insert(`operator`.name)
            case let function as Function where !function.isOperator:
                operatorNames.insert(function.name)
            case let function as Function:
                globalFunctionNames.insert(function.name)
            case let variable as Variable:
                globalVariableNames.insert(variable.name)
            default:
                continue
            }
        }

        return Document {
            ForEach(in: [
                ("Types", typeNames),
                ("Protocols", protocolNames),
                ("Operators", operatorNames)
            ]) { (heading, names) in
                if (!names.isEmpty) {
                    Heading { heading }
                    List(of: names.sorted()) { name in
                        Link(urlString: path(for: name), text: name)
                    }
                }
            }

            if !globalTypealiasNames.isEmpty ||
                !globalFunctionNames.isEmpty ||
                !globalVariableNames.isEmpty
            {
                Heading { "Globals" }

                Section {
                    ForEach(in: [
                          ("Typealiases", globalTypealiasNames),
                          ("Functions", globalFunctionNames),
                          ("Variables", globalVariableNames)
                      ]) { (heading, names) in
                        if (!names.isEmpty) {
                          Heading { heading }
                            
                          List(of: names.sorted()) { name in
                              Link(urlString: path(for: name), text: name)
                          }
                        }
                    }
                }
            }
        }
    }

    var lines: [String] {
        body.description.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    }
}
