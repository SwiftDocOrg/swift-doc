import SwiftDoc
import SwiftSemantics

extension Modifiable {
    var nonAccessModifiers: [Modifier] {
        return modifiers.filter { modifier in
            switch modifier.name {
            case "private", "fileprivate", "internal", "public", "open":
                return false
            default:
                return true
            }
        }
    }
}
