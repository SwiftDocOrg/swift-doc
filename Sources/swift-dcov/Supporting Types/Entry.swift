import SwiftDoc

struct Entry {
    let symbol: Symbol

    init(_ symbol: Symbol) {
        self.symbol = symbol
    }
}

// MARK: - Encodable

extension Entry: Encodable {
    private enum CodingKeys: String, CodingKey {
       case name
       case type
       case documented
       case file
       case line
       case column
   }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(symbol.id.description, forKey: .name)
        try container.encode(String(describing: type(of: symbol.declaration)), forKey: .type)
        try container.encode(symbol.isDocumented, forKey: .documented)
        try container.encodeIfPresent(symbol.sourceLocation?.file, forKey: .file)
        try container.encodeIfPresent(symbol.sourceLocation?.line, forKey: .line)
        try container.encodeIfPresent(symbol.sourceLocation?.column, forKey: .column)
    }
}

