import Foundation

extension StringProtocol {
    func indented(by spaces: Int = 2) -> String {
        return String(repeating: " ", count: spaces) + self
    }

    func leftPadded(to length: Int) -> String {
        guard count < length else { return String(self) }
        return String(repeating: " ", count: length - count) + self
    }

    func rightPadded(to length: Int) -> String {
        guard count < length else { return String(self) }
        return self + String(repeating: " ", count: length - count)
    }

    var escapingEmojiShortcodes: String {
        // Insert U+200B ZERO WIDTH SPACE
        // to prevent colon sequences from being interpreted as
        // emoji shortcodes (without wrapping with code element).
        // See: https://docs.github.com/en/github/writing-on-github/basic-writing-and-formatting-syntax#using-emoji
        return self.replacingOccurrences(of: ":", with: ":\u{200B}")
    }

    var escaped: String {
        #if os(macOS)
        return (CFXMLCreateStringByEscapingEntities(nil, String(self) as NSString, nil)! as NSString) as String
        #else
        return [
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("'", "&apos;"),
            ("\"", "&quot;"),
        ].reduce(String(self)) { (string, element) in
            string.replacingOccurrences(of: element.0, with: element.1)
        }
        #endif
    }

    func escapingOccurrences<Target>(of target: Target, options: String.CompareOptions = [], range searchRange: Range<String.Index>? = nil) -> String where Target : StringProtocol {
        return replacingOccurrences(of: target, with: target.escaped, options: options, range: searchRange)
    }

    func escapingOccurrences<Target>(of targets: [Target], options: String.CompareOptions = []) -> String where Target : StringProtocol {
        return targets.reduce(into: String(self)) { (result, target) in
            result = result.escapingOccurrences(of: target, options: options)
        }
    }
}
