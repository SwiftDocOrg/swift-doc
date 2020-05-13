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
                symbol.declaration.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }

    var html: HypertextLiteral.HTML {
        var html = try! SwiftSyntaxHighlighter.highlight(source: symbol.declaration, using: Xcode.self)
        html = linkCodeElements(of: html, for: symbol, in: module, with: baseURL)
        return HTML(html)
    }
}
