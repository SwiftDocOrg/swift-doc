import Foundation

public func route(for symbol: Symbol) -> String {
    return route(for: symbol.id)
}

public func route(for name: CustomStringConvertible) -> String {
    return name.description.replacingOccurrences(of: ".", with: "_")
                           .replacingOccurrences(of: " ", with: "-")
}

public func path(for symbol: Symbol, with baseURL: String) -> String {
    return path(for: route(for: symbol), with: baseURL)
}

public func path(for identifier: CustomStringConvertible, with baseURL: String) -> String {
    let tail: String = path(for: "\(identifier)")
    let url = URL(string: baseURL)?.appendingPathComponent(tail) ?? URL(string: tail)
    guard let string = url?.absoluteString else {
        fatalError("Unable to construct path for \(identifier) with baseURL \(baseURL)")
    }

    return string
}

public func path(for identifier: String) -> String {
    let kReservedCharacters: CharacterSet = [
      // Windows Reserved Characters
      "<", ">", ":", "\"", "/", "\\", "|", "?", "*",
    ]
    return identifier.components(separatedBy: kReservedCharacters).joined(separator: "_")
}
