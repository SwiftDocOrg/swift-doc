import XCTest
import Foundation

/// A class that provides abstractions to write tests for the `generate` subcommand.
///
/// Create a subclass of this class to write test cases for the `generate` subcommand.
/// It provides an API to create source files which should be included in the sources.
/// Then you can generate the documentation.
/// If there's an error while generating the documentation for any of the formats,
/// the test automatically fails.
/// Additionally, it provides APIs to assert validations on the generated documentation.
///
/// ``` swift
/// class TestVisibility: GenerateTestCase {
///     func testClassesVisibility() {
///         sourceFile("Example.swift") {
///             #"""
///             public class PublicClass {}
///
///             class InternalClass {}
///
///             private class PrivateClass {}
///             """#
///         }
///
///         generate(minimumAccessLevel: .internal)
///
///         XCTAssertDocumentationContains(.class("PublicClass"))
///         XCTAssertDocumentationContains(.class("InternalClass"))
///         XCTAssertDocumentationNotContains(.class("PrivateClass"))
///     }
/// }
/// ```
///
/// The tests are end-to-end tests.
/// They use the command-line tool to build the documentation
/// and run the assertions
/// by reading and understanding the created output of the documentation.
class GenerateTestCase: XCTestCase {
    private var sourcesDirectory: URL?

    private var outputs: [GeneratedDocumentation] = []

    /// The output formats which should be generated for this test case.
    /// You can set a new value in `setUp()` if a test should only generate specific formats.
    var testedOutputFormats: [GeneratedDocumentation.Type] = []

    override func setUpWithError() throws {
        try super.setUpWithError()

        sourcesDirectory = try createTemporaryDirectory()

        testedOutputFormats = [GeneratedHTMLDocumentation.self, GeneratedCommonMarkDocumentation.self]
    }

    override func tearDown() {
        super.tearDown()

        if let sourcesDirectory = self.sourcesDirectory {
            try? FileManager.default.removeItem(at: sourcesDirectory)
        }
        for output in outputs {
            try? FileManager.default.removeItem(at: output.directory)
        }
    }

    func sourceFile(_ fileName: String, contents: () -> String, file: StaticString = #filePath, line: UInt = #line) {
        guard let sourcesDirectory = self.sourcesDirectory else {
            return assertionFailure()
        }
        do {
            try contents().write(to: sourcesDirectory.appendingPathComponent(fileName), atomically: true, encoding: .utf8)
        }
        catch let error {
            XCTFail("Could not create source file '\(fileName)' (\(error))", file: file, line: line)
        }
    }

    func generate(minimumAccessLevel: MinimumAccessLevel, file: StaticString = #filePath, line: UInt = #line) {
        for format in testedOutputFormats {
            do {
                let outputDirectory = try createTemporaryDirectory()
                try Process.run(command: swiftDocCommand,
                                arguments: [
                                    "generate",
                                    "--module-name", "SwiftDoc",
                                    "--format", format.outputFormat,
                                    "--output", outputDirectory.path,
                                    "--minimum-access-level", minimumAccessLevel.rawValue,
                                    sourcesDirectory!.path
                ]) { result in
                    if result.terminationStatus != EXIT_SUCCESS {
                        XCTFail("Generating documentation failed for format \(format.outputFormat)", file: file, line: line)
                    }
                }

                outputs.append(format.init(directory: outputDirectory))
            }
            catch let error {
                XCTFail("Could not generate documentation format \(format.outputFormat) (\(error))", file: file, line: line)
            }
        }
    }
}


extension GenerateTestCase {
    func XCTAssertDocumentationContains(_ symbolType: SymbolType, file: StaticString = #filePath, line: UInt = #line) {
        for output in outputs {
            if output.symbol(symbolType) == nil {
                XCTFail("Output \(type(of: output).outputFormat) is missing \(symbolType)", file: file, line: line)
            }
        }
    }

    func XCTAssertDocumentationNotContains(_ symbolType: SymbolType, file: StaticString = #filePath, line: UInt = #line) {
        for output in outputs {
            if output.symbol(symbolType) != nil {
                XCTFail("Output \(type(of: output).outputFormat) contains \(symbolType) although it should be omitted", file: file, line: line)
            }
        }
    }

    enum SymbolType: CustomStringConvertible {
        case `class`(String)
        case `struct`(String)
        case `enum`(String)
        case `typealias`(String)
        case `protocol`(String)
        case function(String)
        case variable(String)
        case `extension`(String)

        var description: String {
            switch self {
            case .class(let name):
                return "class '\(name)'"
            case .struct(let name):
                return "struct '\(name)'"
            case .enum(let name):
                return "enum '\(name)'"
            case .typealias(let name):
                return "typealias '\(name)'"
            case .protocol(let name):
                return "protocol '\(name)'"
            case .function(let name):
                return "func '\(name)'"
            case .variable(let name):
                return "variable '\(name)'"
            case .extension(let name):
                return "extension '\(name)'"
            }
        }
    }
}


extension GenerateTestCase {

    enum MinimumAccessLevel: String {
        case `public`, `internal`, `private`
    }
}



private func createTemporaryDirectory() throws -> URL {
    let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: temporaryDirectoryURL, withIntermediateDirectories: true)

    return temporaryDirectoryURL
}
