import XCTest

final class GenerateSubcommandTests: XCTestCase {
    func testCommonMark() throws {
        let outputDirectory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: outputDirectory) }

        try Process.run(command: swiftDocCommand,
                        arguments: [
                            "generate",
                            "--module-name", "SwiftDoc",
                            "--format", "commonmark",
                            "--output", outputDirectory.path,
                            "."
                        ]
        ) { result in
            XCTAssertEqual(result.terminationStatus, EXIT_SUCCESS)
            XCTAssertEqual(result.output, "")
            XCTAssertEqual(result.error, "")

            do {
                let commonmark = try String(contentsOf: outputDirectory.appendingPathComponent("Home.md"))
                XCTAssertTrue(commonmark.contains("# Types"))
            }

            do {
                let commonmark = try String(contentsOf: outputDirectory.appendingPathComponent("_Sidebar.md"))
                XCTAssertTrue(commonmark.contains("<summary>Types</summary>"))
            }

            do {
                let commonmark = try String(contentsOf: outputDirectory.appendingPathComponent("_Footer.md"))
                XCTAssertTrue(commonmark.contains("[swift-doc](https://github.com/SwiftDocOrg/swift-doc)"))
            }

            do {
                let contents = try FileManager.default.contentsOfDirectory(at: outputDirectory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
                let subdirectories = try contents.filter { try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true }
                XCTAssertEqual(subdirectories.count, 0, "output should not contain any subdirectories")
            }
        }
    }

    func testHTML() throws {
        let outputDirectory = try temporaryDirectory()

        defer { try? FileManager.default.removeItem(at: outputDirectory) }
        try Process.run(command: swiftDocCommand,
                        arguments: [
                            "generate",
                            "--module-name", "SwiftDoc",
                            "--format", "html",
                            "--output", outputDirectory.path,
                            "."
                        ]
        ) { result in
            XCTAssertEqual(result.terminationStatus, EXIT_SUCCESS)
            XCTAssertEqual(result.output, "")
            XCTAssertEqual(result.error, "")

            do {
                let html = try String(contentsOf: outputDirectory.appendingPathComponent("index.html"))
                XCTAssertTrue(html.contains("<!DOCTYPE html>"))
            }

            do {
                let css = try String(contentsOf: outputDirectory.appendingPathComponent("all.css"))
                XCTAssertTrue(css.contains(":root"))
            }

            do {
                let contents = try FileManager.default.contentsOfDirectory(at: outputDirectory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
                let subdirectories = try contents.filter { try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true }
                                                 .filter { FileManager.default.fileExists(atPath: $0.appendingPathComponent("index.html").path) }
                XCTAssertGreaterThanOrEqual(subdirectories.count, 1, "output should contain one or more subdirectories containing index.html")
            }
        }
    }
}
