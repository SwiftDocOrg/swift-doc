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
    let symbolFilter: (Symbol) -> Bool

    init(of symbol: Symbol, in module: Module, baseURL: String, includingOtherSymbols symbolFilter: @escaping (Symbol) -> Bool) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL
        self.symbolFilter = symbolFilter
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

        let html = linkTypes(of: code, for: symbol, in: module, with: baseURL, includingSymbols: symbolFilter)

        return #"""
        <div class="declaration">
        <pre class="highlight"><code>\#(unsafeUnescaped: html)</code></pre>
        </div>
        """#
    }
}
