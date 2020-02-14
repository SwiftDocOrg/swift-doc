import Commander
import Foundation
import SwiftDoc

let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())

let fileManager = FileManager.default

var standardOutput = FileHandle.standardOutput
var standardError = FileHandle.standardError

command(
    Argument<[String]>("inputs", description: "One or more paths to Swift files", validator: { (inputs) -> [String] in
        inputs.filter { path in
            var isDirectory: ObjCBool = false
            return fileManager.fileExists(atPath: path, isDirectory: &isDirectory) || isDirectory.boolValue
        }
    }), { inputs in
        do {
            let module = try Module(paths: inputs)
            print(GraphViz.diagram(of: module), to: &standardOutput)
        } catch {
            print("Error: \(error)", to: &standardError)
            exit(EXIT_FAILURE)
        }
}).run()
