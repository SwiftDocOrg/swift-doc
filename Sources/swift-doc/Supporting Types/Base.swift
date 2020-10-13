//import Foundation
//import ArgumentParser
//
//enum Base {
//    case none
//    case rootDirectory
//    case currentDirectory
//    case externalURL(URL)
//}
//
//extension Base: ExpressibleByArgument {
//    init?(argument: String) {
//        switch argument {
//        case "":
//            self = .none
//        case "/":
//            self = .rootDirectory
//        case ".", "./":
//            self = .currentDirectory
//        default:
//            if let url = URL(string: argument) {
//                self = .externalURL(url)
//            } else {
//                
//                return nil
//            }
//        }
//    }
//}
