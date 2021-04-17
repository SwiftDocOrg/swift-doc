import XCTest
import Foundation

extension XCTestCase {
    var swiftDocCommand: URL {
        #if USE_HOMEBREW
        return URL(fileURLWithPath: "/usr/local/bin/swift-doc")
        #else
        return Bundle.productsDirectory.appendingPathComponent("swift-doc")
        #endif
    }
}
