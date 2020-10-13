import XCTest

final class DiagramSubcommandTests: XCTestCase {
    func testStandardOutput() throws {
        let command = Bundle.productsDirectory.appendingPathComponent("swift-doc")

        let outputDirectory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: outputDirectory) }

        try Process.run(command: command,
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
