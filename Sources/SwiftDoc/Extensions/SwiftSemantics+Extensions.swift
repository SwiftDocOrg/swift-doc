import SwiftSemantics

public protocol API: Declaration {
    var attributes: [Attribute] { get }
    var keyword: String { get }
    var context: String? { get }
    var name: String { get }
    var isPublic: Bool { get }
}

extension API {
    public var qualifiedName: String {
        guard let context = context else { return name }
        return "\(context).\(name)"
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
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
        default:
            assertionFailure("unhandled type: \(self)")
            return
        }
    }
}

public func ==(lhs: API, rhs: API) -> Bool {
    switch (lhs, rhs) {
    case let (lhs, rhs) as (AssociatedType, AssociatedType):
        return lhs == rhs
    case let (lhs, rhs) as (Class, Class):
        return lhs == rhs
    case let (lhs, rhs) as (Enumeration, Enumeration):
        return lhs == rhs
    case let (lhs, rhs) as (Enumeration.Case, Enumeration.Case):
        return lhs == rhs
    case let (lhs, rhs) as (Function, Function):
        return lhs == rhs
    case let (lhs, rhs) as (Initializer, Initializer):
        return lhs == rhs
    case let (lhs, rhs) as (Operator, Operator):
        return lhs == rhs
    case let (lhs, rhs) as (PrecedenceGroup, PrecedenceGroup):
        return lhs == rhs
    case let (lhs, rhs) as (Protocol, Protocol):
        return lhs == rhs
    case let (lhs, rhs) as (Structure, Structure):
        return lhs == rhs
    case let (lhs, rhs) as (Subscript, Subscript):
        return lhs == rhs
    case let (lhs, rhs) as (Typealias, Typealias):
        return lhs == rhs
    case let (lhs, rhs) as (Variable, Variable):
        return lhs == rhs
    default:
        return false
    }
}

extension AssociatedType: API {}

extension Class: API {}

extension Enumeration: API {}

extension Enumeration.Case: API {
    public var isPublic: Bool { return true }
}

extension Function: API {
    public var name: String {
        "\(identifier)(\(signature.input.map { ($0.firstName ?? "_") + ":" }.joined()))"
    }
}

extension Initializer: API {
    public var name: String {
        "\(keyword)\(optional ? "?": "")(\(parameters.map { ($0.firstName ?? "_") + ":" }.joined()))"
    }
}

extension Operator: API {
    public var isPublic: Bool { return true }
}

extension PrecedenceGroup: API {
    public var context: String? { return nil }
}

extension Protocol: API {
    public var context: String? { return nil }
}

extension Structure: API {}

extension Subscript: API {
    public var name: String {
        "\(keyword)(\(indices.map { ($0.firstName ?? "_") + ":" }.joined()))"
    }
}

extension Typealias: API {}

extension Variable: API {}

// MARK: -

public protocol Modifiable: Declaration {
    var modifiers: [Modifier] { get }
}

extension AssociatedType: Modifiable {}
extension Class: Modifiable {}
extension Enumeration: Modifiable {}
extension Extension: Modifiable {}
extension Function: Modifiable {}
extension Initializer: Modifiable {}
extension PrecedenceGroup: Modifiable {}
extension Protocol: Modifiable {}
extension Structure: Modifiable {}
extension Subscript: Modifiable {}
extension Typealias: Modifiable {}
extension Variable: Modifiable {}

extension Modifiable {
    public var isPublic: Bool {
        return modifiers.contains { $0.name == "public" || $0.name == "open" }
    }
}

// MARK: -

public protocol Type: API {
    var inheritance: [String] { get }
    var name: String { get }
}

extension Class: Type {}
extension Enumeration: Type {}
extension Protocol: Type {}
extension Structure: Type {}
