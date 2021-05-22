import SwiftSemantics
import SwiftDoc
import CommonMarkBuilder
import HypertextLiteral
import Foundation

struct GlobalPage: Page {
    let module: Module
    let name: String
    let symbols: [Symbol]
    let baseURL: String
    let datesLocale: Locale

    init(module: Module, name: String, symbols: [Symbol], baseURL: String, datesLocale: Locale) {
        self.module = module
        self.name = name
        self.symbols = symbols
        self.baseURL = baseURL
        self.datesLocale = datesLocale
    }

    // MARK: - Page

    var title: String {
        return name
    }
    
    var document: CommonMark.Document {
        return Document {
            ForEach(in: symbols) { symbol in
                Heading { symbol.id.description }
                Documentation(for: symbol, in: module, baseURL: baseURL)
            }
        }
    }

    var html: HypertextLiteral.HTML {
        let description: String

        let descriptions = Set(symbols.map { String(describing: type(of: $0.api)) })
        if descriptions.count == 1 {
            description = descriptions.first!
        } else {
            description = "Global"
        }

        return #"""
        <h1>
        <small>\#(description)</small>
        <span class="name">\#(softbreak(name))</span>
        </h1>

        \#(symbols.map { symbol in
        Documentation(for: symbol, in: module, baseURL: baseURL).html
        })
        """#
    }
}
