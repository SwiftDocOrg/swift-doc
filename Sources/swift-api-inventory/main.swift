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
            // TODO: Add special behavior for Package.swift manifests
            var sourceFiles: [SourceFile] = []
            for path in inputs {
                let directory = URL(fileURLWithPath: path)
                guard let directoryEnumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else { continue }
                for case let url as URL in directoryEnumerator {
                    var isDirectory: ObjCBool = false
                    guard url.pathExtension == "swift",
                        fileManager.isReadableFile(atPath: url.path),
                        fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
                        isDirectory.boolValue == false
                    else { continue }
                    sourceFiles.append(try SourceFile(file: url, relativeTo: directory))
                }
            }

            let module = Module(sourceFiles: sourceFiles)
            print(inventory(of: module).joined(separator: "\n"), to: &standardOutput)
        } catch {
            print("Error: \(error)", to: &standardError)
            exit(EXIT_FAILURE)
        }
}).run()
