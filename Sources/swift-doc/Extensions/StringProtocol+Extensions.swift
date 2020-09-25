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
}
