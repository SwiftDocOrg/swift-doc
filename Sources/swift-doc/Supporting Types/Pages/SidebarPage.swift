import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral

struct SidebarPage: Page {
    var module: Module

    var typeNames: Set<String> = []
    var protocolNames: Set<String> = []
    var operatorNames: Set<String> = []
    var globalTypealiasNames: Set<String> = []
    var globalFunctionNames: Set<String> = []
    var globalVariableNames: Set<String> = []

    init(module: Module) {
        self.module = module

        for symbol in module.interface.topLevelSymbols.filter({ $0.isIncluded(minimumAccessLevel: module.minimumAccessLevel) }) {
            switch symbol.api {
            case is Class:
                typeNames.insert(symbol.id.description)
            case is Enumeration:
                typeNames.insert(symbol.id.description)
            case is Structure:
                typeNames.insert(symbol.id.description)
            case let `protocol` as Protocol:
                protocolNames.insert(`protocol`.name)
            case let `typealias` as Typealias:
                globalTypealiasNames.insert(`typealias`.name)
            case let `operator` as Operator:
                operatorNames.insert(`operator`.name)
            case let function as Function where function.isOperator:
                operatorNames.insert(function.name)
            case let function as Function:
                globalFunctionNames.insert(function.name)
            case let variable as Variable:
                globalVariableNames.insert(variable.name)
            default:
                continue
            }
        }
    }

    // MARK: - Page

    var document: CommonMark.Document {
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
                    <details>
                    <summary>\#(section.title)</summary>
                    """#
                }

                List(of: section.names.sorted()) { name in
                    Link(urlString: "/" + path(for: name), text: name)
                }

                Fragment { "</details>" }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        #"""
        \#(document)
        """#
    }
}
