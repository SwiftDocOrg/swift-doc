import SwiftDoc

extension Symbol {
    var isDocumented: Bool {
        return !documentation.isEmpty
    }
}
