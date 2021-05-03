import XCTest

final class DiagramSubcommandTests: XCTestCase {
    func testStandardOutput() throws {
        let outputDirectory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: outputDirectory) }

        try Process.run(command: swiftDocCommand,
                        arguments: [
                            "diagram",
                            "Sources"
                        ]
        ) { result in
            XCTAssertEqual(result.terminationStatus, EXIT_SUCCESS)
            XCTAssertEqual(result.output?.starts(with: "digraph {"), true)
            XCTAssertEqual(result.error, "")
        }
    }
}
