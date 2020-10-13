import SwiftDoc
import Foundation
import SwiftSemantics
import struct SwiftSemantics.Protocol


typealias Router = (Symbol) -> String
//
//protocol Router {
//    func callAsFunction(_ symbol: Symbol) -> String
//    func callAsFunction(_ string: String) -> String
//}
//
//struct FlatRouter: Router {
//    var baseURL: URL?
//    var suffix: String?
//
//    init(baseURL: URL? = nil, suffix: String? = nil) {
//        self.baseURL = baseURL
//        self.suffix = suffix
//    }
//
//    func callAsFunction(_ string: String) -> String {
//        let suffix = self.suffix ?? ""
//        if var url = baseURL {
//            url.appendPathComponent(string)
//            return (url.isFileURL ? url.relativePath : url.absoluteString) + suffix
//        } else {
//            return string + suffix
//        }
//    }
//
//    func callAsFunction(_ symbol: Symbol) -> String {
//        if symbol.id.pathComponents.isEmpty {
//            return callAsFunction(symbol.id.description)
//        } else {
//            return callAsFunction(symbol.id.pathComponents.joined(separator: "_") + "#\(symbol.name)")
//        }
//    }
//}
//
//struct DocSetRouter: Router {
//    func callAsFunction(_ symbol: Symbol) -> String {
//        let identifier = symbol.id.description.replacingOccurrences(of: ".", with: "_")
//        return "//apple_ref/swift/\(symbol.entryType)/\(identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)"
//    }
//
//    func callAsFunction(_ string: String) -> String {
//        return ""
//    }
//}

//
//fileprivate extension Symbol {
//    // https://kapeli.com/docsets#supportedentrytypes
//    var entryType: String {
//        let parent = context.compactMap { $0 as? Symbol }.last?.api
//
//        switch api {
//        case is Class:
//            return "Class"
//        case is Initializer:
//            return "Method"
//        case is Enumeration:
//            return "Enum"
//        case is Enumeration.Case:
//            return "Value"
//        case let type as Type where type.inheritance.contains(where: { $0.hasSuffix("Error") }):
//            return "Error"
//        case is Function where parent is Type:
//            return "Method"
//        case is Function:
//            return "Function"
//        case is Variable where parent is Type:
//            return "Property"
//        case let variable as Variable where variable.keyword == "let":
//            return "Constant"
//        case is Variable:
//            return "Variable"
//        case is Operator:
//            return "Operator"
//        case is PrecedenceGroup:
//            return "Procedure" // FIXME: no direct matching entry type
//        case is Protocol:
//            return "Protocol"
//        case is Structure:
//            return "Struct"
//        case is Subscript:
//            return "Method"
//        case is Type, is AssociatedType:
//            return "Type"
//        default:
//            return "Entry"
//        }
//    }
//}
