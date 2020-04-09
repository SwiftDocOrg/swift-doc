import Foundation
import SwiftDoc
import HTML

public func linkCodeElements(of html: String, for symbol: Symbol, in module: Module) -> String {
    let document = try! Document(string: html.description)!
    for element in document.search(xpath: "//code | //pre/code//span[contains(@class,'type')]") {
        guard let name = element.content else { continue }

        if let candidates = module.interface.symbolsGroupedByQualifiedName[name],
            candidates.count == 1,
            let candidate = candidates.filter({ $0 != symbol }).first
        {
            let a = Element(name: "a")
            a["href"] = path(for: candidate)
            element.wrap(inside: a)
        }
    }

    return document.root?.description ?? html
}

public func sidebar(for html: String) -> String {
    let toc = Element(name: "ol")

    let document = try! Document(string: html.description)!
    for h2 in document.search(xpath: "//section/h2") {
        guard let section = h2.parent as? Element else { continue }

        let li = Element(name: "li")

        var className: String? = nil
        switch section["id"]?.lowercased() {
        case "initializers":
            className = "initializer"
        case "enumeration cases":
            className = "case"
        case "methods":
            className = "method"
        case "properties":
            className = "property"
        case "nested type aliases":
            className = "typealias"
        default:
            break
        }

        if let id = section["id"] {
            let a = Element(name: "a")
            a["href"] = "#\(id)"
            a.content = h2.text
            li.insert(child: a)
        } else {
            li.content = h2.text
        }


        let nestedItems = section.search(xpath: "./h3 | ./div/h3").compactMap { summary -> Element? in
            guard let article = summary.parent as? Element else { return nil }

            let li = Element(name: "li")

            if let className = className {
                li["class"] = className
            }

            let a = Element(name: "a")
            a["href"] = "#\(article["id"]!)"
            a.content = summary.text

            li.insert(child: a)
            return li
        }

        if !nestedItems.isEmpty {
            let ul = Element(name: "ul")
            nestedItems.forEach { ul.insert(child: $0) }
            li.insert(child: ul)
        }


        toc.insert(child: li)
    }

    return toc.description
}

fileprivate let pattern = #"(?:([a-z]{2,})([A-Z]+))"#
fileprivate let regex = try! NSRegularExpression(pattern: pattern, options: [])

public func softbreak(_ string: String) -> String {
    let string = string.replacingOccurrences(of: ".", with: ".\u{200B}")
                       .replacingOccurrences(of: ":", with: ":\u{200B}")

    return regex.stringByReplacingMatches(in: string, options: [], range: NSRange(string.startIndex..<string.endIndex, in: string), withTemplate: "$1\u{200B}$2")
}
