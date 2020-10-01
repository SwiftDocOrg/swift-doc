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

    func testFunctionsInPublicExtension() throws {
        let source = #"""
        public extension Int {
            func a() {}
            public func b() {}
            internal func c() {}
            fileprivate func d() {}
            private func e() {}
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(sourceFile.symbols.count, 5)
        XCTAssertTrue(sourceFile.symbols[0].isPublic, "Function `a()` should BE marked as public - its visibility is specified by extension")
        XCTAssertTrue(sourceFile.symbols[1].isPublic, "Function `b()` should BE marked as public - its visibility is public")
        XCTAssertFalse(sourceFile.symbols[2].isPublic, "Function `c()` should NOT be marked as public - its visibility is internal")
        XCTAssertFalse(sourceFile.symbols[3].isPublic, "Function `d()` should NOT be marked as public - its visibility is fileprivate")
        XCTAssertFalse(sourceFile.symbols[4].isPublic, "Function `e()` should NOT be marked as public - its visibility is private")

        XCTAssertEqual(module.interface.symbols.count, 2)
        XCTAssertEqual(module.interface.symbols[0].name, "a()", "Function `a()` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[1].name, "b()", "Function `b()` should be in documented interface")
    }

    func testNestedPropertiesInPublicExtension() throws {
        let source = #"""
        public class RootController {}

        public extension RootController {
            class ControllerExtension {
                public var public_properties: ExtendedProperties = ExtendedProperties()
                internal var internal_properties: InternalProperties = InternalProperties()
            }
        }

        public extension RootController.ControllerExtension {
            struct ExtendedProperties {
                public var public_prop: Int = 1
            }
        }

        internal extension RootController.ControllerExtension {
            struct InternalProperties {
                internal var internal_prop: String = "FOO"
            }
        }
        """#


        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(module.interface.symbols.count, 5)
        XCTAssertEqual(module.interface.symbols[0].name, "RootController")
        XCTAssertEqual(module.interface.symbols[1].name, "ControllerExtension")
        XCTAssertEqual(module.interface.symbols[2].name, "public_properties")
        XCTAssertEqual(module.interface.symbols[3].name, "ExtendedProperties")
        XCTAssertEqual(module.interface.symbols[4].name, "public_prop")
    }
}
