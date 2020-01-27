import CommonMarkBuilder
import SwiftMarkup
import Foundation

struct Callout: Component {
    var callout: SwiftMarkup.Documentation.Callout

    init(_ callout: SwiftMarkup.Documentation.Callout) {
        self.callout = callout
    }

    // MARK: - Component

    var body: Fragment {
        Fragment {
            """
            > \(callout.delimiter.rawValue.capitalized): \(callout.content)
            """
        }
    }
}
