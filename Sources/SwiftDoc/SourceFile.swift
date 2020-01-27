import Foundation
import SwiftMarkup
import SwiftSyntax
import SwiftSemantics
import struct SwiftSemantics.Protocol

public struct SourceFile: Hashable, Codable {
    public let path: String

    public let symbols: [Symbol]
    public let extendedSymbols: [Extension: [Symbol]]

    public init(file url: URL, relativeTo directory: URL) throws {
        self.path = url.path(relativeTo: directory)

        var symbols: [Symbol] = []
        var extendedSymbols: [Extension: [Symbol]] = [:]
        for case let (symbol, `extension`) in try Visitor(file: url, relativeTo: directory).visitedSymbols {
            if let `extension` = `extension` {
                extendedSymbols[`extension`, default: []] += [symbol]
            } else {
                symbols.append(symbol)
            }
        }
        
        self.symbols = symbols
        self.extendedSymbols = extendedSymbols
    }

    // MARK: -

    private struct Visitor: SyntaxVisitor {
        var currentCompilationConditions: [CompilationCondition] = []
        var currentExtension: Extension?
        var currentHeading: String?

        var visitedSymbols: [(Symbol, Extension?)] = []

        let sourceLocationConverter: SourceLocationConverter

        init(file url: URL, relativeTo directory: URL) throws {
            let tree = try SyntaxParser.parse(url)
            sourceLocationConverter = SourceLocationConverter(file: url.path(relativeTo: directory), tree: tree)
            tree.walk(&self)
            assert(currentExtension == nil)
            assert(currentCompilationConditions.isEmpty)
        }

        mutating func add<Node, Declaration>(_ type: Declaration.Type, _ node: Node) where Declaration: API & ExpressibleBySyntax, Node == Declaration.Syntax {
            add(node, declaration: Declaration(node))
        }

        mutating func add<Node: Syntax>(_ node: Node, declaration: API) {
            let documentation = try! Documentation.parse(node.documentation)
            let sourceLocation = sourceLocationConverter.location(for: node.position)
            var symbol = Symbol(declaration: declaration, documentation: documentation, sourceLocation: sourceLocation)
            symbol.conditions = currentCompilationConditions
            visitedSymbols.append((symbol, currentExtension))
        }

        // MARK: - SyntaxVisitor

        mutating func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
            add(AssociatedType.self, node)
            return .skipChildren
        }

        mutating func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Class.self, node)
            return .visitChildren
        }

        mutating func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Enumeration.self, node)
            return .visitChildren
        }

        mutating func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
            for `case` in Enumeration.Case.cases(from: node) {
                add(node, declaration: `case`)
            }
            return .skipChildren
        }

        mutating func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
            assert(currentExtension == nil)
            currentExtension = Extension(node)
            return .visitChildren
        }

        mutating func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Function.self, node)
            return .skipChildren
        }

        mutating func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
            return .visitChildren
        }

        mutating func visit(_ node: IfConfigClauseSyntax) -> SyntaxVisitorContinueKind {
            assert(node.parent is IfConfigClauseListSyntax)
            assert(node.parent?.parent is IfConfigDeclSyntax)

            let block = ConditionalCompilationBlock(node.parent?.parent as! IfConfigDeclSyntax)
            let branch = ConditionalCompilationBlock.Branch(node)
            currentCompilationConditions.append(CompilationCondition(block: block, branch: branch))

            return .visitChildren
        }

        mutating func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Initializer.self, node)
            return .skipChildren
        }

        mutating func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
            add(PrecedenceGroup.self, node)
            return .skipChildren
        }

        mutating func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Protocol.self, node)
            return .visitChildren
        }

        mutating func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Subscript.self, node)
            return .skipChildren
        }

        mutating func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Structure.self, node)
            return .visitChildren
        }

        mutating func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
            add(Typealias.self, node)
            return .skipChildren
        }

        mutating func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
            for variable in Variable.variables(from: node) {
                add(node, declaration: variable)
            }
            return .skipChildren
        }

        mutating func visitPost(_ node: ExtensionDeclSyntax) {
            assert(currentExtension != nil)
            currentExtension = nil
        }

        mutating func visitPost(_ node: IfConfigClauseSyntax) {
            assert(!currentCompilationConditions.isEmpty)
            currentCompilationConditions.removeLast()
        }
    }
}
