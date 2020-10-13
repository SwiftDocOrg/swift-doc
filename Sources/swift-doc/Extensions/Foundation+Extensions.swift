import Foundation

extension URLComponents {
    mutating func appendPathComponent(_ component: String) {
        if let _ = scheme, path.isEmpty { path = "/" }

        var pathComponents = path.split(separator: "/")
        pathComponents.append(contentsOf: component.split(separator: "/"))
        path = (scheme == nil ? "" : "/") + pathComponents.joined(separator: "/")
    }
}

extension URL {
    func path(relativeTo another: URL) -> String {
        let pathComponents = self.pathComponents, otherPathComponents = another.pathComponents
        guard pathComponents.starts(with: otherPathComponents) else { return path }
        return pathComponents.suffix(pathComponents.count - otherPathComponents.count).joined(separator: "/")
    }
}
