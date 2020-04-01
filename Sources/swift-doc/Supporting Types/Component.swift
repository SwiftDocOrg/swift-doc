import CommonMarkBuilder
import HypertextLiteral

public protocol Component: BlockConvertible, HypertextLiteralConvertible {
    var fragment: Fragment { get }
    var html: HypertextLiteral.HTML { get }
}

extension Component {
    public var blockValue: [Block & Node] {
        return fragment.blockValue
    }
}
