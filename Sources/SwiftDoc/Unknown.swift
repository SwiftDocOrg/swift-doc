import SwiftSemantics

public struct Unknown: Hashable, Codable {
    public let name: String
}

// MARK: - API

extension Unknown: API {
    public var attributes: [Attribute] { return [] }
    public var modifiers: [Modifier] { return [] }
    public var keyword: String { return "" }
}
