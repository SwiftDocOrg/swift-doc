import ArgumentParser
import SwiftDoc

enum AccessLevel: String, ExpressibleByArgument {
    case `public`
    case `internal`

    func includes(symbol: Symbol) -> Bool {
        switch self {
        case .public:
            return symbol.isPublic
        case .internal:
            return symbol.isPublic || symbol.isInternal
        }
    }
}
