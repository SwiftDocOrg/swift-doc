import XCTest

class TestVisibility: GenerateTestCase {
    func testClassesVisibility() {
        sourceFile("Example.swift") {
        #"""
        public class PublicClass {}

        class InternalClass {}

        private class PrivateClass {}
        """#
        }

        generate(minimumAccessLevel: .internal)

        XCTAssertDocumentationContains(.class("PublicClass"))
        XCTAssertDocumentationContains(.class("InternalClass"))
        XCTAssertDocumentationNotContains(.class("PrivateClass"))
    }

    /// This example fails (because the tests are wrong, not because of a bug in `swift-doc`).
    func testFailingExample() {
        sourceFile("Example.swift") {
            #"""
            public class PublicClass {}

            public class AnotherPublicClass {}

            class InternalClass {}
            """#
        }

        generate(minimumAccessLevel: .public)

        XCTAssertDocumentationContains(.class("PublicClass"))
        XCTAssertDocumentationContains(.class("InternalClass"))
    }
}
