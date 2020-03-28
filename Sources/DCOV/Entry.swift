public struct Entry: Codable {
    public let name: String
    public let type: String
    public let documented: Bool
    public let file: String?
    public let line: Int?
    public let column: Int?

    public init(name: String, type: String, documented: Bool, file: String?, line: Int?, column: Int?) {
        self.name = name
        self.type = type
        self.documented = documented
        self.file = file
        self.line = line
        self.column = column
    }
}

// MARK: -

extension Array where Element == Entry {
    var ratio: Ratio {
        let hits = filter { $0.documented }.count
        return Ratio(hits: hits, misses: count - hits)
    }
}
