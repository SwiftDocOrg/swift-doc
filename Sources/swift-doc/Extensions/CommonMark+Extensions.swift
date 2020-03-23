import CommonMark
import HypertextLiteral

extension CommonMark.Document: HypertextLiteralConvertible {
    public var html: HypertextLiteral.HTML {
        HypertextLiteral.HTML(render(format: .html, options: .unsafe))
    }
}
