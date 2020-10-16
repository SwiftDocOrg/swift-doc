import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral
import Highlighter
import Xcode

struct Declaration: Component {
    var symbol: Symbol
    var module: Module
    let baseURL: String

    init(of symbol: Symbol, in module: Module, baseURL: String) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL
    }

    // MARK: - Component

    var fragment: Fragment {
        Fragment {
            CodeBlock("swift") {
                symbol.declaration.map { $0.text }.joined()
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let code = symbol.declaration.map { $0.html }.joined()

        return #"""
        <div class="declaration">
        <pre class="highlight"><code>\#(unsafeUnescaped: code)</code></pre>
        </div>
        """#
    }
}
