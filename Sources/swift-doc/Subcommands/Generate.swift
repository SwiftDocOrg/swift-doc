import ArgumentParser
import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol

extension AccessLevel: ExpressibleByArgument { }

extension SwiftDoc {
  struct Generate: ParsableCommand {
    enum Format: String, ExpressibleByArgument {
      case commonmark
      case html
    }

    struct Options: ParsableArguments {
      @Argument(help: "One or more paths to Swift files")
      var inputs: [String]

      @Option(name: [.long, .customShort("n")],
              help: "The name of the module")
      var moduleName: String

      @Option(name: .shortAndLong,
              default: ".build/documentation",
              help: "The path for generated output")
      var output: String

      @Option(name: .shortAndLong,
              default: .commonmark,
              help: "The output format")
      var format: Format

      @Option(name: .customLong("minimum-access-level"),
              default: .public,
              help: "The minimum access level for declarations to be included")
      var minimumAccessLevel: AccessLevel
        
      @Option(name: .customLong("base-url"),
              default: "/",
              help: "The base URL used for all relative URLs in generated documents.")
      var baseURL: String
    }

    static var configuration = CommandConfiguration(abstract: "Generates Swift documentation")

    @OptionGroup()
    var options: Options

    func run() throws {
      let module = try Module(name: options.moduleName, paths: options.inputs, minimumAccessLevel: options.minimumAccessLevel)

      let outputDirectoryURL = URL(fileURLWithPath: options.output)
      try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)

      do {
        let format = options.format

        var pages: [String: Page] = [:]

        var globals: [String: [Symbol]] = [:]
        for symbol in module.interface.topLevelSymbols.filter({ $0.isIncluded(minimumAccessLevel: options.minimumAccessLevel) }) {
          switch symbol.api {
          case is Class, is Enumeration, is Structure, is Protocol:
            pages[path(for: symbol)] = TypePage(module: module, symbol: symbol)
          case let `typealias` as Typealias:
            pages[path(for: `typealias`.name)] = TypealiasPage(module: module, symbol: symbol)
          case let function as Function where !function.isOperator:
            globals[function.name, default: []] += [symbol]
          case let variable as Variable:
            globals[variable.name, default: []] += [symbol]
          default:
            continue
          }
        }

        for (name, symbols) in globals {
          pages[path(for: name)] = GlobalPage(module: module, name: name, symbols: symbols)
        }

        guard !pages.isEmpty else { return }

        if pages.count == 1, let page = pages.first?.value {
          let filename: String
          switch format {
          case .commonmark:
            filename = "Home.md"
          case .html:
            filename = "index.html"
          }

          let url = outputDirectoryURL.appendingPathComponent(filename)
          try page.write(to: url, format: format, baseURL: options.baseURL)
        } else {
          switch format {
          case .commonmark:
            pages["Home"] = HomePage(module: module)
            pages["_Sidebar"] = SidebarPage(module: module)
            pages["_Footer"] = FooterPage()
          case .html:
            pages["Home"] = HomePage(module: module)
          }

          try pages.map { $0 }.parallelForEach {
            let filename: String
            switch format {
            case .commonmark:
              filename = "\($0.key).md"
            case .html where $0.key == "Home":
              filename = "index.html"
            case .html:
              filename = "\($0.key)/index.html"
            }

            let url = outputDirectoryURL.appendingPathComponent(filename)
            try $0.value.write(to: url, format: format, baseURL: options.baseURL)
          }
        }

        if case .html = format {
          let cssData = try fetchRemoteCSS()
          let cssURL = outputDirectoryURL.appendingPathComponent("all.css")
          try writeFile(cssData, to: cssURL)
        }

      } catch {
        logger.error("\(error)")
      }
    }
  }
}

func fetchRemoteCSS() throws -> Data {
  let url = URL(string: "https://raw.githubusercontent.com/SwiftDocOrg/swift-doc/master/Resources/all.min.css")!
  return try Data(contentsOf: url)
}
