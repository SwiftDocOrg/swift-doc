import XCTest

@testable import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftSyntax

final class SourceFileTests: XCTestCase {
    func testSourceFile() throws {
        let source = #"""
        import Foundation

        /// Protocol
        public protocol P {
            /// Function requirement
            func f()

            /// Property requirement
            var p: Any { get }
        }

        /// Enumeration
        public enum E {
            /// Enumeration case
            case c
        }

        /// Structure
        public struct S {}

        /// Extension
        extension S: P {
            /// Function
            func f() {}

            /// Property
            var p: Any { return () }
        }

        /// Class
        open class C: P{
            /// Function
            func f() {}

            /// Property
            var p: Any { return () }
        }

        /// Subclass
        public final class SC: C {}
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())

        XCTAssertEqual(sourceFile.imports.count, 1)
        XCTAssertEqual(sourceFile.imports.first?.pathComponents, ["Foundation"])

        XCTAssertEqual(sourceFile.symbols.count, 12)

        do {
            let `protocol` = sourceFile.symbols[0]
            XCTAssert(`protocol`.declaration is Protocol)
            XCTAssertEqual(`protocol`.documentation?.summary, "Protocol")

            do {
                let function = sourceFile.symbols[1]

                XCTAssert(function.declaration is Function)

                XCTAssertEqual(function.context.count, 1)
                XCTAssert(function.context.first is Symbol)
                XCTAssertEqual(function.context.first as? Symbol, `protocol`)

                XCTAssertEqual(function.documentation?.summary, "Function requirement")
            }

            do {
                let property = sourceFile.symbols[2]

                XCTAssert(property.declaration is Variable)

                XCTAssertEqual(property.context.count, 1)
                XCTAssert(property.context.first is Symbol)
                XCTAssertEqual(property.context.first as? Symbol, `protocol`)

                XCTAssertEqual(property.documentation?.summary, "Property requirement")
            }
        }

        do {
            let enumeration = sourceFile.symbols[3]
            XCTAssert(enumeration.declaration is Enumeration)
            XCTAssertEqual(enumeration.documentation?.summary, "Enumeration")

            do {
                let `case` = sourceFile.symbols[4]

                XCTAssert(`case`.declaration is Enumeration.Case)

                XCTAssertEqual(`case`.context.count, 1)
                XCTAssert(`case`.context.first is Symbol)
                XCTAssertEqual(`case`.context.first as? Symbol, enumeration)

                XCTAssertEqual(`case`.documentation?.summary, "Enumeration case")
            }
        }

        do {
            let structure = sourceFile.symbols[5]
            XCTAssert(structure.declaration is Structure)
            XCTAssertEqual(structure.documentation?.summary, "Structure")
        }

        do {
            do {
                let function = sourceFile.symbols[6]

                XCTAssert(function.declaration is Function)

                XCTAssertEqual(function.context.count, 1)
                XCTAssert(function.context.first is Extension)
                XCTAssertEqual((function.context.first as? Extension)?.extendedType, "S")

                XCTAssertEqual(function.documentation?.summary, "Function")
            }

            do {
                let property = sourceFile.symbols[7]

                XCTAssert(property.declaration is Variable)

                XCTAssertEqual(property.context.count, 1)
                XCTAssert(property.context.first is Extension)
                XCTAssertEqual((property.context.first as? Extension)?.extendedType, "S")

                XCTAssertEqual(property.documentation?.summary, "Property")
            }
        }

        do {
            let `class` = sourceFile.symbols[8]
            XCTAssert(`class`.declaration is Class)
            XCTAssertEqual(`class`.documentation?.summary, "Class")

            do {
                let function = sourceFile.symbols[9]

                XCTAssert(function.declaration is Function)

                XCTAssertEqual(function.context.count, 1)
                XCTAssert(function.context.first is Symbol)
                XCTAssertEqual(function.context.first as? Symbol, `class`)

                XCTAssertEqual(function.documentation?.summary, "Function")
            }

            do {
                let property = sourceFile.symbols[10]

                XCTAssert(property.declaration is Variable)

                XCTAssertEqual(property.context.count, 1)
                XCTAssert(property.context.first is Symbol)
                XCTAssertEqual(property.context.first as? Symbol, `class`)

                XCTAssertEqual(property.documentation?.summary, "Property")
            }
        }

        do {
            let `class` = sourceFile.symbols[11]
            XCTAssert(`class`.declaration is Class)
            XCTAssertEqual((`class`.declaration as? Class)?.inheritance, ["C"])
            XCTAssertEqual(`class`.documentation?.summary, "Subclass")
        }
    }
}
