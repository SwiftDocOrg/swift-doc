import ArgumentParser
import Foundation
import DCOV
import SwiftDoc

extension SwiftDocCommand {
    struct Coverage: ParsableCommand {
        struct Options: ParsableArguments {
            @Argument(help: "One or more paths to Swift files")
            var inputs: [String]

            @Option(name: .shortAndLong,
                    help: "The path for generated report")
            var output: String?
        }

        static var configuration = CommandConfiguration(abstract: "Generates documentation coverage statistics for Swift files")

        @OptionGroup()
        var options: Options

        func run() throws {
            let module = try Module(paths: options.inputs)
            let report = Report(module: module)

            if let output = options.output {
                let encoder = JSONEncoder()
                let data = try encoder.encode(report)
                try data.write(to: URL(fileURLWithPath: output))
            } else {
                print(["Total".rightPadded(to: 60), format(report.totals.percentage)].joined(separator: "\t"))
                for (file, ratio) in report.coverageBySourceFile.sorted(by: { $0.0 < $1.0 }) {
                    print(["  - \(file)".rightPadded(to: 60), format(ratio.percentage)].joined(separator: "\t"))
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

fileprivate extension String {
    func leftPadded(to length: Int) -> String {
        guard count < length else { return self }
        return String(repeating: " ", count: length - count) + self
    }

    func rightPadded(to length: Int) -> String {
        guard count < length else { return self }
        return self + String(repeating: " ", count: length - count)
    }
}

fileprivate func format(_ percentage: Double) -> String {
    return String(format: "%0.2f %%", percentage).leftPadded(to: 8)
}
