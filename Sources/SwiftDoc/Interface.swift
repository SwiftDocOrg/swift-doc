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

    private lazy var symbolsByIdentifier: [Symbol.ID: [Symbol]] = {
        return Dictionary(grouping: symbols, by: { $0.id })
    }()

    public private(set) lazy var topLevelSymbols: [Symbol] = {
        return symbols.filter { $0.declaration is Type || $0.id.pathComponents.isEmpty }
    }()

    public private(set) lazy var baseClasses: [Symbol] = {
        return symbols.filter { $0.declaration is Class &&
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

    public private(set) lazy var relationships: [Relationship] = {
        var relationships: Set<Relationship> = []
        for symbol in symbols {
            let `extension` = symbol.context.compactMap({ $0 as? Extension }).first

            if let container = symbol.context.compactMap({ $0 as? Symbol }).last {
                let predicate: Relationship.Predicate

                switch container.declaration {
                case is Protocol:
                    if symbol.declaration.modifiers.contains(where: { $0.name == "optional" }) {
                        predicate = .optionalRequirementOf
                    } else {
                        predicate = .requirementOf
                    }
                default:
                    predicate = .memberOf
                }

                relationships.insert(Relationship(subject: symbol, predicate: predicate, object: container))
            }

            if let `extension` = `extension` {
                for extended in symbols.filter({ $0.declaration is Type &&  $0.id.matches(`extension`.extendedType) }) {
                    let predicate: Relationship.Predicate
                    switch extended.declaration {
                    case is Protocol:
                        predicate = .defaultImplementationOf
                    default:
                        predicate = .memberOf
                    }

                    relationships.insert(Relationship(subject: symbol, predicate: predicate, object: extended))
                }
            }

            if let type = symbol.declaration as? Type {
                let inheritance = Set((type.inheritance + (`extension`?.inheritance ?? [])).flatMap { $0.split(separator: "&").map { $0.trimmingCharacters(in: .whitespaces) } })
                for name in inheritance {
                    let inheritedTypes = symbols.filter({ ($0.declaration is Class || $0.declaration is Protocol) && $0.id.matches(name) })
                    if inheritedTypes.isEmpty {
                        let inherited = Symbol(declaration: Unknown(name: name), context: [], documentation: nil, sourceLocation: nil)
                        relationships.insert(Relationship(subject: symbol, predicate: .inheritsFrom, object: inherited))
                    } else {
                        for inherited in inheritedTypes {
                            let predicate: Relationship.Predicate
                            if symbol.declaration is Class, inherited.declaration is Class {
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

    private lazy var relationshipsBySubject: [Symbol.ID: [Relationship]] = {
        Dictionary(grouping: relationships, by: { $0.subject.id })
    }()

    private lazy var relationshipsByObject: [Symbol.ID: [Relationship]] = {
        Dictionary(grouping: relationships, by: { $0.object.id })
    }()

    // MARK: -

    public func members(of symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .memberOf }.map { $0.subject } ?? []
    }

    public func requirements(of symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .requirementOf }.map { $0.subject } ?? []
    }

    public func optionalRequirements(of symbol: Symbol) -> [Symbol] {
        return relationshipsByObject[symbol.id]?.filter { $0.predicate == .optionalRequirementOf }.map { $0.subject } ?? []
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
        return symbolsByIdentifier[symbol.id]?.filter { $0 != symbol } ?? []
    }
}
