import Foundation
import SwiftDoc
import SwiftSemantics
import SwiftMarkup
import CommonMarkBuilder
import HypertextLiteral
import SwiftSyntaxHighlighter
import Xcode

struct Documentation: Component {
    var symbol: Symbol
    var module: Module

    init(for symbol: Symbol, in module: Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    var fragment: Fragment {
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

            Declaration(of: symbol, in: module)

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

    var html: HypertextLiteral.HTML {
        guard let documentation = symbol.documentation else { return "" }

        var fragments: [HypertextLiteralConvertible] = []

        fragments.append(Declaration(of: symbol, in: module))

        if let summary = documentation.summary {
            fragments.append(#"""
            <div class="summary" role="doc-abstract">
                \#(commonmark: summary)
            </div>
            """# as HypertextLiteral.HTML)
        }

        if !documentation.discussionParts.isEmpty {
            fragments.append(#"""
            <div class="discussion">
                \#(documentation.discussionParts.compactMap { part -> HypertextLiteral.HTML? in
                    if let part = part as? SwiftMarkup.Documentation.Callout {
                        return Callout(part).html
                    } else if let part = part as? String {
                        if part.starts(with: "```"),
                            let codeBlock = (try? CommonMark.Document(part))?.children.compactMap({ $0 as? CodeBlock }).first,
                            (codeBlock.fenceInfo ?? "") == "" ||
                                codeBlock.fenceInfo?.compare("swift", options: .caseInsensitive) == .orderedSame,
                            let source = codeBlock.literal
                        {
                            var html = try! SwiftSyntaxHighlighter.highlight(source: source, using: Xcode.self)
                            html = linkCodeElements(of: html, for: symbol, in: module)
                            return HTML(html)
                        } else {
                            var html = (try! CommonMark.Document(part)).render(format: .html, options: [.unsafe])
                            html = linkCodeElements(of: html, for: symbol, in: module)
                            return HTML(html)
                        }
                    } else {
                        return nil
                    }
                })
            </div>
            """# as HypertextLiteral.HTML)
        }

        if !documentation.parameters.isEmpty {
            let typedParameters: [(name: String, type: String?, description: String)] = documentation.parameters.map { entry in
                let type: String?
                switch symbol.api {
                case let function as Function:
                    type = function.signature.input.first(where: { $0.firstName == entry.name || $0.secondName == entry.name })?.type
                case let initializer as Initializer:
                    type = initializer.parameters.first(where: { $0.firstName == entry.name || $0.secondName == entry.name })?.type
                case let `subscript` as Subscript:
                    type = `subscript`.indices.first(where: { $0.firstName == entry.name || $0.secondName == entry.name })?.type
                default:
                    type = nil
                }

                return (entry.name, type, entry.description)
            }

            fragments.append(#"""
              <h4>Parameters</h4>

              <table class="parameters">
                <thead hidden>
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Description</th>
                </tr>
                </thead>
                <tbody>
                  \#(typedParameters.map { entry -> HypertextLiteral.HTML in
                        let typeCell: HypertextLiteral.HTML
                        if let type = entry.type {
                            typeCell = #"<td><code class="type">\#(softbreak(type))</code></td>"# as HypertextLiteral.HTML
                        } else {
                            typeCell = "<td></td>" as HypertextLiteral.HTML
                        }

                      return #"""
                      <tr>
                          <th>\#(softbreak(entry.name))</th>
                          \#(typeCell)</td>
                          <td>\#(commonmark: entry.description)</td>
                      </tr>
                      """# as HypertextLiteral.HTML
                      })
                </tbody>
              </table>
              """# as HypertextLiteral.HTML)
        }

        if let `throws` = documentation.throws {
            fragments.append(#"""
              <h4>Throws</h4>
              \#(commonmark: `throws`)
            """# as HypertextLiteral.HTML)
        }

        if let `returns` = documentation.returns {
            fragments.append(#"""
              <h4>Returns</h4>
              \#(commonmark: `returns`)
            """# as HypertextLiteral.HTML)
        }

        return #"""
        \#(fragments.map { $0.html })
        """#
    }
}

extension Documentation {
    struct Callout: Component {
        var callout: SwiftMarkup.Documentation.Callout

        init(_ callout: SwiftMarkup.Documentation.Callout) {
            self.callout = callout
        }

        // MARK: - Component

        var fragment: Fragment {
            Fragment {
                """
                > \(callout.delimiter.rawValue.capitalized): \(callout.content)
                """
            }
        }

        var html: HypertextLiteral.HTML {
            return #"""
            <aside class=\#(callout.delimiter.rawValue)>
                \#(commonmark: callout.content)
            </aside>
            """#
        }
    }
}
