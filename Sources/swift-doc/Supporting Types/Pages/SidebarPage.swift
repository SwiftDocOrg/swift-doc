import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder

struct SidebarPage: Page {
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
            ForEach(in: (
                [
                    ("Types", typeNames),
                    ("Protocols", protocolNames),
                    ("Global Typealiases", globalTypealiasNames),
                    ("Global Variables",globalVariableNames),
                    ("Global Functions", globalFunctionNames),
                    ("Operators", operatorNames)
                ] as [(title: String, names: Set<String>)]
            ).filter { !$0.names.isEmpty }) { section in
                // FIXME: This should be an HTML block
                Fragment {
                    #"""
                    <details open>
                    <summary>\#(section.title)</summary>
                    """#
                }

                List(of: section.names.sorted()) { name in
                    Link(urlString: "\(path(for: name)).md", text: name)
                }

                Fragment { "</details>" }
            }
        }
    }
}
