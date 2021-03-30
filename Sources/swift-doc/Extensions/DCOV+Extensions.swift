import DCOV
import SwiftDoc
import SwiftSemantics

extension Entry {
    public init(_ symbol: Symbol) {
        let name = symbol.id.description
        let type = String(describing: Swift.type(of: symbol.api))
        let documented = symbol.isDocumented
        let file = symbol.sourceRange?.start.file
        let line = symbol.sourceRange?.start.line
        let column = symbol.sourceRange?.start.column

        self.init(name: name, type: type, documented: documented, file: file, line: line, column: column)
    }
}

// MARK: -

extension Report {
    public init(module: Module, symbolFilter: (Symbol) -> Bool) {
        let entries = module.sourceFiles
                            .flatMap { $0.symbols }
                            .filter(symbolFilter)
                            .map { Entry($0) }

        self.init(entries: entries)
    }
}
