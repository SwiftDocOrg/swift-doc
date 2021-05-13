import XCTest

import SwiftDoc

final class PathTests: XCTestCase {
    func testEmptyBaseURL() {
        XCTAssertEqual(path(for: "Class", with: ""), "Class")

        XCTAssertEqual(path(for: "(lhs:rhs:)", with: ""), "(lhs_rhs_)")
    }

    func testRootDirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "/"), "/Class")

        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "/"), "/(lhs_rhs_)")
    }

    func testCurrentDirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "./"), "./Class")

        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "./"), "./(lhs_rhs_)")
    }

    func testNestedSubdirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "/path/to/directory"), "/path/to/directory/Class")
        XCTAssertEqual(path(for: "Class", with: "/path/to/directory/"), "/path/to/directory/Class")

        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "/path/to/directory"), "/path/to/directory/(lhs_rhs_)")
        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "/path/to/directory/"), "/path/to/directory/(lhs_rhs_)")
    }

    func testDomainBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "https://example.com"), "https://example.com/Class")
        XCTAssertEqual(path(for: "Class", with: "https://example.com/"), "https://example.com/Class")

        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "https://example.com"), "https://example.com/(lhs_rhs_)")
        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "https://example.com/"), "https://example.com/(lhs_rhs_)")
    }

    func testDomainSubdirectoryBaseURL() {
        XCTAssertEqual(path(for: "Class", with: "https://example.com/docs"), "https://example.com/docs/Class")
        XCTAssertEqual(path(for: "Class", with: "https://example.com/docs/"), "https://example.com/docs/Class")

        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "https://example.com/docs"), "https://example.com/docs/(lhs_rhs_)")
        XCTAssertEqual(path(for: "(lhs:rhs:)", with: "https://example.com/docs/"), "https://example.com/docs/(lhs_rhs_)")
    }
}
