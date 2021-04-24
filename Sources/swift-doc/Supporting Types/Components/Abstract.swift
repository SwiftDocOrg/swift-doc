import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct Abstract: Component {
    var symbol: Symbol
    let baseURL: String

    init(for symbol: Symbol, baseURL: String) {
        self.symbol = symbol
        self.baseURL = baseURL
    }
    
    // MARK: - Component

    var fragment: Fragment {
        if let summary = symbol.documentation?.summary {
            return Fragment {
                List.Item {
                    Fragment {
                        #"""
                        [\#(symbol.id.description.escapingEmojiShortcodes)](\#(path(for: symbol, with: baseURL))):
                        \#(summary)
                        """#
                    }
                }
            }
        } else {
            return Fragment {
                List.Item {
                    Paragraph {
                        Link(urlString: path(for: symbol, with: baseURL), text: symbol.id.description.escapingEmojiShortcodes)
                    }
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let descriptor = String(describing: type(of: symbol.api)).lowercased()

        return #"""
        <dt class="\#(descriptor)">
            <a href=\#(path(for: symbol, with: baseURL)) title="\#(descriptor) - \#(symbol.id.description)">
                \#(softbreak(symbol.id.description))
            </a>
        </dt>
        <dd>
            \#(commonmark: symbol.documentation?.summary?.description ?? "")
        </dd>
        """#
    }
}
