import SwiftSyntax

extension SourceLocation: Equatable {
    public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        return lhs.file == rhs.file && lhs.offset == rhs.offset
    }
}

extension SourceLocation: Comparable {
    public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
        return lhs.file ?? "" < rhs.file ?? "" || (lhs.file == rhs.file && lhs.offset < rhs.offset)
    }
}

extension SourceLocation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(offset)
    }
}

// MARK: -

extension SourceRange: Equatable {
    public static func == (lhs: SourceRange, rhs: SourceRange) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
}

extension SourceRange: Comparable {
    public static func < (lhs: SourceRange, rhs: SourceRange) -> Bool {
        return lhs.start < rhs.start
    }
}

extension SourceRange: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(end)
    }
}

// MARK: -

protocol SymbolDeclProtocol: SyntaxProtocol {
    var declaration: Syntax { get }
}

extension SymbolDeclProtocol {
    func sourceRange(using converter: SourceLocationConverter) -> SourceRange {
        return SourceRange(start: startLocation(converter: converter), end: endLocation(converter: converter))
    }
}

extension AssociatedtypeDeclSyntax: SymbolDeclProtocol {}
extension ClassDeclSyntax: SymbolDeclProtocol {}
extension EnumDeclSyntax: SymbolDeclProtocol {}
extension EnumCaseDeclSyntax: SymbolDeclProtocol {}
extension FunctionDeclSyntax: SymbolDeclProtocol {}
extension InitializerDeclSyntax: SymbolDeclProtocol {}
extension OperatorDeclSyntax: SymbolDeclProtocol {}
extension PrecedenceGroupDeclSyntax: SymbolDeclProtocol {}
extension ProtocolDeclSyntax: SymbolDeclProtocol {}
extension StructDeclSyntax: SymbolDeclProtocol {}
extension SubscriptDeclSyntax: SymbolDeclProtocol {}
extension TypealiasDeclSyntax: SymbolDeclProtocol {}
extension VariableDeclSyntax: SymbolDeclProtocol {}

extension DeclGroupSyntax {
    var declaration: Syntax {
        Syntax(self.withoutTrailingTrivia()
                    .withoutLeadingTrivia()
                    .withMembers(SyntaxFactory.makeBlankMemberDeclBlock()))
    }
}

extension EnumDeclSyntax {
    var declaration: Syntax {
        Syntax(self.withoutTrailingTrivia()
                    .withoutLeadingTrivia()
                    .withMembers(SyntaxFactory.makeBlankMemberDeclBlock()))
    }
}

extension FunctionDeclSyntax {
    var declaration: Syntax {
        Syntax(self.withoutTrailingTrivia()
                    .withoutLeadingTrivia()
                    .withBody(SyntaxFactory.makeBlankCodeBlock()))
    }
}

extension InitializerDeclSyntax {
    var declaration: Syntax {
        Syntax(self.withoutTrailingTrivia()
                    .withoutLeadingTrivia()
                    .withBody(SyntaxFactory.makeBlankCodeBlock()))
    }
}

extension SubscriptDeclSyntax {
    var declaration: Syntax {
        Syntax(self.withoutTrailingTrivia()
                    .withoutLeadingTrivia()
                    .withAccessor(nil))
    }
}

extension VariableDeclSyntax {
    var declaration: Syntax {
        let bindings = self.bindings.map { binding -> PatternBindingSyntax in
            if let value = binding.initializer?.value,
                value.is(ClosureExprSyntax.self) || value.is(FunctionCallExprSyntax.self)
            {
                return binding.withInitializer(nil)
                              .withAccessor(nil)
            } else {
                return binding.withAccessor(nil)
            }
        }

        return Syntax(self.withoutTrailingTrivia()
                        .withoutLeadingTrivia()
                        .withBindings(SyntaxFactory.makePatternBindingList(bindings)))
    }
}

extension SyntaxProtocol {
    var declaration: Syntax {
        Syntax(self.withoutLeadingTrivia()
                   .withoutTrailingTrivia())
    }
}

// MARK: -

extension SyntaxProtocol {
    var documentation: String? {
        return leadingTrivia?.documentation
    }
}

extension Trivia {
    var documentation: String? {
        let components = compactMap { $0.documentation }
        guard !components.isEmpty else { return nil }
        return components.joined(separator: "\n").unindented
    }
}

fileprivate extension TriviaPiece {
    var documentation: String? {
        switch self {
        case let .docLineComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            return String(comment.suffix(from: startIndex))
        case let .docBlockComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            let endIndex = comment.index(comment.endIndex, offsetBy: -2)
            return String(comment[startIndex ..< endIndex])
        default:
            return nil
        }
    }
}

extension String {
    var unindented: String {
        let lines = split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.count > 1 else { return trimmingCharacters(in: .whitespaces) }

        let indentation = lines.compactMap { $0.firstIndex(where: { !$0.isWhitespace })?.utf16Offset(in: $0) }
            .min() ?? 0

        return lines.map {
            guard $0.count > indentation else { return String($0) }
            return String($0.suffix($0.count - indentation))
        }.joined(separator: "\n")
    }
}
