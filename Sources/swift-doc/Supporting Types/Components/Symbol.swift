import CommonMarkBuilder
import SwiftDoc
import SwiftMarkup
import Foundation

public struct Symbol: Component {
    var symbol: SwiftDoc.Symbol
    var module: SwiftDoc.Module

    public init(_ symbol: SwiftDoc.Symbol, in module: SwiftDoc.Module) {
        self.symbol = symbol
        self.module = module
    }

    // MARK: - Component

    public var body: Fragment {
        Fragment {
            Heading { symbol.name }

            if symbol.conditions.isEmpty {
                Documentation(for: symbol)
            } else {
                ConditionalCompilationCounterparts(of: symbol, in: module)
            }
        }
    }
}
