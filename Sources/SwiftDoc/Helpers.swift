import Foundation
//
//public func route(for symbol: Symbol) -> String {
//    return route(for: symbol.id)
//}
//
//public func route(for name: CustomStringConvertible) -> String {
//    return name.description.replacingOccurrences(of: ".", with: "_")
//}
//
//public func path(for symbol: Symbol, with baseURL: String) -> String {
//    return path(for: route(for: symbol), with: baseURL)
//}
//
//public func path(for identifier: CustomStringConvertible, with baseURL: String) -> String {
//    let url = URL(string: baseURL)?.appendingPathComponent("\(identifier)") ?? URL(string: "\(identifier)")
//    guard let string = url?.absoluteString else {
//        fatalError("Unable to construct path for \(identifier) with baseURL \(baseURL)")
//    }
//
//    return string
//}
