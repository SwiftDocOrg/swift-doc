import SwiftMarkup
import SwiftSyntax
import SwiftSemantics

public final class Symbol {
    public typealias ID = Identifier

    public let declaration: API
    public let context: [Contextual]
    public let documentation: Documentation?
    public let sourceLocation: SourceLocation?

    public private(set) lazy var `extension`: Extension? = context.compactMap { $0 as? Extension }.first
    public private(set) lazy var conditions: [CompilationCondition] = context.compactMap { $0 as? CompilationCondition }

    init(declaration: API, context: [Contextual], documentation: Documentation?, sourceLocation: SourceLocation?) {
        self.declaration = declaration
        self.context = context
        self.documentation = documentation
        self.sourceLocation = sourceLocation
    }

    public var name: String {
        return declaration.name
    }

    public private(set) lazy var id: ID = {
        Identifier(pathComponents: context.compactMap {
            ($0 as? Symbol)?.name ?? ($0 as? Extension)?.extendedType
        }, name: name)
    }()

    public var isPublic: Bool {
        if declaration.modifiers.contains(where: { $0.name == "public" || $0.name == "open" }) {
            return true
        }

        if let `extension` = context.compactMap({ $0 as? Extension }).first,
            `extension`.modifiers.contains(where: { $0.name == "public" })
        {
            return true
        }

        if declaration is Enumeration.Case,
            let enumeration = context.compactMap({ $0 as? Enumeration }).last,
            enumeration.modifiers.contains(where: { $0.name == "public" }) {
            return true
        }

        return false
    }

    public var isDocumented: Bool {
        return documentation?.isEmpty == false
    }
}

// MARK: - Equatable

extension Symbol: Equatable {
    public static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        guard lhs.documentation == rhs.documentation,
            lhs.sourceLocation == rhs.sourceLocation
            else { return false }

        guard lhs.context.count == rhs.context.count else { return false}
        for (lc, rc) in zip(lhs.context, rhs.context) {
            switch (lc, rc) {
            case let (ls, rs) as (Symbol, Symbol) where ls == rs:
                continue
            case let (ls, rs) as (Extension, Extension) where ls == rs:
                continue
            case let (ls, rs) as (CompilationCondition, CompilationCondition) where ls == rs:
                continue
            default:
                return false
            }
        }

        switch (lhs.declaration, rhs.declaration) {
        case let (ls, rs) as (AssociatedType, AssociatedType):
            return ls == rs
        case let (ls, rs) as (Class, Class):
            return ls == rs
        case let (ls, rs) as (Enumeration, Enumeration):
            return ls == rs
        case let (ls, rs) as (Enumeration.Case, Enumeration.Case):
            return ls == rs
        case let (ls, rs) as (Function, Function):
            return ls == rs
        case let (ls, rs) as (Initializer, Initializer):
            return ls == rs
        case let (ls, rs) as (Operator, Operator):
            return ls == rs
        case let (ls, rs) as (PrecedenceGroup, PrecedenceGroup):
            return ls == rs
        case let (ls, rs) as (Protocol, Protocol):
            return ls == rs
        case let (ls, rs) as (Structure, Structure):
            return ls == rs
        case let (ls, rs) as (Subscript, Subscript):
            return ls == rs
        case let (ls, rs) as (Typealias, Typealias):
            return ls == rs
        case let (ls, rs) as (Variable, Variable):
            return ls == rs
        case let (ls, rs) as (Unknown, Unknown):
            return ls == rs
        default:
            return false
        }
    }
}

// MARK: - Comparable

extension Symbol: Comparable {
    public static func < (lhs: Symbol, rhs: Symbol) -> Bool {
        return lhs.name < rhs.name
    }
}

// MARK: - Hashable

extension Symbol: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(documentation)
        hasher.combine(sourceLocation)
        switch declaration {
        case let api as AssociatedType:
            hasher.combine(api)
        case let api as Class:
            hasher.combine(api)
        case let api as Enumeration:
            hasher.combine(api)
        case let api as Enumeration.Case:
            hasher.combine(api)
        case let api as Function:
            hasher.combine(api)
        case let api as Initializer:
            hasher.combine(api)
        case let api as Operator:
            hasher.combine(api)
        case let api as PrecedenceGroup:
            hasher.combine(api)
        case let api as Protocol:
            hasher.combine(api)
        case let api as Structure:
            hasher.combine(api)
        case let api as Subscript:
            hasher.combine(api)
        case let api as Typealias:
            hasher.combine(api)
        case let api as Variable:
            hasher.combine(api)
        case let api as Unknown:
            hasher.combine(api)
        default:
            break
        }
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
        case unknown
    }

    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let declaration: API
        if container.contains(.associatedType) {
            declaration = try container.decode(AssociatedType.self, forKey: .associatedType)
        } else if container.contains(.`case`) {
            declaration = try container.decode(Enumeration.Case.self, forKey: .case)
        } else if container.contains(.`class`) {
            declaration = try container.decode(Class.self, forKey: .class)
        } else if container.contains(.enumeration) {
            declaration = try container.decode(Enumeration.self, forKey: .enumeration)
        } else if container.contains(.function) {
            declaration = try container.decode(Function.self, forKey: .function)
        } else if container.contains(.initializer) {
            declaration = try container.decode(Initializer.self, forKey: .initializer)
        } else if container.contains(.`operator`) {
            declaration = try container.decode(Operator.self, forKey: .operator)
        } else if container.contains(.precedenceGroup) {
            declaration = try container.decode(PrecedenceGroup.self, forKey: .precedenceGroup)
        } else if container.contains(.`protocol`) {
            declaration = try container.decode(Protocol.self, forKey: .protocol)
        } else if container.contains(.structure) {
            declaration = try container.decode(Structure.self, forKey: .structure)
        } else if container.contains(.`subscript`) {
            declaration = try container.decode(Subscript.self, forKey: .subscript)
        } else if container.contains(.`typealias`) {
            declaration = try container.decode(Typealias.self, forKey: .typealias)
        } else if container.contains(.variable) {
            declaration = try container.decode(Variable.self, forKey: .variable)
        } else if container.contains(.unknown) {
            declaration = try container.decode(Unknown.self, forKey: .variable)
        } else {
            let context = DecodingError.Context(codingPath: container.codingPath, debugDescription: "missing declaration")
            throw DecodingError.dataCorrupted(context)
        }

        let documentation = try container.decode(Documentation.self, forKey: .documentation)
        let sourceLocation = try container.decode(SourceLocation.self, forKey: .sourceLocation)

        self.init(declaration: declaration, context: [] /* TODO */, documentation: documentation, sourceLocation: sourceLocation)
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
        } else if let declaration = declaration as? Unknown {
            try container.encode(declaration, forKey: .unknown)
        } else  {
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "unhandled declaration type")
            throw EncodingError.invalidValue(declaration, context)
        }

        try container.encode(documentation, forKey: .documentation)
        try container.encode(sourceLocation, forKey: .sourceLocation)
    }
}
