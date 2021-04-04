import XCTest

extension XCTestCase {
    func getSwiftDocCommand() -> URL {
        #if USE_HOMEBREW
        return URL(fileURLWithPath: "/usr/local/bin/swift-doc")
        #else
        return Bundle.productsDirectory.appendingPathComponent("swift-doc")
        #endif
    }
}
