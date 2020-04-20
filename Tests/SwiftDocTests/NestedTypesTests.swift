import XCTest

import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftSyntax

final class NestedTypesTests: XCTestCase {
    func testNestedTypes() throws {
        let source = #"""
        public class C { }

        extension C {
            public enum E {
                case c
            }
        }

        extension C.E {
            public static let tp = 0
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile], minimumAccessLevel: .public)

        XCTAssertEqual(sourceFile.symbols.count, 4)

        // `class C`
        let `class` = sourceFile.symbols[0]
        XCTAssert(`class`.api is Class)

        // `enum E`
        let `enum` = sourceFile.symbols[1]
        XCTAssert(`enum`.api is Enumeration)

        // `case c`
        let `case` = sourceFile.symbols[2]
        XCTAssert(`case`.api is Enumeration.Case)

        // `let tp`
        let `let` = sourceFile.symbols[3]
        XCTAssert(`let`.api is Variable)

        // `class C` contains `enum E`
        let classRelationships = try XCTUnwrap(module.interface.relationshipsByObject[`class`.id])
        XCTAssertEqual(classRelationships.count, 1)
        XCTAssertTrue(classRelationships.allSatisfy({ $0.predicate == .memberOf }))
        XCTAssertEqual(Set(classRelationships.map({ $0.subject.id })), Set([`enum`.id]))

        // `enum C` contains `case c` and `let tp`
        let enumRelationships = try XCTUnwrap(module.interface.relationshipsByObject[`enum`.id])
        XCTAssertEqual(enumRelationships.count, 2)
        XCTAssertTrue(enumRelationships.allSatisfy({ $0.predicate == .memberOf }))
        XCTAssertEqual(Set(enumRelationships.map({ $0.subject.id })), Set([`case`.id, `let`.id]))

        // `case c` and `let tp` have no relationships
        XCTAssertNil(module.interface.relationshipsByObject[`case`.id])
        XCTAssertNil(module.interface.relationshipsByObject[`let`.id])

        // no other relationships present in module
        XCTAssertEqual(
            module.interface.relationships.count,
            [classRelationships, enumRelationships].joined().count
        )
    }

    #if false // Disabling tests for `swift-doc` code, executable targers are not testable.

    func testRelationshipsSectionWithNestedTypes() throws {
        let source = #"""
        public class C {
            public enum E {
            }
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        // `class C`
        let `class` = sourceFile.symbols[0]
        XCTAssert(`class`.api is Class)

        // `enum E`
        let `enum` = sourceFile.symbols[1]
        XCTAssert(`enum`.api is Enumeration)

        let classRelationships = Relationships(of: `class`, in: module)
        XCTAssertNotEqual(classRelationships.html, "")

        let enumRelationships = Relationships(of: `enum`, in: module)
        XCTAssertNotEqual(enumRelationships.html, "")
    }

    func testNoRelationshipsSection() throws {
        let source = #"""
        public class C {
        }

        public enum E {
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        // `class C`
        let `class` = sourceFile.symbols[0]
        XCTAssert(`class`.api is Class)

        // `enum E`
        let `enum` = sourceFile.symbols[1]
        XCTAssert(`enum`.api is Enumeration)

        let classRelationships = Relationships(of: `class`, in: module)
        XCTAssertEqual(classRelationships.html, "")

        let enumRelationships = Relationships(of: `enum`, in: module)
        XCTAssertEqual(enumRelationships.html, "")
    }

    #endif
}
