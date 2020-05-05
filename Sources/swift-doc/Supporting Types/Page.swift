import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol
import CommonMark
import HypertextLiteral

protocol Page: HypertextLiteralConvertible {
    var module: Module { get }
    var title: String { get }
    var document: CommonMark.Document { get }
    var html: HypertextLiteral.HTML { get }
}

extension Page {
    var module: Module { fatalError("unimplemented") }
    var title: String { fatalError("unimplemented") }
}

func path(for symbol: Symbol) -> String {
    return path(for: symbol.id.description)
}

func path(for identifier: CustomStringConvertible) -> String {
    return "\(identifier)".replacingOccurrences(of: ".", with: "_")
}

func writeFile(_ data: Data, to url: URL) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o744])

    try data.write(to: url)
    try fileManager.setAttributes([.posixPermissions: 0o744], ofItemAtPath: url.path)
}
