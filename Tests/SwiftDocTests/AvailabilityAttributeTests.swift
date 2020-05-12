import XCTest

import SwiftDoc
import SwiftSemantics
import struct SwiftSemantics.Protocol
import SwiftSyntax

final class AvailabilityAttributeTypesTests: XCTestCase {
    func testBasicAvailabilityType() throws {
        let source = #"""

        @available(iOS, deprecated: 13, renamed: "NewAndImprovedViewController")
        class OldViewController: UIViewController { }

        """#

        let url = try temporaryFile(contents: source)
        let sourceFile = try SourceFile(file: url, relativeTo: url.deletingLastPathComponent())
      
        let symbol = sourceFile.symbols[0]
        XCTAssert(symbol.api is Class)

        XCTAssertEqual(symbol.availabilityAttributes.count, 1)
        
        let attributes = symbol.availabilityAttributes.first!.attributes
        XCTAssertEqual(attributes.count, 3)

        let iOS = attributes[0]
        XCTAssertEqual(iOS, AvailabilityAttributeType.platform(platform: "iOS", version: nil))
         
        let deprecation = attributes[1]
        XCTAssertEqual(deprecation, AvailabilityAttributeType.deprecated(version: "13"))
        
        let renamed = attributes[2]
        XCTAssertEqual(renamed, AvailabilityAttributeType.renamed(message: "\"NewAndImprovedViewController\""))

    }
}