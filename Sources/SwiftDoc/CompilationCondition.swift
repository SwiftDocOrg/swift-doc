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
