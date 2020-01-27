import SwiftSemantics

protocol Generic {
    var genericParameters: [GenericParameter] { get }
    var genericRequirements: [GenericRequirement] { get }
}

extension Class: Generic {}
extension Enumeration: Generic {}
extension Function: Generic {}
extension Initializer: Generic {}
extension Structure: Generic {}
extension Subscript: Generic {}
extension Typealias: Generic {}

