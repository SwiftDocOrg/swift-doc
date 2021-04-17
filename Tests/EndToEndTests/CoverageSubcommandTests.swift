import XCTest

final class CoverageSubcommandTests: XCTestCase {
    func testStandardOutput() throws {
        let outputDirectory = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: outputDirectory) }

        try Process.run(command: swiftDocCommand,
                        arguments: [
                            "coverage",
                            "Sources"
                        ]
        ) { result in
            XCTAssertEqual(result.terminationStatus, EXIT_SUCCESS)
            XCTAssertEqual(result.output?.starts(with: "Total"), true)
            XCTAssertEqual(result.error, "")
        }
    }

    func testFileOutput() throws {
        let outputDirectory = try temporaryDirectory()
        let outputFile = outputDirectory.appendingPathComponent("report.json")
        defer { try? FileManager.default.removeItem(at: outputDirectory) }

        try Process.run(command: swiftDocCommand,
                        arguments: [
                            "coverage",
                            "--output", outputFile.path,
                            "Sources"
                        ]
        ) { result in
            XCTAssertEqual(result.terminationStatus, EXIT_SUCCESS)
            XCTAssertEqual(result.output, "")
            XCTAssertEqual(result.error, "")

            do {
                let data = try Data(contentsOf: outputFile)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                XCTAssertEqual(json?["type"] as? String, "org.dcov.report.json.export")
            }
        }
    }
}
