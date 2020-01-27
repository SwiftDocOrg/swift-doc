import SwiftMarkup
import SwiftSyntax
import SwiftSemantics

public struct Symbol {
    public let declaration: API
    public let documentation: Documentation
    public let sourceLocation: SourceLocation

    public internal(set) var conditions: [CompilationCondition] = []

    public var name: String {
        switch declaration {
        case let type as Type:
            return type.qualifiedName
        default:
            return declaration.name
        }
    }
}

// MARK: - Equatable

extension Symbol: Equatable {
    public static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        return lhs.documentation == rhs.documentation &&
            lhs.sourceLocation == rhs.sourceLocation &&
            lhs.declaration == rhs.declaration
    }
}

// MARK: - Hashable

extension Symbol: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(documentation)
        hasher.combine(sourceLocation)
        declaration.hash(into: &hasher)
    }
}

// MARK: - Codable

extension Symbol: Codable {
    private enum CodingKeys: String, CodingKey {
        case documentation
        case sourceLocation

        case associatedType
        case `case`
        case `class`
        case enumeration
        case function
        case initializer
        case `operator`
        case precedenceGroup
        case `protocol`
        case structure
        case `subscript`
        case `typealias`
        case variable
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.associatedType) {
            self.declaration = try container.decode(AssociatedType.self, forKey: .associatedType)
        } else if container.contains(.`case`) {
            self.declaration = try container.decode(Enumeration.Case.self, forKey: .case)
        } else if container.contains(.`class`) {
            self.declaration = try container.decode(Class.self, forKey: .class)
        } else if container.contains(.enumeration) {
            self.declaration = try container.decode(Enumeration.self, forKey: .enumeration)
        } else if container.contains(.function) {
            self.declaration = try container.decode(Function.self, forKey: .function)
        } else if container.contains(.initializer) {
            self.declaration = try container.decode(Initializer.self, forKey: .initializer)
        } else if container.contains(.`operator`) {
            self.declaration = try container.decode(Operator.self, forKey: .operator)
        } else if container.contains(.precedenceGroup) {
            self.declaration = try container.decode(PrecedenceGroup.self, forKey: .precedenceGroup)
        } else if container.contains(.`protocol`) {
            self.declaration = try container.decode(Protocol.self, forKey: .protocol)
        } else if container.contains(.structure) {
            self.declaration = try container.decode(Structure.self, forKey: .structure)
        } else if container.contains(.`subscript`) {
            self.declaration = try container.decode(Subscript.self, forKey: .subscript)
        } else if container.contains(.`typealias`) {
            self.declaration = try container.decode(Typealias.self, forKey: .typealias)
        } else if container.contains(.variable) {
            self.declaration = try container.decode(Variable.self, forKey: .variable)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "missing declaration")
            throw DecodingError.dataCorrupted(context)
        }

        self.documentation = try container.decode(Documentation.self, forKey: .documentation)
        self.sourceLocation = try container.decode(SourceLocation.self, forKey: .sourceLocation)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let declaration = declaration as? AssociatedType {
            try container.encode(declaration, forKey: .associatedType)
        } else if let declaration = declaration as? Class {
            try container.encode(declaration, forKey: .class)
        } else if let declaration = declaration as? Enumeration {
            try container.encode(declaration, forKey: .enumeration)
        } else if let declaration = declaration as? Enumeration.Case {
            try container.encode(declaration, forKey: .case)
        } else if let declaration = declaration as? Function {
            try container.encode(declaration, forKey: .function)
        } else if let declaration = declaration as? Initializer {
            try container.encode(declaration, forKey: .initializer)
        } else if let declaration = declaration as? Operator {
            try container.encode(declaration, forKey: .operator)
        } else if let declaration = declaration as? PrecedenceGroup {
            try container.encode(declaration, forKey: .precedenceGroup)
        } else if let declaration = declaration as? Protocol {
            try container.encode(declaration, forKey: .protocol)
        } else if let declaration = declaration as? Structure {
            try container.encode(declaration, forKey: .structure)
        } else if let declaration = declaration as? Subscript {
            try container.encode(declaration, forKey: .subscript)
        } else if let declaration = declaration as? Typealias {
            try container.encode(declaration, forKey: .typealias)
        } else if let declaration = declaration as? Variable {
            try container.encode(declaration, forKey: .variable)
        } else  {
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "unhandled declaration type")
            throw EncodingError.invalidValue(declaration, context)
        }

        try container.encode(documentation, forKey: .documentation)
        try container.encode(sourceLocation, forKey: .sourceLocation)
    }
}
