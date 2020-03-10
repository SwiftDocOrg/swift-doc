public struct Ratio {
    public private(set) var hits: Int = 0
    public private(set) var misses: Int = 0

    public var total: Int { hits + misses }

    public var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(hits) / Double(total) * 100.0
    }

    public init(hits: Int = 0, misses: Int = 0) {
        self.hits = max(0, hits)
        self.misses = max(0, misses)
    }

    public mutating func hit() {
        hits += 1
    }

    public mutating func miss() {
        misses += 1
    }

    public static func + (lhs: Ratio, rhs: Ratio) -> Ratio {
        return Ratio(hits: lhs.hits + rhs.hits, misses: lhs.misses + rhs.misses)
    }
}

// MARK: - Encodable

extension Ratio: Encodable {
    private enum CodingKeys: String, CodingKey {
        case count
        case documented
        case percent
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hits, forKey: .documented)
        try container.encode(total, forKey: .count)
        try container.encode(percentage, forKey: .percent)
    }
}
