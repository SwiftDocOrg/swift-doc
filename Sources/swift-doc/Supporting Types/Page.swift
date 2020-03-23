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

extension Page {
    func write(to url: URL, format: SwiftDoc.Generate.Format) throws {
        let data: Data?
        switch format {
        case .commonmark:
            data = document.render(format: .commonmark).data(using: .utf8)
        case .html:
            data = layout(self).description.data(using: .utf8)
        }

        let fileManager = FileManager.default
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: [.posixPermissions: 0o744])

        try data?.write(to: url)
        try fileManager.setAttributes([.posixPermissions: 0o744], ofItemAtPath: url.path)
    }
}

func path(for symbol: Symbol) -> String {
    return path(for: symbol.id.description)
}

func path(for identifier: CustomStringConvertible) -> String {
    return "\(identifier)".replacingOccurrences(of: ".", with: "_")
}
