import Foundation
import SwiftDoc

class Environment {
    var origin: URL?
    var commit: String?

    func sourceURL(for symbol: Symbol) -> URL? {
        guard let origin = origin,
              let commit = commit,
              let file = symbol.sourceLocation?.file
        else { return nil}

        guard origin.host == "github.com" else { return nil }

        let url = origin.appendingPathComponent("blob").appendingPathComponent(commit).appendingPathComponent(file)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        if let sourceRange = symbol.sourceRange,
           let startLine = sourceRange.start.line
        {
            if let endLine = sourceRange.end.line {
                components?.fragment = "L\(startLine)-L\(endLine)"
            } else {
                components?.fragment = "L\(startLine)"
            }
        }

        return components?.url
    }
}
