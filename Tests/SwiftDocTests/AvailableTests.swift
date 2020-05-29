import XCTest

import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftSyntax

final class AvailabilityTests: XCTestCase {

    func testShortHandAvailabilityMultiplePlatforms() throws {
         let source = #"""

        @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 0)
        XCTAssertEqual(availability.platforms.count, 5)

        XCTAssertEqual(availability.platforms[0].platform, "macOS")
        XCTAssertEqual(availability.platforms[1].platform, "iOS")
        XCTAssertEqual(availability.platforms[2].platform, "watchOS")
        XCTAssertEqual(availability.platforms[3].platform, "tvOS")
        XCTAssertFalse(availability.platforms[3].isOtherPlatform())
        XCTAssertEqual(availability.platforms[4].platform, "*")
        XCTAssertTrue(availability.platforms[4].isOtherPlatform())

        XCTAssertEqual(availability.platforms[0].version, "10.15")
        XCTAssertEqual(availability.platforms[1].version, "13")
        XCTAssertEqual(availability.platforms[2].version, "6")
        XCTAssertEqual(availability.platforms[3].version, "13")
        
        XCTAssertNil(availability.platforms[4].version)
    }

    func testUnavailableAvailability() throws {
     let source = #"""

        @available(tvOS, unavailable)
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "tvOS")
        XCTAssertNil(availability.platforms[0].version)

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.unavailable)
    }

    func testDepcrecatedNoVersionAvailability() throws {
        let source = #"""

        @available(iOS, deprecated)
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "iOS")
        XCTAssertNil(availability.platforms[0].version)

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.deprecated(version: nil))
    }

    func testDepcrecatedWithVersionAvailability() throws {
        let source = #"""

        @available(iOS, deprecated: 2.5)
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "iOS")
        XCTAssertNil(availability.platforms[0].version)

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.deprecated(version: "2.5"))
    }

    func testMessageAvailability() throws {
        let source = #"""

        @available(*, message: "this is no longer used")
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "*")
        XCTAssertNil(availability.platforms[0].version)
        XCTAssertTrue(availability.platforms[0].isOtherPlatform())

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.message(message: #""this is no longer used""#))
    }

    func testRenamedAvailability() throws {
        let source = #"""

        @available(*, renamed: "SomeNewProtcol")
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "*")
        XCTAssertNil(availability.platforms[0].version)
        XCTAssertTrue(availability.platforms[0].isOtherPlatform())

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.renamed(message: #""SomeNewProtcol""#))
    }

    func testObseletedAvailability() throws {
        let source = #"""

        @available(iOS, obsoleted: 2.0)
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "iOS")
        XCTAssertNil(availability.platforms[0].version)
        XCTAssertFalse(availability.platforms[0].isOtherPlatform())

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.obsoleted(version: "2.0"))
    }

    func testIntroducedAvailability() throws {
        let source = #"""

        @available(iOS, introduced: 2.0)
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 1)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "iOS")
        XCTAssertNil(availability.platforms[0].version)
        XCTAssertFalse(availability.platforms[0].isOtherPlatform())

        XCTAssertEqual(availability.attributes[0], AvailabilityKind.introduced(version: "2.0"))
    }

    func testMultipleAvailability() throws {
        let source = #"""

        @available(*, introduced: 2.0, deprecated: 2.1, renamed: "NewProtocol", message: "some message")
        protocol test { }

        """#
        let symbol = try! firstSymbol(fromString: source)
        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let availability = symbol.availabilityAttributes.first!
        XCTAssertEqual(availability.attributes.count, 4)
        XCTAssertEqual(availability.platforms.count, 1)

        XCTAssertEqual(availability.platforms[0].platform, "*")
        XCTAssertNil(availability.platforms[0].version)
        XCTAssertTrue(availability.platforms[0].isOtherPlatform())
        
        XCTAssertEqual(availability.attributes[0], AvailabilityKind.introduced(version: "2.0"))
        XCTAssertEqual(availability.attributes[1], AvailabilityKind.deprecated(version: "2.1"))
        XCTAssertEqual(availability.attributes[2], AvailabilityKind.renamed(message: #""NewProtocol""#))
        XCTAssertEqual(availability.attributes[3], AvailabilityKind.message(message: #""some message""#))
    }

    func firstSymbol(fromString string: String) throws -> Symbol {
       let url = try temporaryFile(contents: string)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())      
        return sourceFile.symbols[0]
    }
}

