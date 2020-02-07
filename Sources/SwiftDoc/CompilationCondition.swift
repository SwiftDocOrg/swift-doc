import SwiftSemantics

public struct CompilationCondition: Hashable, Codable {
    public let block: ConditionalCompilationBlock
    public let branch: ConditionalCompilationBlock.Branch

    init(block: ConditionalCompilationBlock, branch: ConditionalCompilationBlock.Branch) {
        precondition(block.branches.contains(branch))
        self.block = block
        self.branch = branch
    }
}

// MARK: - CustomStringConvertible

extension CompilationCondition: CustomStringConvertible {
    public var description: String {
        if let condition = branch.condition {
            return condition
        } else {
            return branch.condition ?? "!(\(block.branches.compactMap { $0.condition }.map { "(\($0))"}.joined(separator: "&&")))"
        }
    }
}
