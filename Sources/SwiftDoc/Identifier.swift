public struct Identifier: Hashable {
    public let context: [String]
    public let name: String
    public let pathComponents: [String]

    public init(context: [String], name: String) {
        self.context = context
        self.name = name
        self.pathComponents = context + CollectionOfOne(name)
    }

    public func matches(_ string: String) -> Bool {
        return matches(string.split(separator: "."))
    }

    public func matches(_ pathComponents: [Substring]) -> Bool {
        return matches(pathComponents.map(String.init))
    }

    public func matches(_ pathComponents: [String]) -> Bool {
        return self.pathComponents.ends(with: pathComponents)
    }
}

// MARK: - CustomStringConvertible

extension Identifier: CustomStringConvertible {
    public var description: String {
        pathComponents.joined(separator: ".")
    }
}

fileprivate extension Array {
    func ends<PossibleSuffix>(with possibleSuffix: PossibleSuffix) -> Bool
        where PossibleSuffix : Sequence,
              Self.Element == PossibleSuffix.Element,
              Self.Element: Equatable
    {
        reversed().starts(with: possibleSuffix)
    }
}
