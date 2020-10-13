import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral

struct Abstract: Component {
    var symbol: Symbol
    var router: Router

    init(for symbol: Symbol, with router: @escaping Router) {
        self.symbol = symbol
        self.router = router
    }
    
    // MARK: - Component

    var fragment: Fragment {
        if let summary = symbol.documentation?.summary {
            return Fragment {
                List.Item {
                    Fragment {
                        #"""
                        [\#(symbol.id)](\#(router(symbol))):
                        \#(summary)
                        """#
                    }
                }
            }
        } else {
            return Fragment {
                List.Item {
                    Paragraph {
                        Link(urlString: router(symbol), text: symbol.id.description)
                    }
                }
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let descriptor = String(describing: type(of: symbol.api)).lowercased()

        return #"""
        <dt class="\#(descriptor)">
            <a href=\#(""/*path(for: symbol)*/) title="\#(descriptor) - \#(symbol.id.description)">
                \#(softbreak(symbol.id.description))
            </a>
        </dt>
        <dd>
            \#(commonmark: symbol.documentation?.summary ?? "")
        </dd>
        """#
    }
}
