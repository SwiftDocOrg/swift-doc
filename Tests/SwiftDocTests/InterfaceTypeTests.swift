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

        let subclasses = module.interface.typesInheriting(from: classA)
        XCTAssertEqual(subclasses.count, 2)
        XCTAssertEqual(subclasses[0].id, classB.id)
        XCTAssertEqual(subclasses[1].id, classC.id)
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
        XCTAssertEqual(module.interface.symbols.count, 5)

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
        XCTAssertFalse(sourceFile.symbols[0].isInternal, "Function `a()` should NOT be marked as internal")
        XCTAssertFalse(sourceFile.symbols[0].isPrivate, "Function `a()` should NOT be marked as private")
        XCTAssertTrue(sourceFile.symbols[1].isPublic, "Function `b()` should BE marked as public - its visibility is public")
        XCTAssertFalse(sourceFile.symbols[1].isInternal, "Function `b()` should NOT be marked as internal")
        XCTAssertFalse(sourceFile.symbols[1].isPrivate, "Function `b()` should NOT be marked as private")
        XCTAssertFalse(sourceFile.symbols[2].isPublic, "Function `c()` should NOT be marked as public - its visibility is internal")
        XCTAssertTrue(sourceFile.symbols[2].isInternal, "Function `c()` should BE marked as internal - its visibility is internal.")
        XCTAssertFalse(sourceFile.symbols[2].isPrivate, "Function `c()` should NOT be marked as private")
        XCTAssertFalse(sourceFile.symbols[3].isPublic, "Function `d()` should NOT be marked as public - its visibility is fileprivate")
        XCTAssertFalse(sourceFile.symbols[3].isInternal, "Function `d()` should NOT be marked as internal - its visibility is fileprivate")
        XCTAssertTrue(sourceFile.symbols[3].isPrivate, "Function `d()` should BE marked as public - its visibility is fileprivate")
        XCTAssertFalse(sourceFile.symbols[4].isPublic, "Function `e()` should NOT be marked as public - its visibility is private")
        XCTAssertFalse(sourceFile.symbols[4].isInternal, "Function `e()` should NOT be marked as public - its visibility is private")
        XCTAssertTrue(sourceFile.symbols[4].isPrivate, "Function `e()` should BE marked as private - its visibility is private")

        XCTAssertEqual(module.interface.symbols.count, 5)
        XCTAssertEqual(module.interface.symbols[0].name, "a()", "Function `a()` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[1].name, "b()", "Function `b()` should be in documented interface")
    }

    func testComputedPropertiesInPublicExtension() throws {
        let source = #"""
        public extension Int {
            var a: Int { 1 }
            public var b: Int { 1 }
            internal var c: Int { 1 }
            fileprivate var d: Int { 1 }
            private var e: Int { 1 }
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(sourceFile.symbols.count, 5)
        XCTAssertTrue(sourceFile.symbols[0].isPublic, "Property `a` should BE marked as public - its visibility is specified by extension")
        XCTAssertFalse(sourceFile.symbols[0].isInternal, "Property `a` should NOT be marked as internal - its visibility is specified public by extension")
        XCTAssertFalse(sourceFile.symbols[0].isPrivate, "Property `a` should NOT be marked as private - its visibility is specified public by extension")
        XCTAssertTrue(sourceFile.symbols[1].isPublic, "Property `b` should BE marked as public - its visibility is public")
        XCTAssertFalse(sourceFile.symbols[1].isInternal, "Property `b` should NOT be marked as internal - its visibility is public")
        XCTAssertFalse(sourceFile.symbols[1].isPrivate, "Property `b` should NOT be marked as private - its visibility is public")
        XCTAssertFalse(sourceFile.symbols[2].isPublic, "Property `c` should NOT be marked as public - its visibility is internal")
        XCTAssertTrue(sourceFile.symbols[2].isInternal, "Property `c` should BE marked as internal - its visibility is internal")
        XCTAssertFalse(sourceFile.symbols[2].isPrivate, "Property `c` should NOT be marked as private - its visibility is internal")
        XCTAssertFalse(sourceFile.symbols[3].isPublic, "Property `d` should NOT be marked as public - its visibility is fileprivate")
        XCTAssertFalse(sourceFile.symbols[3].isInternal, "Property `d` should NOT be marked as internal - its visibility is fileprivate")
        XCTAssertTrue(sourceFile.symbols[3].isPrivate, "Property `d` should BE marked as private - its visibility is fileprivate")
        XCTAssertFalse(sourceFile.symbols[4].isPublic, "Property `e` should NOT be marked as public - its visibility is private")
        XCTAssertFalse(sourceFile.symbols[4].isInternal, "Property `e` should NOT be marked as internal - its visibility is private")
        XCTAssertTrue(sourceFile.symbols[4].isPrivate, "Property `e` should BE marked as public - its visibility is private")

        XCTAssertEqual(module.interface.symbols.count, 5)
        XCTAssertEqual(module.interface.symbols[0].name, "a", "Property `a` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[1].name, "b", "Property `b` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[2].name, "c", "Property `c` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[3].name, "d", "Property `d` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[4].name, "e", "Property `e` should be in documented interface")
    }

    func testComputedPropertiesWithMultipleAccessModifiersInPublicExtension() throws {
        let source = #"""
        public extension Int {
            internal(set) var a: Int {
                get { 1 }
                set {}
            }
            private(set) var b: Int {
                get { 1 }
                set {}
            }
            public internal(set) var c: Int {
                get { 1 }
                set {}
            }
            public fileprivate(set) var d: Int {
                get { 1 }
                set {}
            }
            public private(set) var e: Int {
                get { 1 }
                set {}
            }
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(sourceFile.symbols.count, 5)
        XCTAssertTrue(sourceFile.symbols[0].isPublic, "Property `a` should be marked as public - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[0].isInternal, "Property `a` should not be marked as internal - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[0].isPrivate, "Property `a` should not be marked as private - the visibility of its getter is public")
        XCTAssertTrue(sourceFile.symbols[1].isPublic, "Property `b` should be marked as public - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[1].isInternal, "Property `b` should not be marked as internal - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[1].isPrivate, "Property `b` should not be marked as private - the visibility of its getter is public")
        XCTAssertTrue(sourceFile.symbols[2].isPublic, "Property `c` should be marked as public - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[2].isInternal, "Property `c` should not be marked as internal - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[2].isPrivate, "Property `c` should not be marked as private - the visibility of its getter is public")
        XCTAssertTrue(sourceFile.symbols[3].isPublic, "Property `d` should be marked as public - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[3].isInternal, "Property `d` should not be marked as internal - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[3].isPrivate, "Property `d` should not be marked as private - the visibility of its getter is public")
        XCTAssertTrue(sourceFile.symbols[4].isPublic, "Property `e` should be marked as public - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[4].isInternal, "Property `e` should not be marked as internal - the visibility of its getter is public")
        XCTAssertFalse(sourceFile.symbols[4].isPrivate, "Property `e` should not be marked as private - the visibility of its getter is public")

        XCTAssertEqual(module.interface.symbols.count, 5)
        XCTAssertEqual(module.interface.symbols[0].name, "a", "Property `a` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[1].name, "b", "Property `b` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[2].name, "c", "Property `c` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[3].name, "d", "Property `d` should be in documented interface")
        XCTAssertEqual(module.interface.symbols[4].name, "e", "Property `e` should be in documented interface")
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

        XCTAssertEqual(module.interface.symbols.count, 8)
        XCTAssertEqual(module.interface.symbols[0].name, "RootController")
        XCTAssertEqual(module.interface.symbols[1].name, "ControllerExtension")
        XCTAssertEqual(module.interface.symbols[2].name, "public_properties")
        XCTAssertEqual(module.interface.symbols[3].name, "internal_properties")
        XCTAssertEqual(module.interface.symbols[4].name, "ExtendedProperties")
        XCTAssertEqual(module.interface.symbols[5].name, "public_prop")
        XCTAssertEqual(module.interface.symbols[6].name, "InternalProperties")
        XCTAssertEqual(module.interface.symbols[7].name, "internal_prop")
    }

    func testDefaultImplementationsOfProtocols() throws {
        let source = #"""
        public protocol SomeProtocol {
            func someMethod()
        }
                     
        public extension SomeProtocol {
            func someMethod() { }
                     
            func someOtherMethod() { }
        }
        """#


        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        let protocolSymbol = module.interface.symbols[0]
        XCTAssertEqual(protocolSymbol.name, "SomeProtocol")
        let defaultImplementations = module.interface.defaultImplementations(of: protocolSymbol)
        XCTAssertEqual(defaultImplementations.count, 2)
        XCTAssertEqual(defaultImplementations[0].name, "someMethod()")
        XCTAssertEqual(defaultImplementations[1].name, "someOtherMethod()")
    }

    func testExternalSymbols() throws {
        let source = #"""
         import UIKit 
                     
         public class SomeClass {
             public struct InnerObject { }
            
             typealias ActuallyExternal = UIView
                     
             typealias ActuallyInternal = InnerStruct 
             
             struct InnerStruct {}        
         }
                      
         public typealias MyClass = SomeClass

         public class AnotherClass {
             typealias PublicClass = SomeClass
         }
                     
         public typealias ExternalClass = UIGestureRecognizer
         """#


        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(module.interface.symbols(named: "SomeClass", resolvingTypealiases: true).first?.name, "SomeClass")
        XCTAssertEqual(module.interface.symbols(named: "SomeClass", resolvingTypealiases: false).first?.name, "SomeClass")

        XCTAssertEqual(module.interface.symbols(named: "SomeClass.InnerObject", resolvingTypealiases: true).first?.name, "InnerObject")
        XCTAssertEqual(module.interface.symbols(named: "SomeClass.InnerObject", resolvingTypealiases: false).first?.name, "InnerObject")

        XCTAssertEqual(module.interface.symbols(named: "SomeClass.ActuallyInternal", resolvingTypealiases: true).first?.name, "InnerStruct")
        XCTAssertEqual(module.interface.symbols(named: "SomeClass.ActuallyInternal", resolvingTypealiases: false).first?.name, "ActuallyInternal")

        XCTAssertEqual(module.interface.symbols(named: "MyClass", resolvingTypealiases: true).first?.name, "SomeClass")
        XCTAssertEqual(module.interface.symbols(named: "MyClass", resolvingTypealiases: false).first?.name, "MyClass")

        XCTAssertEqual(module.interface.symbols(named: "MyClass.InnerObject", resolvingTypealiases: true).first?.name, "InnerObject")
        XCTAssertNil(module.interface.symbols(named: "MyClass.InnerObject", resolvingTypealiases: false).first)

        XCTAssertEqual(module.interface.symbols(named: "AnotherClass.PublicClass", resolvingTypealiases: true).first?.name, "SomeClass")
        XCTAssertTrue(module.interface.symbols(named: "AnotherClass.PublicClass", resolvingTypealiases: false).first?.api is Typealias)

        XCTAssertEqual(module.interface.symbols(named: "AnotherClass.PublicClass.ActuallyInternal", resolvingTypealiases: true).first?.name, "InnerStruct")
        XCTAssertNil(module.interface.symbols(named: "AnotherClass.PublicClass.ActuallyInternal", resolvingTypealiases: false).first)

        XCTAssertNil(module.interface.symbols(named: "ExternalClass", resolvingTypealiases: true).first)
        XCTAssertTrue(module.interface.symbols(named: "ExternalClass", resolvingTypealiases: false).first?.api is Typealias)

        XCTAssertNil(module.interface.symbols(named: "ExternalClass.State", resolvingTypealiases: true).first)
        XCTAssertNil(module.interface.symbols(named: "ExternalClass.State", resolvingTypealiases: false).first)

        XCTAssertNil(module.interface.symbols(named: "SomeClass.ActuallyExternal", resolvingTypealiases: true).first)
        XCTAssertTrue(module.interface.symbols(named: "SomeClass.ActuallyExternal", resolvingTypealiases: false).first?.api is Typealias)

        XCTAssertNil(module.interface.symbols(named: "UIGestureRecognizer", resolvingTypealiases: true).first)
        XCTAssertNil(module.interface.symbols(named: "UIGestureRecognizer", resolvingTypealiases: false).first)

        XCTAssertNil(module.interface.symbols(named: "UIGestureRecognizer.State", resolvingTypealiases: true).first)
        XCTAssertNil(module.interface.symbols(named: "UIGestureRecognizer.State", resolvingTypealiases: false).first)
    }

    public func testMembersOfTypealiasedSymbols() throws {
        let source = #"""
        public class SomeClass {
            public func someMethod() { }
        }
                
        public typealias OtherClass = SomeClass
                
        public extension OtherClass {
            func someExtensionMethod() { }
        }
        """#


        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(module.interface.symbols.count, 4)

        let someClass = module.interface.symbols[0]
        XCTAssertEqual(someClass.name, "SomeClass")
        let members = module.interface.members(of: someClass)
        XCTAssertEqual(2, members.count)
        XCTAssertEqual(members[0].name, "someMethod()")
        XCTAssertEqual(members[1].name, "someExtensionMethod()")
    }

    public func testToplevelSymbols() throws {
        let source = #"""
        public class SomeClass {
            public func someMethod() { }
        }
                     
        infix operator ≠
                
        public typealias OtherClass = SomeClass
                     
        public func someFunction() { }
                
        public extension OtherClass {
            func someExtensionMethod() { }
        }
        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
        let module = Module(name: "Module", sourceFiles: [sourceFile])

        XCTAssertEqual(module.interface.topLevelSymbols.count, 4)

        XCTAssertEqual(module.interface.topLevelSymbols[0].name, "SomeClass")
        XCTAssertEqual(module.interface.topLevelSymbols[1].name, "≠")
        XCTAssertEqual(module.interface.topLevelSymbols[2].name, "OtherClass")
        XCTAssertEqual(module.interface.topLevelSymbols[3].name, "someFunction()")
    }
}
