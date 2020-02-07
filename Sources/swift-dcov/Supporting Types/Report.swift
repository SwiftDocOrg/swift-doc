import SwiftMarkup
import SwiftDoc

struct Report {
    static var version: String = "0.0.1"
    static var type: String = "org.swiftdoc.dcov.json.export"

    let entries: [Entry]
    let coverageBySourceFile: [SourceFile: Counter]
    let totals: Counter

    init(module: Module) {
        var coverageBySourceFile: [SourceFile: Counter] = [:]
        var entries: [Entry] = []

        for file in module.sourceFiles {
            for symbol in file.symbols where symbol.isPublic {
                entries.append(Entry(symbol))

                if symbol.isDocumented {
                    coverageBySourceFile[file, default: Counter()].hit()
                } else {
                    coverageBySourceFile[file, default: Counter()].miss()
                }
            }
        }

        self.entries = entries
        self.coverageBySourceFile = coverageBySourceFile
        self.totals = coverageBySourceFile.values.reduce(Counter(), +)
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
        let coverageByFileName = Dictionary(uniqueKeysWithValues: coverageBySourceFile.map { (sourceFile, counter) in
            return (sourceFile.path, counter)
        })
        try nestedContainer.encode(coverageByFileName, forKey: .files)
    }
}
