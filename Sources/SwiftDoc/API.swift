import SwiftSemantics

public protocol API: Declaration {
    var attributes: [Attribute] { get }
    var modifiers: [Modifier] { get }
    var name: String { get }
    var keyword: String { get }
}

// MARK: -

extension API {
    public var nonAccessModifiers: [Modifier] {
        return modifiers.filter { modifier in
            switch modifier.name {
            case "private", "fileprivate", "internal", "public", "open":
                return false
            default:
                return true
            }
        }
    }
}

// MARK: -

extension AssociatedType: API {}
extension Class: API {}
extension Enumeration: API {}
extension Enumeration.Case: API {}

extension Function: API {
    public var name: String {
        if self.isOperator {
            return identifier
        } else {
            return "\(identifier)(\(signature.input.map { ($0.firstName ?? "_") + ":" }.joined()))"
        }
    }
}

extension Initializer: API {
    public var name: String {
        return "\(keyword)\(optional ? "?": "")(\(parameters.map { ($0.firstName ?? "_") + ":" }.joined()))"
    }
}

extension Operator: API {}
extension PrecedenceGroup: API {}
extension Protocol: API {}

extension Structure: API {}

extension Subscript: API {
    public var name: String {
        return "\(keyword)(\(indices.map { ($0.firstName ?? "_") + ":" }.joined()))"
    }
}

extension Typealias: API {}
extension Variable: API {}
