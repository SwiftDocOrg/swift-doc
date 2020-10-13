import XCTest
import SwiftSemantics
import SwiftDoc

final class OperatorIdentifiersTests: XCTestCase {
    func testComparisonOperators() throws {
        let sourceFile: SourceFile = #"""
        func ==(lhs: (), rhs: ()) -> Bool { return true }
        func !=(lhs: (), rhs: ()) -> Bool { return false }
        func ===(lhs: (), rhs: ()) -> Bool { return true }
        func !==(lhs: (), rhs: ()) -> Bool { return false }
        func <(lhs: (), rhs: ()) -> Bool { return true }
        func <=(lhs: (), rhs: ()) -> Bool { return true }
        func >=(lhs: (), rhs: ()) -> Bool { return true }
        func >(lhs: (), rhs: ()) -> Bool { return true }
        func ~=(lhs: (), rhs: ()) -> Bool { return true }
        """#

        let operators = sourceFile.symbols.filter { ($0.api as? Function)?.isOperator == true }
        XCTAssertEqual(operators.count, 9)

        do {
            let symbol = operators[0]
            XCTAssertEqual(symbol.id.name, "infix ==")
            XCTAssertEqual(symbol.id.escaped, "infix-equals-equals")
        }

        do {
            let symbol = operators[1]
            XCTAssertEqual(symbol.id.name, "infix !=")
            XCTAssertEqual(symbol.id.escaped, "infix-bang-equals")
        }

        do {
            let symbol = operators[2]
            XCTAssertEqual(symbol.id.name, "infix ===")
            XCTAssertEqual(symbol.id.escaped, "infix-equals-equals-equals")
        }

        do {
            let symbol = operators[3]
            XCTAssertEqual(symbol.id.name, "infix !==")
            XCTAssertEqual(symbol.id.escaped, "infix-bang-equals-equals")
        }

        do {
            let symbol = operators[4]
            XCTAssertEqual(symbol.id.name, "infix <")
            XCTAssertEqual(symbol.id.escaped, "infix-lt")
        }

        do {
            let symbol = operators[5]
            XCTAssertEqual(symbol.id.name, "infix <=")
            XCTAssertEqual(symbol.id.escaped, "infix-lt-equals")
        }

        do {
            let symbol = operators[6]
            XCTAssertEqual(symbol.id.name, "infix >=")
            XCTAssertEqual(symbol.id.escaped, "infix-gt-equals")
        }

        do {
            let symbol = operators[7]
            XCTAssertEqual(symbol.id.name, "infix >")
            XCTAssertEqual(symbol.id.escaped, "infix-gt")
        }

        do {
            let symbol = operators[8]
            XCTAssertEqual(symbol.id.name, "infix ~=")
            XCTAssertEqual(symbol.id.escaped, "infix-tilde-equals")
        }
    }

    func testPrefixOperators() throws {
        let sourceFile: SourceFile = #"""
        prefix func + (number: Number) -> Number {
            return number >= 0 ? number : number.negated
        }

        prefix func - (number: Number) -> Number {
            return number.negated
        }
        """#

        let operators = sourceFile.symbols.filter { ($0.api as? Function)?.isOperator == true }
        XCTAssertEqual(operators.count, 2)


        do {
            let symbol = operators[0]
            XCTAssertEqual(symbol.id.name, "prefix +")
            XCTAssertEqual(symbol.id.escaped, "prefix-plus")
        }

        do {
            let symbol = operators[1]
            XCTAssertEqual(symbol.id.name, "prefix -")
            XCTAssertEqual(symbol.id.escaped, "prefix-minus")
        }
    }

    func testInfixOperators() throws {
        let sourceFile: SourceFile = #"""
        infix func ?? <T>(lhs: T?, rhs: T?) -> T? {
            if let lhs = lhs { return lhs } else { return rhs }
        }
        """#

        let operators = sourceFile.symbols.filter { ($0.api as? Function)?.isOperator == true }
        XCTAssertEqual(operators.count, 1)


        do {
            let symbol = operators[0]
            XCTAssertEqual(symbol.id.name, "infix ??")
            XCTAssertEqual(symbol.id.escaped, "infix-quest-quest")
        }
    }

    func testSuffixOperators() throws {
        let sourceFile: SourceFile = #"""
        postfix func ° (value: Double) -> Temperature {
            return Temperature(degrees: value)
        }
        """#

        let operators = sourceFile.symbols.filter { ($0.api as? Function)?.isOperator == true }
        XCTAssertEqual(operators.count, 1)


        do {
            let symbol = operators[0]
            XCTAssertEqual(symbol.id.name, "postfix °")
            XCTAssertEqual(symbol.id.escaped, "postfix-°")
        }
    }
}
