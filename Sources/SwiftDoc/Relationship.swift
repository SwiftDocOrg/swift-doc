import SwiftSemantics

public struct Relationship: Hashable, Codable {
    public enum Predicate: String, Hashable, Codable {
        case memberOf
        case conformsTo
        case inheritsFrom
        case defaultImplementationOf
        case overrides
        case requirementOf
        case optionalRequirementOf
    }

    public let subject: Symbol
    public let predicate: Predicate
    public let object: Symbol
}

// MARK: - CustomStringConvertible

extension Relationship: CustomStringConvertible {
    public var description: String {
        return "\(subject.id) \(predicate) \(object.id)"//" when \(conditions)"
    }
}
