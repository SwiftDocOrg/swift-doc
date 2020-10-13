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

        guard let filedata = data else { return }

        try writeFile(filedata, to: url)
    }
}

func writeFile(_ data: Data, to url: URL) throws {
    let fileManager = FileManager.default
    try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
}


extension Page {
    var symbol: Symbol? { nil }
}
