import SwiftDoc
import SwiftMarkup
import CommonMarkBuilder

struct Documentation: Component {
    var symbol: Symbol

    init(for symbol: Symbol) {
        self.symbol = symbol
    }

    // MARK: - Component

    var body: Fragment {
        guard let documentation = symbol.documentation else { return Fragment { "" } }

        return Fragment {
            if !symbol.conditions.isEmpty {
                Fragment {
                    #"""
                    <dl>
                    <dt><code>\#(symbol.conditions.map { $0.description }.joined(separator: ", "))</code></dt>
                    <dd>

                    """#
                }
            }

            if documentation.summary != nil {
                Fragment { "\(documentation.summary!)" }
            }

            CodeBlock("swift") {
                "\(symbol.declaration)".trimmingCharacters(in: .whitespacesAndNewlines)
            }

            ForEach(in: documentation.discussionParts) { part in
                if part is SwiftMarkup.Documentation.Callout {
                    Callout(part as! SwiftMarkup.Documentation.Callout)
                } else {
                    Fragment { "\(part)" }
                }
            }

            if !documentation.parameters.isEmpty {
                Section {
                    Heading { "Parameters" }
                    List(of:  documentation.parameters) { parameter in
                        Fragment { "\(parameter.name): \(parameter.description)" }
                    }
                }
            }

            if documentation.throws != nil {
                Section {
                    Heading { "Throws" }
                    Fragment { documentation.throws! }
                }
            }

            if documentation.returns != nil {
                Section {
                    Heading { "Returns" }
                    Fragment { documentation.returns! }
                }
            }

            if !symbol.conditions.isEmpty {
                Fragment {
                    #"""

                    </dd>
                    </dl>
                    """#
                }
            }
        }
    }

    struct Callout: Component {
        var callout: SwiftMarkup.Documentation.Callout

        init(_ callout: SwiftMarkup.Documentation.Callout) {
            self.callout = callout
        }

        // MARK: - Component

        var body: Fragment {
            Fragment {
                """
                > \(callout.delimiter.rawValue.capitalized): \(callout.content)
                """
            }
        }
    }
}
