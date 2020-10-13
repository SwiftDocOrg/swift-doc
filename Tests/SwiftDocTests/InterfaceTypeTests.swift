import XCTest

import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftSyntax

final class InterfaceTypeTests: XCTestCase {

    func testPrivateInheritance() throws {
        let sourceFile: SourceFile = #"""
        public class A { }

        class B : A { }

        public class C : A { }
        """#

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
}
