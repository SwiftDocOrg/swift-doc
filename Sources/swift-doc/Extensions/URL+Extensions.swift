import Foundation

extension URL {
    /// Returns a canonical version of the URL
    /// by performing the following transformations:
    ///
    /// * Removing the scheme component, if present
    ///   ```
    ///   https://example.com/mona/LinkedList → example.com/mona/LinkedList
    ///   ```
    /// * Removing the userinfo component (preceded by `@`), if present:
    ///   ```
    ///   git@example.com/mona/LinkedList → example.com/mona/LinkedList
    ///   ```
    /// * Removing the port subcomponent, if present:
    ///   ```
    ///   example.com:443/mona/LinkedList → example.com/mona/LinkedList
    ///   ```
    /// * Replacing the colon (`:`) preceding the path component in "`scp`-style" URLs:
    ///   ```
    ///   git@example.com:mona/LinkedList.git → example.com/mona/LinkedList
    ///   ```
    /// * Expanding the tilde (`~`) to the provided user, if applicable:
    ///   ```
    ///   ssh://mona@example.com/~/LinkedList.git → example.com/~mona/LinkedList
    ///   ```
    /// * Removing percent-encoding from the path component, if applicable:
    ///   ```
    ///   example.com/mona/%F0%9F%94%97List → example.com/mona/🔗List
    ///   ```
    /// * Removing the `.git` file extension from the path component, if present:
    ///   ```
    ///   example.com/mona/LinkedList.git → example.com/mona/LinkedList
    ///   ```
    /// * Removing the trailing slash (`/`) in the path component, if present:
    ///   ```
    ///   example.com/mona/LinkedList/ → example.com/mona/LinkedList
    ///   ```
    /// * Removing the fragment component (preceded by `#`), if present:
    ///   ```
    ///   example.com/mona/LinkedList#installation → example.com/mona/LinkedList
    ///   ```
    /// * Removing the query component (preceded by `?`), if present:
    ///   ```
    ///   example.com/mona/LinkedList?utm_source=forums.swift.org → example.com/mona/LinkedList
    ///   ```
    /// * Adding a leading slash (`/`) for `file://` URLs and absolute file paths:
    ///   ```
    ///   file:///Users/mona/LinkedList → /Users/mona/LinkedList
    ///   ```
    var canonicalized: URL {
        var string = absoluteString.precomposedStringWithCanonicalMapping.lowercased()

        // Remove the scheme component, if present.
        let detectedScheme = string.dropSchemeComponentPrefixIfPresent()

        // Remove the userinfo subcomponent (user / password), if present.
        if case (let user, _)? = string.dropUserinfoSubcomponentPrefixIfPresent() {
            // If a user was provided, perform tilde expansion, if applicable.
            string.replaceFirstOccurenceIfPresent(of: "/~/", with: "/~\(user)/")
        }

        // Remove the port subcomponent, if present.
        string.removePortComponentIfPresent()

        // Remove the fragment component, if present.
        string.removeFragmentComponentIfPresent()

        // Remove the query component, if present.
        string.removeQueryComponentIfPresent()

        // Accomodate "`scp`-style" SSH URLs
        if detectedScheme == nil || detectedScheme == "ssh" {
            string.replaceFirstOccurenceIfPresent(of: ":", before: string.firstIndex(of: "/"), with: "/")
        }

        // Split the remaining string into path components,
        // filtering out empty path components and removing valid percent encodings.
        var components = string.split(omittingEmptySubsequences: true, whereSeparator: isSeparator)
            .compactMap { $0.removingPercentEncoding ?? String($0) }

        // Remove the `.git` suffix from the last path component.
        var lastPathComponent = components.popLast() ?? ""
        lastPathComponent.removeSuffixIfPresent(".git")
        components.append(lastPathComponent)

        string = components.joined(separator: "/")

        // Prepend a leading slash for file URLs and paths
        if detectedScheme == "file" || string.first.flatMap(isSeparator) ?? false {
            string.insert("/", at: string.startIndex)
        }

        if detectedScheme == "http" {
            string = "http://" + string
        } else {
            string = "https://" + string
        }

        return URL(string: string) ?? self
    }
}

fileprivate let isSeparator: (Character) -> Bool = { $0 == "/" || $0 == "\\" }

private extension Character {
    var isDigit: Bool {
        switch self {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            return true
        default:
            return false
        }
    }

    var isAllowedInURLScheme: Bool {
        return isLetter || self.isDigit || self == "+" || self == "-" || self == "."
    }
}

private extension String {
    @discardableResult
    mutating func removePrefixIfPresent<T: StringProtocol>(_ prefix: T) -> Bool {
        guard hasPrefix(prefix) else { return false }
        removeFirst(prefix.count)
        return true
    }

    @discardableResult
    mutating func removeSuffixIfPresent<T: StringProtocol>(_ suffix: T) -> Bool {
        guard hasSuffix(suffix) else { return false }
        removeLast(suffix.count)
        return true
    }

    @discardableResult
    mutating func dropSchemeComponentPrefixIfPresent() -> String? {
        if let rangeOfDelimiter = range(of: "://"),
           self[startIndex].isLetter,
           self[..<rangeOfDelimiter.lowerBound].allSatisfy({ $0.isAllowedInURLScheme })
        {
            defer { self.removeSubrange(..<rangeOfDelimiter.upperBound) }

            return String(self[..<rangeOfDelimiter.lowerBound])
        }

        return nil
    }

    @discardableResult
    mutating func dropUserinfoSubcomponentPrefixIfPresent() -> (user: String, password: String?)? {
        if let indexOfAtSign = firstIndex(of: "@"),
           let indexOfFirstPathComponent = firstIndex(where: isSeparator),
           indexOfAtSign < indexOfFirstPathComponent
        {
            defer { self.removeSubrange(...indexOfAtSign) }

            let userinfo = self[..<indexOfAtSign]
            var components = userinfo.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
            guard components.count > 0 else { return nil }
            let user = String(components.removeFirst())
            let password = components.last.map(String.init)

            return (user, password)
        }

        return nil
    }

    @discardableResult
    mutating func removePortComponentIfPresent() -> Bool {
        if let indexOfFirstPathComponent = firstIndex(where: isSeparator),
           let startIndexOfPort = firstIndex(of: ":"),
           startIndexOfPort < endIndex,
           let endIndexOfPort = self[index(after: startIndexOfPort)...].lastIndex(where: { $0.isDigit }),
           endIndexOfPort <= indexOfFirstPathComponent
        {
            self.removeSubrange(startIndexOfPort ... endIndexOfPort)
            return true
        }

        return false
    }

    @discardableResult
    mutating func removeFragmentComponentIfPresent() -> Bool {
        if let index = firstIndex(of: "#") {
            self.removeSubrange(index...)
        }

        return false
    }

    @discardableResult
    mutating func removeQueryComponentIfPresent() -> Bool {
        if let index = firstIndex(of: "?") {
            self.removeSubrange(index...)
        }

        return false
    }

    @discardableResult
    mutating func replaceFirstOccurenceIfPresent<T: StringProtocol, U: StringProtocol>(
        of string: T,
        before index: Index? = nil,
        with replacement: U
    ) -> Bool {
        guard let range = range(of: string) else { return false }

        if let index = index, range.lowerBound >= index {
            return false
        }

        self.replaceSubrange(range, with: replacement)
        return true
    }
}

