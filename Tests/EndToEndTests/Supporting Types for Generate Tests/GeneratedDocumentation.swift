import Foundation
import HTML
import CommonMark

/// A protocol which needs to be implemented by the different documentation generators. It provides an API to operate
/// on the generated documentation.
protocol GeneratedDocumentation {

    /// The name of the output format. This needs to be the name name like the value passed to swift-doc's `format` option.
    static var outputFormat: String { get }

    init(directory: URL)

    var directory: URL { get }

    func symbol(_ symbolType: GenerateTestCase.SymbolType) -> Page?
}

protocol Page {
    var type: String? { get }

    var name: String? { get }
}



struct GeneratedHTMLDocumentation: GeneratedDocumentation {

    static let outputFormat = "html"

    let directory: URL

    func symbol(_ symbolType: GenerateTestCase.SymbolType) -> Page? {
        switch symbolType {
        case .class(let name):
            return page(for: name, ofType: "Class")
        case .typealias(let name):
            return page(for: name, ofType: "Typealias")
        case .struct(let name):
            return page(for: name, ofType: "Structure")
        case .enum(let name):
            return page(for: name, ofType: "Enumeration")
        case .protocol(let name):
            return page(for: name, ofType: "Protocol")
        case .function(let name):
            return page(for: name, ofType: "Function")
        case .variable(let name):
            return page(for: name, ofType: "Variable")
        case .extension(let name):
            return page(for: name, ofType: "Extensions on")
        }
    }

    private func page(for symbolName: String, ofType type: String) -> Page? {
        guard let page = page(named: symbolName) else { return nil }
        guard page.type == type else { return nil }

        return page
    }

    private func page(named name: String) -> HtmlPage? {
        let fileUrl = directory.appendingPathComponent(fileName(forSymbol: name)).appendingPathComponent("index.html")
        guard
            FileManager.default.isReadableFile(atPath: fileUrl.path),
            let contents = try? String(contentsOf: fileUrl),
            let document = try? HTML.Document(string: contents)
            else { return nil }

        return HtmlPage(document: document)
    }

    private func fileName(forSymbol symbolName: String) -> String {
        symbolName
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: " ", with: "-")
            .components(separatedBy: reservedCharactersInFilenames).joined(separator: "_")
    }

    private struct HtmlPage: Page {
        let document: HTML.Document

        var type: String? {
            let results = document.search(xpath: "//h1/small")
            assert(results.count == 1)
            return results.first?.content
        }

        var name: String? {
            let results = document.search(xpath: "//h1/code")
            assert(results.count == 1)
            return results.first?.content
        }
    }
}


struct GeneratedCommonMarkDocumentation: GeneratedDocumentation {

    static let outputFormat = "commonmark"

    let directory: URL

    func symbol(_ symbolType: GenerateTestCase.SymbolType) -> Page? {
        switch symbolType {
        case .class(let name):
            return page(for: name, ofType: "class")
        case .typealias(let name):
            return page(for: name, ofType: "typealias")
        case .struct(let name):
            return page(for: name, ofType: "struct")
        case .enum(let name):
            return page(for: name, ofType: "enum")
        case .protocol(let name):
            return page(for: name, ofType: "protocol")
        case .function(let name):
            return page(for: name, ofType: "func")
        case .variable(let name):
            return page(for: name, ofType: "var") ?? page(for: name, ofType: "let")
        case .extension(let name):
            return page(for: name, ofType: "extension")
        }
    }

    private func page(for symbolName: String, ofType type: String) -> Page? {
        guard let page = page(named: symbolName) else { return nil }
        guard page.type == type else { return nil }

        return page
    }

    private func page(named name: String) -> CommonMarkPage? {
        let fileUrl = directory.appendingPathComponent("\(name).md")
        guard
            FileManager.default.isReadableFile(atPath: fileUrl.path),
            let contents = try? String(contentsOf: fileUrl),
            let document = try? CommonMark.Document(contents)
            else { return nil }

        return CommonMarkPage(document: document)
    }

    private func fileName(forSymbol symbolName: String) -> String {
        symbolName
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: " ", with: "-")
            .components(separatedBy: reservedCharactersInFilenames).joined(separator: "_")
    }

    private struct CommonMarkPage: Page {
        let document: CommonMark.Document

        private var headingElement: Heading? {
            document.children.first(where: { ($0 as? Heading)?.level == 1 }) as? Heading
        }

        var type: String? {
            // Our CommonMark pages don't give a hint of the actual type of a documentation page. That's why we extract
            // it via a regex out of the declaration. Not very nice, but works for now.
            guard
                let name = self.name,
                let code = document.children.first(where: { $0 is CodeBlock}) as? CodeBlock,
                let codeContents = code.literal,
                let extractionRegex = try? NSRegularExpression(pattern: "([a-z]+) \(name)")
            else { return nil }

            guard
                let match = extractionRegex.firstMatch(in: codeContents, range: NSRange(location: 0, length: codeContents.utf16.count)),
                match.numberOfRanges > 0,
                let range = Range(match.range(at: 1), in: codeContents)
            else { return nil }

            return String(codeContents[range])
        }

        var name: String? {
            headingElement?.children.compactMap { ($0 as? Literal)?.literal }.joined()
        }
    }
}

private let reservedCharactersInFilenames: CharacterSet = [
    // Windows Reserved Characters
    "<", ">", ":", "\"", "/", "\\", "|", "?", "*",
]
