import Foundation
import CommonMarkBuilder

fileprivate let dateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter
}()

struct FooterPage: Page {

    // MARK: - Page

    var body: Document {
        let timestamp = dateFormatter.string(from: Date())

        return Document {
            Fragment {
                "Generated at \(timestamp) using [swift-doc](https://github.com/SwiftDocOrg/swift-doc)."
            }
        }
    }
}
