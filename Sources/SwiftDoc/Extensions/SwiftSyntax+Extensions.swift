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

extension Syntax {
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

fileprivate extension String {
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
