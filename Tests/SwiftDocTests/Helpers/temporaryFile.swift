import Foundation

func temporaryFile(path: String? = nil, contents: String) throws -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
    try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)

    let path = path ?? ProcessInfo.processInfo.globallyUniqueString
    let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(path)

    try contents.data(using: .utf8)?.write(to: temporaryFileURL)

    return temporaryFileURL
}
