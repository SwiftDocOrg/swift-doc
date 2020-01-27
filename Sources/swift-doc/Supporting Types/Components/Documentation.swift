import SwiftDoc
import SwiftMarkup
import CommonMarkBuilder

struct Documentation: Component {
    var symbol: SwiftDoc.Symbol

    init(for symbol: SwiftDoc.Symbol) {
        self.symbol = symbol
    }

    // MARK: - Component

    var body: Fragment {
        Fragment {
            if symbol.documentation.summary != nil {
                Fragment { "\(symbol.documentation.summary!)" }
            }

            CodeBlock("swift") {
                "\(symbol.declaration)".trimmingCharacters(in: .whitespacesAndNewlines)
            }

            ForEach(in: symbol.documentation.discussionParts) { part in
                if part is SwiftMarkup.Documentation.Callout {
                    Callout(part as! SwiftMarkup.Documentation.Callout)
                } else {
                    Fragment { "\(part)" }
                }
            }

            if !symbol.documentation.parameters.isEmpty {
                Section {
                    Heading { "Parameters" }
                    List(of:  symbol.documentation.parameters) { parameter in
                        Fragment { "\(parameter.name): \(parameter.description)" }
                    }
                }
            }

            if symbol.documentation.throws != nil {
                Section {
                    Heading { "Throws" }
                    Fragment { symbol.documentation.throws! }
                }
            }

            if symbol.documentation.returns != nil {
                Section {
                    Heading { "Returns" }
                    Fragment { symbol.documentation.returns! }
                }
            }
        }
    }
}
