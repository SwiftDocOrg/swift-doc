import SwiftSemantics
import SwiftDoc

func inventory(of module: Module) -> [String] {
    return module.symbols
        .filter { $0.declaration.isPublic }
        .sorted { $0.declaration.qualifiedName < $1.declaration.qualifiedName }
        .compactMap { representation(of: $0, in: module) }
}

// TODO: Refactor
fileprivate func representation(of symbol: Symbol, in module: Module) -> String? {
    if let declaration = symbol.declaration as? Modifiable,
        declaration.modifiers.contains(where: { $0.name == "override" })
    {
        return nil
    }

    if let declaration = symbol.declaration as? Enumeration.Case,
        !module.symbols.contains(where: { $0.declaration is Enumeration &&
                                          $0.declaration.isPublic &&
                                          $0.name == declaration.context })
    {
        return nil
    }

    switch symbol.declaration {
    case let declaration as Variable:
        var representation: String
        if let context = declaration.context {
            representation = (
                declaration.attributes.map { $0.description } +
                declaration.nonAccessModifiers.map { $0.description } +
                    ["var", context + "." + declaration.name]
            ).joined(separator: " ")
        } else {
            representation = (
                declaration.attributes.map { $0.description } +
                declaration.nonAccessModifiers.map { $0.description } +
                ["var", declaration.name]
            ).joined(separator: " ")
        }

        if declaration.keyword == "let" ||
            declaration.modifiers.contains(where: { $0.name == "private" && $0.detail == "set" }) {
            representation += " { get }"
        } else {
            representation += " { get set }"
        }

        return representation
    case let declaration as Function:
        var representation: String
        if let context = declaration.context {
            representation = (
                declaration.attributes.map { $0.description } +
                declaration.nonAccessModifiers.map { $0.description } +
                    [declaration.keyword, context + "." + declaration.identifier]
            ).joined(separator: " ")
        } else {
            representation = (
                declaration.attributes.map { $0.description } +
                declaration.nonAccessModifiers.map { $0.description } +
                    [declaration.keyword, declaration.identifier]
            ).joined(separator: " ")
        }

        if !declaration.genericParameters.isEmpty {
            representation += "<\(declaration.genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        representation += "(\(declaration.signature.input.map { "\($0.firstName ?? "_"): \($0.type ?? "_")\($0.variadic ? "..." : "")" }.joined(separator: ", ")))"

        if let throwsOrRethrowsKeyword = declaration.signature.throwsOrRethrowsKeyword {
            representation += " \(throwsOrRethrowsKeyword)"
        }

        if let output = declaration.signature.output {
            representation += " -> \(output)"
        }

        if !declaration.genericRequirements.isEmpty {
            representation += " where \(declaration.genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return representation
    case let declaration as Initializer:
          var representation = (
              declaration.attributes.map { $0.description } +
              declaration.nonAccessModifiers.map { $0.description } +
              [declaration.keyword, declaration.context!]
          ).joined(separator: " ")


          if declaration.optional {
              representation += "?"
          }

          if !declaration.genericParameters.isEmpty {
              representation += "<\(declaration.genericParameters.map { $0.description }.joined(separator: ", "))>"
          }

          representation += "(\(declaration.parameters.map { "\($0.firstName ?? "_"): \($0.type ?? "_")\($0.variadic ? "..." : "")" }.joined(separator: ", ")))"

          if !declaration.genericRequirements.isEmpty {
              representation += " where \(declaration.genericRequirements.map { $0.description }.joined(separator: ", "))"
          }

          return representation
    case let declaration as Subscript:
        var representation = (
            declaration.attributes.map { $0.description } +
            declaration.nonAccessModifiers.map { $0.description } +
            [(declaration.context ?? "") + declaration.keyword]
        ).joined(separator: " ")

        if !declaration.genericParameters.isEmpty {
            representation += "<\(declaration.genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        representation += "(\(declaration.indices.map { "\($0.firstName ?? "_"): \($0.type ?? "_")\($0.variadic ? "..." : "")" }.joined(separator: ", ")))"

        if !declaration.genericRequirements.isEmpty {
            representation += " where \(declaration.genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        if declaration.accessors.isEmpty {
            representation += " { get }"
        } else {
            representation += " { \(declaration.accessors.compactMap { $0.kind?.rawValue }.joined(separator: " ")) }"
        }

        return representation
    case let declaration as Enumeration.Case:
        if let associatedValue = declaration.associatedValue {
            return "\(declaration.keyword) \(declaration.qualifiedName)(\(associatedValue.map { "\($0.firstName ?? "_"): \($0.type ?? "_")\($0.variadic ? "..." : "")" }.joined(separator: ", ")))"
        } else {
            return "\(declaration.keyword) \(declaration.qualifiedName)"
        }
    case let declaration as API & Modifiable:
        var representation = (
            declaration.attributes.map { $0.description } +
                declaration.nonAccessModifiers.map { $0.description } +
                [declaration.keyword, declaration.qualifiedName]
            ).joined(separator: " ")

        if let genericParameters = (declaration as? Generic)?.genericParameters,
            !genericParameters.isEmpty
        {
            representation += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        if let inheritance = module.inheritance(of: symbol),
            !inheritance.isEmpty
        {
            representation += ": \(inheritance.joined(separator: ", "))"
        }

        if let genericRequirements = (declaration as? Generic)?.genericRequirements,
            !genericRequirements.isEmpty
        {
            representation += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return representation
    default:
        fatalError()
    }
}

