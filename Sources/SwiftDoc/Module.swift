import SwiftSemantics

public struct Module: Codable {
    public let name: String

    public let sourceFiles: [SourceFile]

    public let symbols: [Symbol]

    public let extendedSymbols: [Extension: [Symbol]]

    public var topLevelSymbols: [Symbol] {
        return symbols.filter { $0.declaration.context == nil || $0.declaration is Type }
    }

    public init(name: String = "Anonymous", sourceFiles: [SourceFile]) {
        self.name = name

        self.sourceFiles = sourceFiles

        var symbols: [Symbol] = []
        var extendedSymbols: [Extension: [Symbol]] = [:]

        for sourceFile in sourceFiles {
            symbols.append(contentsOf: sourceFile.symbols)

            for `extension` in sourceFile.extendedSymbols.keys {
                extendedSymbols[`extension`, default: []] += sourceFile.extendedSymbols[`extension`] ?? []
            }
        }

        self.symbols = symbols
        self.extendedSymbols = extendedSymbols
    }

    public func members(of symbol: Symbol) -> [Symbol] {
        guard symbol.declaration is Type else { return [] }
        var members: [Symbol] = symbols.filter { $0.declaration.context == symbol.declaration.qualifiedName }

        let inheritance = [symbol.declaration.qualifiedName] + (self.inheritance(of: symbol) ?? [])
        for `extension` in extendedSymbols.keys where `extension`.genericRequirements.isEmpty {
            if inheritance.contains(`extension`.extendedType) {
                members.append(contentsOf: extendedSymbols[`extension`] ?? [])
            }
        }

        return members
    }

    public func inheritance(of symbol: Symbol) -> [String]? {
        guard let type = symbol.declaration as? Type else { return nil }
        let inheritance = type.inheritance

        var extendedInheritance: Set<String> = []
        for `extension` in extendedSymbols.keys where `extension`.genericRequirements.isEmpty {
            if symbol.declaration.qualifiedName == `extension`.extendedType ||
                inheritance.contains(`extension`.extendedType) ||
                extendedInheritance.contains(`extension`.extendedType)
            {
                extendedInheritance.formUnion(`extension`.inheritance)
            }
        }

        return inheritance + extendedInheritance.sorted()
    }

    public func namesOfTypesConforming(to protocol: Protocol) -> [String] {
        var names: [String] = []

        for symbol in symbols {
            if let type = symbol.declaration as? Type,
                type.inheritance.contains(`protocol`.name)
            {
                names.append(type.qualifiedName)
            }
        }

        for `extension` in extendedSymbols.keys where `extension`.genericRequirements.isEmpty {
            if `extension`.inheritance.contains(`protocol`.name) {
                names.append(`extension`.extendedType)
            }
        }

        return Set(names).sorted()
    }

    public func conditionalCounterparts(of symbol: Symbol) -> [Symbol] {
        return symbols.filter { !$0.conditions.isEmpty && $0.declaration.qualifiedName == symbol.declaration.qualifiedName }
    }

    public func hasDeclaration(named name: String) -> Bool {
        return symbols.contains { $0.declaration.qualifiedName == name }
    }
}
