import DCOV
import SwiftDoc
import SwiftSemantics

extension Entry {
    public init(_ symbol: Symbol) {
        let name = symbol.id.description
        let type = String(describing: Swift.type(of: symbol.api))
        let documented = symbol.isDocumented
        let file = symbol.sourceLocation?.file
        let line = symbol.sourceLocation?.line
        let column = symbol.sourceLocation?.column

        self.init(name: name, type: type, documented: documented, file: file, line: line, column: column)
    }
}

// MARK: -

extension Report {
    public init(module: Module) {
        let entries = module.sourceFiles
                            .flatMap { $0.symbols }
                            .filter { $0.isPublic }
                            .map { Entry($0) }

        self.init(entries: entries)
    }
}
