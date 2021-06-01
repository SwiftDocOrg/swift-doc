import SwiftSemantics

public struct PlatformAvailability {
    public let platform: String
    public let version: String? // Semver/Version?

    /// Returns true when this represents the '*' case.
    public func isOtherPlatform() -> Bool { return version == nil && platform == "*"}
}

public enum AvailabilityKind: Equatable {
    case introduced(version: String)
    case obsoleted(version: String)
    case renamed(message: String)
    case message(message: String)
    case deprecated(version: String?)
    case unavailable
}

extension AvailabilityKind {
    init?(name: String?, value: String) {
        if let name = name {
            switch name {
                case "introduced":
                    self = .introduced(version: value)
                case "obsoleted":
                    self = .obsoleted(version: value)
                case "renamed":
                    self = .renamed(message: value)
                case "message":
                    self = .message(message: value)
                case "deprecated":
                    self = .deprecated(version: value)
                default:
                    return nil
            }
        } else {
            // check if unavailable or deprecated (kinds that don't require values)
            switch value {
                case "deprecated":
                    self = .deprecated(version: nil)
                case "unavailable":
                    self = .unavailable
                default:
                return nil
            }
            
        }
    }
}


public final class Availability {
    public let platforms: [PlatformAvailability]
    public let attributes: [AvailabilityKind]

    init(arguments: [Attribute.Argument]) {
        var platforms: [PlatformAvailability] = []
        var attributes: [AvailabilityKind] = []

        arguments.forEach { argument in
            if let availabilityKind = AvailabilityKind(name: argument.name, value: argument.value) {
                attributes.append(availabilityKind)
            } else {
                if let platform = PlatformAvailability(from: argument) {
                    platforms.append(platform)
                }
            }
        }

        self.platforms = platforms
        self.attributes = attributes
    }
}


extension PlatformAvailability {
    init?(from argument: Attribute.Argument) {

        // Shorthand from SwiftSemantics.Attribute.Argument will have both name and version in `value` property
        // example: @available(macOS 10.15, iOS 13, *)
        if argument.name == nil {
            let components = argument.value.split(separator: " ", maxSplits: 1)
            if components.count == 2,
                let platform = components.first,
                let version = components.last 
                {
                    self.platform = String(platform)
                    self.version = String(version)
                }
            else {
                // example: @available(iOS, deprecated: 13, renamed: "NewAndImprovedViewController")
                // this will be the `iOS` portion. Will also be the * in otherPlatform cases
                self.platform = argument.value
                self.version = nil
            }
        } else {
            // There is no name, so it includes a colon (:) so lets try an AvailabilityKind
            return nil
        }
    }
}
