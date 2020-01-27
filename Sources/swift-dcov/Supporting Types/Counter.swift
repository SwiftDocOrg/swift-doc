struct Counter {
    private(set) var hits: Int = 0
    private(set) var misses: Int = 0

    var total: Int { hits + misses }

    var percentage: Double {
        Double(hits) / Double(total) * 100.0
    }

    init(hits: Int = 0, misses: Int = 0) {
        self.hits = max(0, hits)
        self.misses = max(0, misses)
    }

    mutating func hit() {
        hits += 1
    }

    mutating func miss() {
        misses += 1
    }

    static func + (lhs: Counter, rhs: Counter) -> Counter {
        return Counter(hits: lhs.hits + rhs.hits, misses: lhs.misses + rhs.misses)
    }
}

// MARK: - Encodable

extension Counter: Encodable {
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
