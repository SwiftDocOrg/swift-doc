import XCTest

import SwiftDoc

final class PathTests: XCTestCase {
    func testEmptyBaseURL() {
        XCTAssertEqual(path(for: "Class", with: ""), "Class")
    }

    func testRootDirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "/"), "/Class")
    }

    func testCurrentDirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "./"), "./Class")
    }

    func testNestedSubdirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "/path/to/directory"), "/path/to/directory/Class")
        XCTAssertEqual(path(for: "Class", with: "/path/to/directory/"), "/path/to/directory/Class")
    }

    func testDomainBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "https://example.com"), "https://example.com/Class")
        XCTAssertEqual(path(for: "Class", with: "https://example.com/"), "https://example.com/Class")
    }

    func testDomainSubdirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "https://example.com/docs"), "https://example.com/docs/Class")
        XCTAssertEqual(path(for: "Class", with: "https://example.com/docs/"), "https://example.com/docs/Class")
    }
}
