import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol
import CommonMark
import HypertextLiteral

protocol Page: HypertextLiteralConvertible {
    var module: Module { get }
    var baseURL: String { get }
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
            var text = document.render(format: .commonmark)
            // Insert U+200B ZERO WIDTH SPACE
            // to prevent colon sequences from being interpreted as
            // emoji shortcodes (without wrapping with code element).
            // See: https://docs.github.com/en/github/writing-on-github/basic-writing-and-formatting-syntax#using-emoji
            text = text.replacingOccurrences(of: ":", with: ":\u{200B}")
            data = text.data(using: .utf8)
        case .html:
            data = layout(self).description.data(using: .utf8)
        }

        guard let filedata = data else { return }

        try writeFile(filedata, to: url)
    }
}

func writeFile(_ data: Data, to url: URL) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
}
