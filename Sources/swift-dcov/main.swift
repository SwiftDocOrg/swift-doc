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
            let report = Report(module: module)
            let encoder = JSONEncoder()
            let data = try encoder.encode(report)

            print(String(data: data, encoding: .utf8)!, to: &standardOutput)
        } catch {
            print("Error: \(error)", to: &standardError)
            exit(EXIT_FAILURE)
        }
}).run()
