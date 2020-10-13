import SwiftDoc

protocol Generator {
    var options: SwiftDocCommand.Generate.Options { get }
    func generate(for module: Module) throws
}
