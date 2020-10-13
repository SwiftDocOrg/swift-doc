import SwiftSemantics

public struct Identifier: Hashable {
    public let pathComponents: [String]
    public let name: String
    public let checksum: String

    public init(symbol: Symbol) {
        self.pathComponents = symbol.context.compactMap {
            ($0 as? Symbol)?.name ?? ($0 as? Extension)?.extendedType
        }

        self.name = {
            switch symbol.api {
            case let function as Function where function.isOperator:
                var components = symbol.api.nonAccessModifiers.map { $0.name }
                if components.isEmpty {
                    components.append("infix")
                }

                components.append(function.identifier)
                return components.joined(separator: " ")
            case let `operator` as Operator:
                var components = symbol.api.nonAccessModifiers.map { $0.name }
                if components.isEmpty {
                    components.append("infix")
                }

                components.append(`operator`.name)
                return components.joined(separator: " ")
            default:
                return symbol.api.name
            }
        }()

        var hasher = SipHasher()
        var declaration = "\(symbol.api)"
        print(declaration)
        withUnsafeBytes(of: &declaration) { hasher.append($0) }
        let hashValue = hasher.finalize()

        self.checksum = String(UInt(bitPattern: hashValue), radix: 32, uppercase: false)
        print(checksum)
    }

    public var escaped: String {
        description.escaped
    }

    public func matches(_ string: String) -> Bool {
        (pathComponents + CollectionOfOne(name)).reversed().starts(with: string.split(separator: ".").map { String($0) }.reversed())
    }
}

// MARK: - CustomStringConvertible

extension Identifier: CustomStringConvertible {
    public var description: String {
        (pathComponents + CollectionOfOne(name)).joined(separator: ".")
    }
}

// MARK: -

fileprivate let replacements: [Character: String] = [
    "-": "minus",
    ".": "dot",
    "!": "bang",
    "?": "quest",
    "*": "star",
    "/": "slash",
    "&": "amp",
    "%": "percent",
    "^": "caret",
    "+": "plus",
    "<": "lt",
    "=": "equals",
    ">": "gt",
    "|": "bar",
    "~": "tilde"
]

fileprivate extension String {
    var escaped: String {
        zip(indices, self).reduce(into: "") { (result, element) in
            let (cursor, character) = element
            if let replacement = replacements[character] {
                result.append(contentsOf: replacement)
                if cursor != index(before: endIndex) {
                    result.append("-")
                }
            } else if character == " " {
                result.append("-")
            } else if !character.isPunctuation,
                        !character.isWhitespace
            {
                result.append(character)
            }
        }
    }
}
