import ArgumentParser
import Foundation
import DCOV
import SwiftDoc

extension SwiftDoc {
    struct Coverage: ParsableCommand {
        struct Options: ParsableArguments {
            @Argument(help: "One or more paths to a directory containing Swift files.")
            var inputs: [String]

            @Option(name: .shortAndLong,
                    help: "The path for generated report")
            var output: String?

            @Option(name: .long,
                    help: "The minimum access level of the symbols considered for coverage statistics.")
            var minimumAccessLevel: AccessLevel = .public
        }

        static var configuration = CommandConfiguration(abstract: "Generates documentation coverage statistics for Swift files")

        @OptionGroup()
        var options: Options

        func run() throws {
            let module = try Module(paths: options.inputs)
            let report = Report(module: module, symbolFilter: options.minimumAccessLevel.includes(symbol:))

            if let output = options.output {
                let encoder = JSONEncoder()
                let data = try encoder.encode(report)
                try data.write(to: URL(fileURLWithPath: output))
            } else {
                print(["Total".rightPadded(to: 60), format(percentage: report.totals.percentage)].joined(separator: "\t"))
                for (file, ratio) in report.coverageBySourceFile.sorted(by: { $0.0 < $1.0 }) {
                    print(["  - \(file)".rightPadded(to: 60), format(percentage: ratio.percentage)].joined(separator: "\t"))
                }

                print("")

                print("Undocumented Symbols:")
                for entry in report.entries.sorted(by: { $0.name < $1.name }) where !entry.documented {
                    print("- \(entry.name)")
                }
            }
        }
    }
}

// MARK: -

fileprivate func format(percentage: Double) -> String {
    return String(format: "%0.2f %%", percentage).leftPadded(to: 8)
}
