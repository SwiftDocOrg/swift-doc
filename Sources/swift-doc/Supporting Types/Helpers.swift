import Foundation
import SwiftDoc
import HTML

fileprivate let regex = try! NSRegularExpression(pattern: #"(?:([a-z]{2,})([A-Z]+))"#, options: [])

public func linkCodeElements(of html: String, for symbol: Symbol, in module: Module) -> String {
    let document = try! Document(string: html.description)!
    for element in document.search(xpath: "//code | //pre/code//span[contains(@class,'type')]") {
        guard let name = element.content else { continue }

//        let nameWithSoftBreaks = regex.stringByReplacingMatches(in: name, options: [], range: NSRange(name.startIndex..<name.endIndex, in: name), withTemplate: "$1\u{200B}$2")
//        element.content = nameWithSoftBreaks

        if let candidates = module.interface.symbolsGroupedByName[name],
            let candidate = candidates.filter({ $0 != symbol }).first,
            candidates.count == 1
        {
            let a = Element(name: "a")
            a["href"] = "/" + path(for: candidate)
            element.wrap(inside: a)
        }
    }

    return document.root?.description ?? html
}

public func sidebar(for html: String) -> String {
    let toc = Element(name: "ol")

    let document = try! Document(string: html.description)!
    for h2 in document.search(xpath: "//h2") {
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

        let a = Element(name: "a")
        a["href"] = "#\(section["id"]!)"
        a.content = h2.text

        li.insert(child: a)

        let nestedItems = section.search(xpath: "./details/summary").compactMap { summary -> Element? in
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

public func softbreak(_ string: String) -> String {
    return string.replacingOccurrences(of: ".", with: ".\u{200B}")
                 .replacingOccurrences(of: ":", with: ":\u{200B}")
}
