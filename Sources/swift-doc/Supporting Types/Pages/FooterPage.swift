import Foundation
import CommonMarkBuilder
import HypertextLiteral

fileprivate let dateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

fileprivate let timestampDateFormatter: DateFormatter = {
    var dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter
}()

fileprivate let href = "https://github.com/SwiftDocOrg/swift-doc"

struct FooterPage: Page {
    let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - Page

    var document: CommonMark.Document {
        let timestamp = timestampDateFormatter.string(from: Date())

        return Document {
            Fragment {
                "Generated at \(timestamp) using [swift-doc](\(href)) \(SwiftDoc.configuration.version)."
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let timestamp = timestampDateFormatter.string(from: Date())
        let dateString = dateFormatter.string(from: Date())

        return #"""
        <p>
            Generated on <time datetime=\#(timestamp)>\#(dateString)</time> using <a href=\#(href)>swift-doc</a> <span class="version">\#(SwiftDoc.configuration.version)</span>.
        </p>
        """#
    }
}
