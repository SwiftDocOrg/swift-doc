public struct Report {
    public static let version: String = "0.0.1"
    public static let type: String = "org.dcov.report.json.export"

    public var entries: [Entry]

    public var coverageBySourceFile: [String: Ratio] {
        return Dictionary(grouping: entries) { $0.file ?? "" }.compactMapValues { $0.ratio }
    }

    public var totals: Ratio  {
        return coverageBySourceFile.values.reduce(Ratio(), +)
    }

    public init(entries: [Entry]) {
        self.entries = entries
    }
}

// MARK: - Encodable

extension Report: Encodable {
    private enum CodingKeys: String, CodingKey {
        case version
        case type
        case data
    }

    private enum NestedCodingKeys: String, CodingKey {
        case totals
        case symbols
        case files
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Report.version, forKey: .version)
        try container.encode(Report.type, forKey: .type)

        var nestedContainer = container.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .data)
        try nestedContainer.encode(totals, forKey: .totals)
        try nestedContainer.encode(entries, forKey: .symbols)
        try nestedContainer.encode(coverageBySourceFile, forKey: .files)
    }
}
