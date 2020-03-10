import Foundation

func temporaryFile(path: String? = nil, contents: String) throws -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo().globallyUniqueString)
    try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o766])

    let path = path ?? ProcessInfo().globallyUniqueString
    let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(path)

    try contents.data(using: .utf8)?.write(to: temporaryFileURL)

    return temporaryFileURL
}
