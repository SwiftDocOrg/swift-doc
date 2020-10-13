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
}
