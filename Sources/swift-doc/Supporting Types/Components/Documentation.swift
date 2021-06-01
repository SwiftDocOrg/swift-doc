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
    let baseURL: String

    init(for symbol: Symbol, in module: Module, baseURL: String) {
        self.symbol = symbol
        self.module = module
        self.baseURL = baseURL
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
                Fragment { "\(documentation.summary!.description.escapingEmojiShortcodes)" }
            }

            Declaration(of: symbol, in: module, baseURL: baseURL)

            ForEach(in: documentation.discussionParts) { part in
                DiscussionPart(part, for: symbol, in: module, baseURL: baseURL)
            }

            if !documentation.parameters.isEmpty {
                Section {
                    Heading { "Parameters" }
                    List(of:  documentation.parameters) { parameter in
                        Fragment { "\(parameter.name): \(parameter.content.description)" }
                    }
                }
            }

            if documentation.throws != nil {
                Section {
                    Heading { "Throws" }
                    Fragment { documentation.throws!.description.escapingEmojiShortcodes }
                }
            }

            if documentation.returns != nil {
                Section {
                    Heading { "Returns" }
                    Fragment { documentation.returns!.description.escapingEmojiShortcodes }
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

        fragments.append(Declaration(of: symbol, in: module, baseURL: baseURL))

        if let summary = documentation.summary {
            fragments.append(#"""
            <div class="summary" role="doc-abstract">
                \#(commonmark: summary.description)
            </div>
            """# as HypertextLiteral.HTML)
        }

        if !documentation.discussionParts.isEmpty {
            fragments.append(#"""
            <div class="discussion">
                \#(documentation.discussionParts.compactMap { part -> HTML? in
                    DiscussionPart(part, for: symbol, in: module, baseURL: baseURL).html
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

                return (entry.name, type, entry.content.description)
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
                          \#(typeCell)
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
              \#(commonmark: `throws`.description)
            """# as HypertextLiteral.HTML)
        }

        if let `returns` = documentation.returns {
            fragments.append(#"""
              <h4>Returns</h4>
              \#(commonmark: `returns`.description)
            """# as HypertextLiteral.HTML)
        }

        return #"""
        \#(fragments.map { $0.html })
        """#
    }
}

extension Documentation {
    struct DiscussionPart: Component {
        var symbol: Symbol
        var module: Module
        var part: SwiftMarkup.DiscussionPart
        let baseURL: String

        init(_ part: SwiftMarkup.DiscussionPart, for symbol: Symbol, in module: Module, baseURL: String) {
            self.part = part
            self.symbol = symbol
            self.module = module
            self.baseURL = baseURL
        }

        // MARK: - Component

        var fragment: Fragment {
            switch part {
            case .blockQuote(let blockquote):
                return Fragment {
                    blockquote.render(format: .commonmark)
                }
            case .callout(let callout):
                return Fragment {
                    BlockQuote {
                        "\(callout.delimiter.rawValue.capitalized): \(callout.content)"
                    }
                }
            case .codeBlock(let codeBlock):
                return Fragment {
                    codeBlock.render(format: .commonmark)
                }
            case .heading(let heading):
                return Fragment {
                    heading.render(format: .commonmark)
                }
            case .htmlBlock(let htmlBlock):
                return Fragment {
                    htmlBlock.literal ?? ""
                }
            case .list(let list):
                return Fragment {
                    list.render(format: .commonmark)
                }
            case .paragraph(let paragraph):
                return Fragment {
                    paragraph.render(format: .commonmark)
                }
            case .thematicBreak(let thematicBreak):
                return Fragment {
                    thematicBreak.render(format: .commonmark)
                }
            }
        }

        var html: HypertextLiteral.HTML {
            switch part {
            case .blockQuote(let blockquote):
                return HTML(blockquote.render(format: .html, options: [.unsafe]))
            case .callout(let callout):
                return #"""
                <aside class=\#(callout.delimiter.rawValue.lowercased()) title=\#(callout.delimiter.rawValue)>
                    \#(commonmark: callout.content)
                </aside>
                """# as HTML
            case .codeBlock(let codeBlock):
                if (codeBlock.fenceInfo ?? "") == "" ||
                        codeBlock.fenceInfo?.compare("swift", options: .caseInsensitive) == .orderedSame,
                    let source = codeBlock.literal
                {
                    var html = try! SwiftSyntaxHighlighter.highlight(source: source, using: Xcode.self)
                    html = linkCodeElements(of: html, for: symbol, in: module, with: baseURL)
                    return HTML(html)
                } else {
                    var html = codeBlock.render(format: .html, options: [.unsafe])
                    html = linkCodeElements(of: html, for: symbol, in: module, with: baseURL)
                    return HTML(html)
                }
            case .heading(let heading):
                return HTML(heading.render(format: .html, options: [.unsafe]))
            case .htmlBlock(let htmlBlock):
                return HTML(htmlBlock.literal ?? "")
            case .list(let list):
                return HTML(list.render(format: .html, options: [.unsafe]))
            case .paragraph(let paragraph):
                return HTML(paragraph.render(format: .html, options: [.unsafe]))
            case .thematicBreak(let thematicBreak):
                return HTML(thematicBreak.render(format: .html, options: [.unsafe]))

            }
        }
    }
}
