import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import HypertextLiteral
import SwiftSyntaxHighlighter
import Xcode

struct Declaration: Component {
    var symbol: Symbol
    var module: Module

    init(of symbol: Symbol, in module: Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var fragment: Fragment {
        Fragment {
            CodeBlock("swift") {
                symbol.declaration.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }

    var html: HypertextLiteral.HTML {
        var html = try! highlight(symbol.declaration, using: Xcode.self)
        html = linkCodeElements(of: html, for: symbol, in: module)
        return HTML(html)
    }
}
