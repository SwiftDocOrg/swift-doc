import Foundation
import SwiftMarkup
import SwiftSyntax
import SwiftSemantics
import struct SwiftSemantics.Protocol
import class SwiftSyntaxHighlighter.SwiftSyntaxHighlighter
import struct Highlighter.Token
import enum Xcode.Xcode

public protocol Contextual {}
extension Symbol: Contextual {}
extension Extension: Contextual {}
extension CompilationCondition: Contextual {}

// MARK: -

public struct SourceFile: Hashable, Codable {
    public let path: String

    public let symbols: [Symbol]

    public let imports: [Import]

    public init(file url: URL, relativeTo directory: URL) throws {
        self.path = url.path(relativeTo: directory)

        let visitor = try Visitor(file: url, relativeTo: directory)

        self.symbols = visitor.visitedSymbols
        self.imports = visitor.visitedImports
    }

    // MARK: -

    private class Visitor: SyntaxVisitor {
        var context: [Contextual] = []

        var visitedSymbols: [Symbol] = []
        var visitedImports: [Import] = []

        let fileURL: URL
        let sourceLocationConverter: SourceLocationConverter

        init(file url: URL, relativeTo directory: URL) throws {
            self.fileURL = url

            let tree = try SyntaxParser.parse(url)
            sourceLocationConverter = SourceLocationConverter(file: url.path(relativeTo: directory), tree: tree)
            super.init()

            walk(tree)

            assert(context.isEmpty)
        }

        func symbol<Node, Declaration>(_ type: Declaration.Type, _ node: Node) -> Symbol? where Declaration: API & ExpressibleBySyntax, Node == Declaration.Syntax, Node: SymbolDeclProtocol {
            guard let api = Declaration(node) else { return nil }
            guard let documentation = try? Documentation.parse(node.documentation) else { return nil }
            let sourceRange = node.sourceRange(using: sourceLocationConverter)
            return Symbol(api: api, context: context, declaration: declaration(for: node), documentation: documentation, sourceRange: sourceRange)
        }

        func symbol<Node: SymbolDeclProtocol>(_ node: Node, api: API) -> Symbol? {
            guard let documentation = try? Documentation.parse(node.documentation) else { return nil }
            let sourceRange = node.sourceRange(using: sourceLocationConverter)
            return Symbol(api: api, context: context, declaration: declaration(for: node), documentation: documentation, sourceRange: sourceRange)
        }

        func declaration<Node: SymbolDeclProtocol>(for node: Node) -> [Token] {
            let highlighter = SwiftSyntaxHighlighter(using: Xcode.self)
            _ = highlighter.visitAny(Syntax(node.declaration))
            return highlighter.tokens
        }

        func push(_ symbol: Symbol?) {
            guard let symbol = symbol else { return }
            visitedSymbols.append(symbol)

            switch symbol.api {
            case is Class,
                 is Enumeration,
                 is Protocol,
                 is Structure:
                context.append(symbol)
            default:
                return
            }
        }

        func push(_ extension: Extension) {
            context.append(`extension`)
        }

        func push(_ condition: CompilationCondition) {
            context.append(condition)
        }

        func push(_ import: Import) {
            visitedImports.append(`import`)
        }

        @discardableResult
        func pop() -> Contextual? {
            return context.popLast()
        }

        // MARK: - SyntaxVisitor

        override func visit(_ node: AssociatedtypeDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(AssociatedType.self, node))
            return .skipChildren
        }

        override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Class.self, node))
            return .visitChildren
        }

        override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Enumeration.self, node))
            return .visitChildren
        }

        override func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
            let cases = node.elements.compactMap { element in
                Enumeration.Case(element.withRawValue(nil))
            }

            for `case` in cases {
                push(symbol(node, api: `case`))
            }

            return .skipChildren
        }

        override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
            push(Extension(node))
            return .visitChildren
        }

        override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Function.self, node))
            return .skipChildren
        }

        override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
            return .visitChildren
        }

        override func visit(_ node: IfConfigClauseSyntax) -> SyntaxVisitorContinueKind {
            assert(node.parent?.is(IfConfigClauseListSyntax.self) == true)
            assert(node.parent?.parent?.is(IfConfigDeclSyntax.self) == true)

            let block = ConditionalCompilationBlock(node.parent!.parent!.as(IfConfigDeclSyntax.self)!)
            let branch = ConditionalCompilationBlock.Branch(node)
            push(CompilationCondition(block: block, branch: branch))

            return .visitChildren
        }

        override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
            push(Import(node))
            return .skipChildren
        }

        override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Initializer.self, node))
            return .skipChildren
        }

        override func visit(_ node: OperatorDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Operator.self, node))
            return .skipChildren
        }

        override func visit(_ node: PrecedenceGroupDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(PrecedenceGroup.self, node))
            return .skipChildren
        }

        override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Protocol.self, node))
            return .visitChildren
        }

        override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Subscript.self, node))
            return .skipChildren
        }

        override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Structure.self, node))
            return .visitChildren
        }

        override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
            push(symbol(Typealias.self, node))
            return .skipChildren
        }

        override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
            let variables = node.bindings.compactMap { Variable($0) }
            for variable in variables {
                push(symbol(node, api: variable))
            }
            
            return .skipChildren
        }

        // MARK: -

        override func visitPost(_ node: ClassDeclSyntax) {
            let context = pop()
            assert((context as? Symbol)?.api is Class)
        }

        override func visitPost(_ node: EnumDeclSyntax) {
            let context = pop()
            assert((context as? Symbol)?.api is Enumeration)
        }

        override func visitPost(_ node: ExtensionDeclSyntax) {
            let context = pop()
            assert(context is Extension)
        }

        override func visitPost(_ node: IfConfigClauseSyntax) {
            let context = pop()
            assert(context is CompilationCondition)
        }

        override func visitPost(_ node: ProtocolDeclSyntax) {
            let context = pop()
            assert((context as? Symbol)?.api is Protocol)
        }

        override func visitPost(_ node: StructDeclSyntax) {
            let context = pop()
            assert((context as? Symbol)?.api is Structure)
        }
    }
}
