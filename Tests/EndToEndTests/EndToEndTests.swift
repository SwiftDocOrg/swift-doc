import class Foundation.Bundle
import XCTest

final class EndToEndTests: XCTestCase {
  func testCSS() throws {
    // Some of the APIs that we use below are available in macOS 10.13 and above.
    guard #available(macOS 10.13, *) else {
      return
    }

    let process = Process()
    process.executableURL = productsDirectory.appendingPathComponent("swift-doc")
    process.arguments = ["generate", "--module-name", "SwiftDoc", "--format", "html", "Sources"]

    let pipe = Pipe()
    process.standardOutput = pipe

    try process.run()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)

    XCTAssertEqual(output, "")

    let cssPath = productsDirectory
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("documentation")
      .appendingPathComponent("all.css")
    let cssData = try Data(contentsOf: cssPath)
    guard let css = String(data: cssData, encoding: .utf8) else {
      return XCTFail("Failed to decode a UTF-8 string from `cssData` in \(#function)")
    }

    XCTAssertTrue(css.starts(with: ":root"))
  }

  /// Returns path to the built products directory.
  lazy var productsDirectory: URL = {
    #if os(macOS)
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
    #else
    return Bundle.main.bundleURL
    #endif
  }()
}
