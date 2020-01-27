import Foundation

extension URL {
    func path(relativeTo another: URL) -> String {
        let pathComponents = self.pathComponents, otherPathComponents = another.pathComponents
        guard pathComponents.starts(with: otherPathComponents) else { return path }
        return pathComponents.suffix(pathComponents.count - otherPathComponents.count).joined(separator: "/")
    }
}
