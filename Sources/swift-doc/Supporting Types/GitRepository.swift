import GitConfig
import Foundation

struct GitRepository {
    var url: URL

    static func discover(at path: String) -> GitRepository? {
        var url = URL(fileURLWithPath: path)
        // TODO recursively enumerate parents?

        if url.lastPathComponent == "Sources" {
            url.deleteLastPathComponent()
        }

        if url.lastPathComponent != ".git" {
            url.appendPathComponent(".git")
        }

        var isDirectory: ObjCBool = false
        guard fileManager.isReadableFile(atPath: url.path),
            fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory),
            isDirectory.boolValue == true
        else { return nil }

        return GitRepository(url: url)
    }

    func showRef() -> String? {
        guard let contents = try? String(contentsOf: url.appendingPathComponent("HEAD")),
              let ref = contents.droppingPrefix("ref: ")?.trimmingCharacters(in: .whitespacesAndNewlines),
              let sha = (try? String(contentsOf: url.appendingPathComponent(ref)))?.trimmingCharacters(in: .whitespacesAndNewlines),
              sha.allSatisfy(\.isHexDigit), sha.count == 40
        else { return nil }

        return sha
    }

    var configuration: Configuration? {
        guard let contents = try? String(contentsOf: url.appendingPathComponent("config")) else { return nil }
        return try? Configuration(contents)
    }
}

fileprivate extension String {
    func droppingPrefix(_ prefix: String) -> String? {
        guard !prefix.isEmpty, hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}
