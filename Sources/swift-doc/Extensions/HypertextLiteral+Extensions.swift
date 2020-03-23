import HypertextLiteral
import CommonMark

extension HypertextLiteral.HTML.StringInterpolation {
    mutating func appendInterpolation(commonmark: String) {
        guard let document = try? Document(commonmark) else { return }
        appendLiteral(document.render(format: .html, options: [.unsafe]))
    }
}
