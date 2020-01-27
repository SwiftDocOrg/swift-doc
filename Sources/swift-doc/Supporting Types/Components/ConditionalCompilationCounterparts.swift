import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import SwiftSemantics

struct ConditionalCompilationCounterparts: Component {
    var symbol: SwiftDoc.Symbol
    var module: SwiftDoc.Module

    public init(of symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    public var body: Fragment {
        // TODO: Support multiple nesting of conditional compilation blocks
        let counterpartsByFirstCondition = Dictionary(grouping: module.conditionalCounterparts(of: symbol)) { $0.conditions.first?.block }.filter { $0.key != nil }

        guard !counterpartsByFirstCondition.isEmpty else { return Fragment { "" } }

        func counterpart(for branch: ConditionalCompilationBlock.Branch, in block: ConditionalCompilationBlock) -> SwiftDoc.Symbol? {
            counterpartsByFirstCondition[block]?.first(where: { $0.conditions.first?.branch == branch })
        }

        return Fragment {
            // FIXME: Use HTML block
            Fragment { "<dl>" }

            ForEach(in: counterpartsByFirstCondition.keys) { block in
                ForEach(in: block!.branches) { branch in
                    Counterpart(counterpart(for: branch, in: block!), in: branch)
                }
            }

            Fragment { "</dl>" }
        }
    }
}

// MARK: -

fileprivate struct Counterpart: Component {
    var counterpart: SwiftDoc.Symbol?
    var branch: ConditionalCompilationBlock.Branch

    init(_ counterpart: SwiftDoc.Symbol?, in branch: ConditionalCompilationBlock.Branch) {
        self.counterpart = counterpart
        self.branch = branch
    }

    var body: Fragment {
        Fragment {
            Fragment { "<dt><code>\(branch)</code></dt>" }

            Fragment { "<dd>" }

            if counterpart != nil {
                Documentation(for: counterpart!)
            } else {
                Paragraph { Emphasis { "(No declaration)" }}
            }

            Fragment { "</dd>" }
        }
    }
}
