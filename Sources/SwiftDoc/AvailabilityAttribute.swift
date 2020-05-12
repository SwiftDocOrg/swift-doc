import SwiftSemantics

public enum AvailabilityAttributeType: Equatable {
    /// all platforms (marked with *)
    case allPlatforms
    case platform(platform: String, version: String?)
    case introduced(version: String?)
    case deprecated(version: String?)
    case obsoleted(version: String?)
    case renamed(message: String)
    case message(message: String)
    case unavailable(version: String?)
}

extension AvailabilityAttributeType {
    init?(from argument: Attribute.Argument) {
        switch argument.value {
        case "*":
            self = .allPlatforms
            return
        case "introduced":
            self = .introduced(version: nil)
            return
        case "deprecated":
            self = .deprecated(version: nil)
            return
        case "obsoleted":
            self = .obsoleted(version: nil)          
            return
        case "unavailable":
            self = .unavailable(version: nil)          
            return
        case "iOS", "macOS", "tvOS", "watchOS", "swift":
            self = .platform(platform: argument.value, version: nil)
        default: 
            guard let name = argument.name else {
                return nil
            }

            switch name {    
            case "iOS", "macOS", "tvOS", "watchOS", "swift":
                self = .platform(platform: name, version: argument.value)
            case "introduced":
                self = .introduced(version: argument.value)
            case "deprecated":
                self = .deprecated(version: argument.value)
            case "obsoleted":
                self = .obsoleted(version: argument.value)          
            case "renamed":
                self = .renamed(message: argument.value)          
            case "message":
                self = .message(message: argument.value)               
            default: return nil
            }
        }
    }
}

public final class AvailabilityAttribute {
    public let attributes: [AvailabilityAttributeType]

    init(arguments: [Attribute.Argument]) {
        attributes = arguments.compactMap { AvailabilityAttributeType.init(from: $0) }
    }
}