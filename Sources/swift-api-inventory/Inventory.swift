import SwiftSemantics
import SwiftDoc

func inventory(of module: Module) -> [String] {
    let publicSymbols = module.symbols
        .filter { $0.isPublic }
        
    let publicProtocolNames = Set(publicSymbols
        .filter { $0.declaration is Protocol }
        .map { $0.declaration.qualifiedName })
    
        
    let symbolsForPublicProtocols = module.symbols
        .filter { symbol -> Bool in
            guard let context = symbol.declaration.context else { return false }
            return publicProtocolNames.contains(context)
    }
    
    let inventory = publicSymbols + symbolsForPublicProtocols
    
    return inventory
        .sorted
        .compactMap { representation(of: $0, in: module) }
}

// TODO: Refactor
fileprivate func representation(of symbol: Symbol, in module: Module) -> String? {
    if symbol.declaration.modifiers.contains(where: { $0.name == "override" }) {
        return nil
    }

    let context = symbol.context.compactMap {
        switch $0 {
        case let `extension` as Extension:
            return `extension`.extendedType
        case let symbol as Symbol:
            return symbol.name
        default:
            return nil
        }
    }.joined(separator: ".")

    switch symbol.declaration {
    case let declaration as Variable:
        var representation = (
            declaration.attributes.map { $0.description } +
            declaration.nonAccessModifiers.map { $0.description } +
                ["var", context + "." + declaration.name]
        ).joined(separator: " ")

        if declaration.keyword == "let" ||
            declaration.modifiers.contains(where: { $0.name == "private" && $0.detail == "set" }) {
            representation += " { get }"
        } else {
            representation += " { get set }"
        }

        return representation
    case let declaration as Function:
        var representation = (
            declaration.attributes.map { $0.description } +
            declaration.nonAccessModifiers.map { $0.description } +
                [declaration.keyword, context + "." + declaration.identifier]
        ).joined(separator: " ")

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
              [declaration.keyword, context]
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
            [context + declaration.keyword]
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
            return "\(declaration.keyword) \(symbol.id)(\(associatedValue.map { "\($0.firstName ?? "_"): \($0.type ?? "_")\($0.variadic ? "..." : "")" }.joined(separator: ", ")))"
        } else {
            return "\(declaration.keyword) \(symbol.id)"
        }
    case let declaration:
        var representation = (
            declaration.attributes.map { $0.description } +
                declaration.nonAccessModifiers.map { $0.description } +
                [declaration.keyword, symbol.id.description]
            ).joined(separator: " ")

        if let genericParameters = (declaration as? Generic)?.genericParameters,
            !genericParameters.isEmpty
        {
            representation += "<\(genericParameters.map { $0.description }.joined(separator: ", "))>"
        }

        let inheritedTypes = module.typesInherited(by: symbol) + module.typesConformed(by: symbol)
        if !inheritedTypes.isEmpty {
            representation += ": \(inheritedTypes.map{ $0.id.description }.joined(separator: ", "))"
        }

        if let genericRequirements = (declaration as? Generic)?.genericRequirements,
            !genericRequirements.isEmpty
        {
            representation += " where \(genericRequirements.map { $0.description }.joined(separator: ", "))"
        }

        return representation
    }
}

