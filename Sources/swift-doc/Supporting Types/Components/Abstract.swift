import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct Abstract: Component {
    var symbol: Symbol

    init(for symbol: Symbol) {
        self.symbol = symbol
    }
    
    // MARK: - Component

    var fragment: Fragment {
        if let summary = symbol.documentation?.summary {
            return Fragment {
                List.Item {
                    Paragraph {
                        Link(urlString: path(for: symbol), text: symbol.id.description)
                        Text { ":" }
                    }

                    Fragment {
                        summary
                    }
                }
            }
        } else {
            return Fragment {
                List.Item {
                    Paragraph {
                        Link(urlString: path(for: symbol), text: symbol.id.description)
                    }
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let descriptor = String(describing: type(of: symbol.api)).lowercased()

        return #"""
        <dt class="\#(descriptor)">
            <a href=\#(path(for: symbol)) title="\#(descriptor) - \#(symbol.id.description)">
                \#(softbreak(symbol.id.description))
            </a>
        </dt>
        <dd>
            \#(commonmark: symbol.documentation?.summary ?? "")
        </dd>
        """#
    }
}
