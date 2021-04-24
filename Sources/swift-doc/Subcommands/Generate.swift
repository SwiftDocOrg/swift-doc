import ArgumentParser
import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol

#if os(Linux)
import FoundationNetworking
#endif

extension SwiftDoc {
  struct Generate: ParsableCommand {
    enum Format: String, ExpressibleByArgument {
      case commonmark
      case html
    }

    struct Options: ParsableArguments {
      @Argument(help: "One or more paths to a directory containing Swift files.")
      var inputs: [String]

      @Option(name: [.long, .customShort("n")],
              help: "The name of the module")
      var moduleName: String

      @Option(name: .shortAndLong,
              help: "The path for generated output")
      var output: String = ".build/documentation"

      @Option(name: .shortAndLong,
              help: "The output format")
      var format: Format = .commonmark

      @Option(name: .customLong("base-url"),
              help: "The base URL used for all relative URLs in generated documents.")
      var baseURL: String = "/"

      @Option(name: .long,
              help: "The minimum access level of the symbols included in generated documentation.")
      var minimumAccessLevel: AccessLevel = .public
    }

    static var configuration = CommandConfiguration(abstract: "Generates Swift documentation")

    @OptionGroup()
    var options: Options

    func run() throws {
      for directory in options.inputs {
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: directory, isDirectory: &isDirectory) {
          logger.warning("Input path \(directory) does not exist.")
        } else if !isDirectory.boolValue {
          logger.warning("Input path \(directory) is not a directory.")
        }
      }

      let module = try Module(name: options.moduleName, paths: options.inputs)
      let baseURL = options.baseURL

      let outputDirectoryURL = URL(fileURLWithPath: options.output)
      try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true)

      do {
        let format = options.format

        var pages: [String: Page] = [:]

        var globals: [String: [Symbol]] = [:]
        let symbolFilter = options.minimumAccessLevel.includes(symbol:)
        for symbol in module.interface.topLevelSymbols.filter(symbolFilter) {
          switch symbol.api {
          case is Class, is Enumeration, is Structure, is Protocol:
            pages[route(for: symbol)] = TypePage(module: module, symbol: symbol, baseURL: baseURL, includingChildren: symbolFilter)
          case let `typealias` as Typealias:
            pages[route(for: `typealias`.name)] = TypealiasPage(module: module, symbol: symbol, baseURL: baseURL)
          case is Operator:
            pages[route(for: symbol)] = OperatorPage(module: module, symbol: symbol, baseURL: baseURL)
          case let function as Function where !function.isOperator:
            globals[function.name, default: []] += [symbol]
          case let variable as Variable:
            globals[variable.name, default: []] += [symbol]
          default:
            continue
          }
        }

        // Extensions on external types.
        var symbolsByExternalType: [String: [Symbol]] = [:]
        for symbol in module.interface.symbols.filter(symbolFilter) {
          guard let extensionDeclaration = symbol.context.first as? Extension, symbol.context.count == 1 else { continue }
          guard module.interface.symbols(named: extensionDeclaration.extendedType, resolvingTypealiases: true).isEmpty else { continue }
          symbolsByExternalType[extensionDeclaration.extendedType, default: []] += [symbol]
        }
        for (typeName, symbols) in symbolsByExternalType {
          pages[route(for: typeName)] = ExternalTypePage(module: module, externalType: typeName, symbols: symbols, baseURL: baseURL)
        }

        for (name, symbols) in globals {
            pages[route(for: name)] = GlobalPage(module: module, name: name, symbols: symbols, baseURL: baseURL)
        }

        guard !pages.isEmpty else {
            logger.warning("No public API symbols were found at the specified path. No output was written.")
            if options.minimumAccessLevel == .public {
              logger.warning("By default, swift-doc only includes public declarations. Maybe you want to use --minimum-access-level to include non-public declarations?")
            }
            return
        }

        if pages.count == 1, let page = pages.first?.value {
          let filename: String
          switch format {
          case .commonmark:
            filename = "Home.md"
          case .html:
            filename = "index.html"
          }

          let url = outputDirectoryURL.appendingPathComponent(filename)
          try page.write(to: url, format: format)
        } else {
          switch format {
          case .commonmark:
            pages["Home"] = HomePage(module: module, externalTypes: Array(symbolsByExternalType.keys), baseURL: baseURL, symbolFilter: symbolFilter)
            pages["_Sidebar"] = SidebarPage(module: module, externalTypes: Set(symbolsByExternalType.keys), baseURL: baseURL, symbolFilter: symbolFilter)
            pages["_Footer"] = FooterPage(baseURL: baseURL)
          case .html:
            pages["Home"] = HomePage(module: module, externalTypes: Array(symbolsByExternalType.keys), baseURL: baseURL, symbolFilter: symbolFilter)
          }

          try pages.map { $0 }.parallelForEach {
            let filename: String
            switch format {
            case .commonmark:
              filename = "\(path(for: $0.key)).md"
            case .html where $0.key == "Home":
              filename = "index.html"
            case .html:
              filename = "\(path(for: $0.key))/index.html"
            }

            let url = outputDirectoryURL.appendingPathComponent(filename)
            try $0.value.write(to: url, format: format)
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
