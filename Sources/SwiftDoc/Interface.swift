import Foundation
import SwiftSemantics
import struct SwiftSemantics.Protocol

public final class Interface: Codable {
    public let imports: [Import]
    public let symbols: [Symbol]

    public required init(imports: [Import], symbols: [Symbol]) {
        self.imports = imports
        self.symbols = symbols.filter { $0.isPublic }
    }

    // MARK: -

    public lazy var symbolsGroupedByIdentifier: [Symbol.ID: [Symbol]] = {
        return Dictionary(grouping: symbols, by: { $0.id })
    }()

    public lazy var symbolsGroupedByQualifiedName: [String: [Symbol]] = {
        return Dictionary(grouping: symbols, by: { $0.id.description })
    }()

    public private(set) lazy var topLevelSymbols: [Symbol] = {
        return symbols.filter { $0.api is Type || $0.id.pathComponents.isEmpty }
    }()

    public private(set) lazy var baseClasses: [Symbol] = {
        return symbols.filter { $0.api is Class &&
            typesInherited(by: $0).isEmpty }
    }()

    public private(set) lazy var classHierarchies: [Symbol: Set<Symbol>] = {
        var classClusters: [Symbol: Set<Symbol>] = [:]

        for baseClass in baseClasses {
            var superclasses = Set(CollectionOfOne(baseClass))

            while !superclasses.isEmpty {
                let subclasses = Set(superclasses.flatMap { typesInheriting(from: $0) }.filter { $0.isPublic })
                defer { superclasses = subclasses }
                classClusters[baseClass, default: []].formUnion(subclasses)
            }
        }

        return classClusters
    }()

    private lazy var extensionsByExtendedType: [String: [Extension]] = {
        return Dictionary(grouping: symbols.flatMap { $0.context.compactMap { $0 as? Extension } }) {
            $0.extendedType
        }
    }()

    public private(set) lazy var relationships: [Relationship] = {
        var relationships: Set<Relationship> = []
        for symbol in symbols {
            let lastDeclarationScope = symbol.context.last(where: { $0 is Extension || $0 is Symbol })

            if let container = lastDeclarationScope as? Symbol {
                let predicate: Relationship.Predicate

                switch container.api {
                case is Protocol:
                    if symbol.api.modifiers.contains(where: { $0.name == "optional" }) {
                        predicate = .optionalRequirementOf
                    } else {
                        predicate = .requirementOf
                    }
                default:
                    predicate = .memberOf
                }

                relationships.insert(Relationship(subject: symbol, predicate: predicate, object: container))
            }

            if let `extension` = lastDeclarationScope as? Extension {
                if let extended = symbols.first(where: { $0.api is Type &&  $0.id.matches(`extension`.extendedType) }) {

                    let predicate: Relationship.Predicate
                    switch extended.api {
                    case is Protocol:
                        predicate = .defaultImplementationOf
                    default:
                        predicate = .memberOf
                    }

                    relationships.insert(Relationship(subject: symbol, predicate: predicate, object: extended))
                }
            }

            if let type = symbol.api as? Type {
                var inheritedTypeNames: Set<String> = []
                inheritedTypeNames.formUnion(type.inheritance.flatMap { $0.split(separator: "&").map { $0.trimmingCharacters(in: .whitespaces) }
                })

                for `extension` in extensionsByExtendedType[symbol.id.description] ?? [] {
                    inheritedTypeNames.formUnion(`extension`.inheritance)
                }

                inheritedTypeNames = Set(inheritedTypeNames.flatMap { $0.split(separator: "&").map { $0.trimmingCharacters(in: .whitespaces) } })

                for name in inheritedTypeNames {
                    let inheritedTypes = symbols.filter({ ($0.api is Class || $0.api is Protocol) && $0.id.description == name })
                    if inheritedTypes.isEmpty {
                        let inherited = Symbol(api: Unknown(name: name), context: [], declaration: nil, documentation: nil, sourceLocation: nil)
                        relationships.insert(Relationship(subject: symbol, predicate: .conformsTo, object: inherited))
                    } else {
                        for inherited in inheritedTypes {
                            let predicate: Relationship.Predicate
                            if symbol.api is Class, inherited.api is Class {
                                predicate = .inheritsFrom
                            } else {
                                predicate = .conformsTo
                            }

                            relationships.insert(Relationship(subject: symbol, predicate: predicate, object: inherited))
                        }
                    }
                }
            }
        }

        return Array(relationships)
    }()

    public private(set) lazy var relationshipsBySubject: [Symbol.ID: [Relationship]] = {
        Dictionary(grouping: relationships, by: { $0.subject.id })
    }()

    public private(set) lazy var relationshipsByObject: [Symbol.ID: [Relationship]] = {
        Dictionary(grouping: relationships, by: { $0.object.id })
    }()

    // MARK: -

    public func members(of symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .memberOf }.map { $0.subject }.sorted() ?? []
    }

    public func requirements(of symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .requirementOf }.map { $0.subject }.sorted() ?? []
    }

    public func optionalRequirements(of symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .optionalRequirementOf }.map { $0.subject }.sorted() ?? []
    }

    public func typesInherited(by symbol: Symbol) -> [Symbol] {
        return relationshipsBySubject[symbol.id]?.filter { $0.predicate == .inheritsFrom }.map { $0.object }.sorted() ?? []
    }

    public func typesInheriting(from symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .inheritsFrom }.map { $0.subject }.sorted() ?? []
    }

    public func typesConformed(by symbol: Symbol) -> [Symbol] {
        return relationshipsBySubject[symbol.id]?.filter { $0.predicate == .conformsTo }.map { $0.object }.sorted() ?? []
    }

    public func typesConforming(to symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .conformsTo }.map { $0.subject }.sorted() ?? []
    }

    public func conditionalCounterparts(of symbol: Symbol) -> [Symbol] {
        return symbolsGroupedByIdentifier[symbol.id]?.filter { $0 != symbol }.sorted() ?? []
    }
}
