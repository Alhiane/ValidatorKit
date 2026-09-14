import Testing
import Foundation
@testable import ValidatorKit

@Suite("Numeric Comparison Rule Tests")
struct NumericComparisonRuleTests {
    @Test("Greater Than Rule for Int, Double and Numeric String")
    func testGreaterThanRuleForNumericTypes() {
        let rule = GreaterThanRule(minValue: 18)
        assert(rule.validate(20) == nil)
        assert(rule.validate(15) != nil)
        assert(rule.validate(20.0) == nil)
        assert(rule.validate(18.0) != nil)
        assert(rule.validate("20") == nil)
        assert(rule.validate("18") != nil)
    }

    @Test("Greater Than Rule rejects non-numeric values")
    func testGreaterThanRuleInvalidType() {
        let rule = GreaterThanRule(minValue: 18)
        assert(rule.validate(nil) != nil)
        assert(rule.validate("not-a-number") != nil)
        assert(rule.validate(true) != nil)
    }

    @Test("Less Than Rule for Int, Double and Numeric String")
    func testLessThanRuleForNumericTypes() {
        let rule = LessThanRule(maxValue: 100)
        assert(rule.validate(99) == nil)
        assert(rule.validate(101) != nil)
        assert(rule.validate(99.0) == nil)
        assert(rule.validate(100.0) != nil)
        assert(rule.validate("99") == nil)
        assert(rule.validate("100") != nil)
    }

    @Test("Less Than Rule rejects non-numeric values")
    func testLessThanRuleInvalidType() {
        let rule = LessThanRule(maxValue: 100)
        assert(rule.validate(nil) != nil)
        assert(rule.validate("not-a-number") != nil)
        assert(rule.validate(true) != nil)
    }

    // Matches README quick-start: .field("age").required().greaterThan(18)
    @Test("Greater Than Schema Validation with Int Value")
    func testGreaterThanSchemaWithIntValue() {
        let schema = ValidationSchema().field("age").required().greaterThan(18).ready()
        assert(schema.validate(["age": 20]).isValid)
        assert(!schema.validate(["age": 16]).isValid)
    }
}
