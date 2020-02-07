public struct Identifier: Hashable {
    public let pathComponents: [String]
    public let name: String

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
