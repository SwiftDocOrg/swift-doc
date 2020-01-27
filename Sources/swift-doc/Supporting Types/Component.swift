import CommonMarkBuilder

public protocol Component: BlockConvertible {
    var body: Fragment { get }
}

extension Component {
    public var blockValue: [Block & Node] {
        return body.blockValue
    }
}
