import Foundation
import SwiftDoc

fileprivate func temporaryFile(path: String? = nil, contents: String) throws -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
    try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)

    let path = path ?? ProcessInfo.processInfo.globallyUniqueString
    let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(path)

    try contents.data(using: .utf8)?.write(to: temporaryFileURL)

    return temporaryFileURL
}

extension SourceFile: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        let url = try! temporaryFile(contents: value)
        try! self.init(file: url, relativeTo: url.deletingLastPathComponent())
    }
}
