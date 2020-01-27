import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import CommonMark
import struct SwiftSemantics.Protocol

protocol Page {
    var body: Document { get }
}

extension Page {
    func write(to url: URL) throws {
        let data = body.render(format: .commonmark).data(using: .utf8)
        try data?.write(to: url)
        try FileManager.default.setAttributes([.posixPermissions: 0o744], ofItemAtPath: url.path)
    }
}

func path(for identifier: CustomStringConvertible) -> String {
    return "\(identifier)".replacingOccurrences(of: ".", with: "_")
}
