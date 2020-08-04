import XCTest

import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftSyntax

final class InterfaceTypeTests: XCTestCase {

    func testPrivateInheritance() throws {
        let source = #"""
        public class A { }

        class B : A { }

        public class C : A { }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])
   
        // `class A`
        let classA = sourceFile.symbols[0]
        XCTAssert(classA.api is Class)
         
         // `class B`
        let classB = sourceFile.symbols[1]
        XCTAssert(classB.api is Class)
          
        // `class C`
        let classC = sourceFile.symbols[2]
        XCTAssert(classC.api is Class)
        
        // Class B does not exist in subclasses because it's not public
        // Class C exists in subclasses because it's public
        let subclasses = module.interface.typesInheriting(from: classA)
        XCTAssertEqual(subclasses.count, 1)
        XCTAssertEqual(subclasses[0].id, classC.id)
    }

    func testInternalMembers() throws {
        let source = #"""
        public struct A: Encodable {
            enum CodingKeys: String, CodingKey {
                case a
            }

            let a: String

            init(a: String) {
                self.a = a
            }
        }

        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(sourceFile.symbols.count, 5)
        XCTAssertEqual(module.interface.symbols.count, 1)

        // `struct A`
        do {
            let symbol = sourceFile.symbols[0]
            XCTAssert(symbol.api is Structure)
            XCTAssertEqual(symbol.api.name, "A")
        }
    }
}
