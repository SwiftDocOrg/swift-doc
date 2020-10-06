import Foundation

extension Process {
    typealias Result = (terminationStatus: Int32, output: String?, error: String?)

    static func run(command executableURL: URL, arguments: [String] = [], completion: (Result) throws -> Void) throws {
        let process = Process()
        if #available(OSX 10.13, *) {
            process.executableURL = executableURL
        } else {
            process.launchPath = executableURL.path
        }
        process.arguments = arguments

        let standardOutput = Pipe()
        process.standardOutput = standardOutput

        let standardError = Pipe()
        process.standardError = standardError

        if #available(OSX 10.13, *) {
          try process.run()
        } else {
          process.launch()
        }
        process.waitUntilExit()

        let output = String(data: standardOutput.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
        let error = String(data: standardError.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)

        try completion((numericCast(process.terminationStatus), output, error))
    }

}
