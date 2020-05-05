import SwiftDoc

protocol Generator {
    static func generate(for module: Module, with options: SwiftDoc.Generate.Options) throws
}
