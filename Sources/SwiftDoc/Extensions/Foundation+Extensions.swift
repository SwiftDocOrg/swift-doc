import Foundation

// MARK: - FileHandle

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        write(data)
    }
}

// MARK: - URL

extension URL {
    public func path(relativeTo another: URL) -> String {
        let pathComponents = self.pathComponents, otherPathComponents = another.pathComponents
        guard pathComponents.starts(with: otherPathComponents) else { return path }
        return pathComponents.suffix(pathComponents.count - otherPathComponents.count).joined(separator: "/")
    }
}
