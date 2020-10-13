import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol
import CommonMark
import HypertextLiteral

protocol Page {
//    var module: Module { get }
//    var generator: Generator { get }
    var title: String { get }
//    var document: CommonMark.Document { get }
//    var html: HypertextLiteral.HTML { get }
}

func writeFile(_ data: Data, to url: URL) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o744])

    try data.write(to: url)
    try fileManager.setAttributes([.posixPermissions: 0o744], ofItemAtPath: url.path)
}


extension Page {
    var symbol: Symbol? { nil }
}
