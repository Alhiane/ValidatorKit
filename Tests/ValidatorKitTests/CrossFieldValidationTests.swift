import Testing
import Foundation
@testable import ValidatorKit

@Suite("Cross-Field Validation Tests")
struct CrossFieldValidationTests {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - MatchesFieldRule

    @Test("Matches Field Rule")
    func testMatchesFieldRule() {
        let rule = MatchesFieldRule(otherField: "password")
        let object: [String: Any] = ["password": "secret123"]

        assert(rule.validate("secret123", in: object) == nil)
        assert(rule.validate("different", in: object) != nil)
        assert(rule.validate("", in: object) != nil)
        assert(rule.validate(nil, in: object) != nil)
    }

    @Test("Matches Field Rule with Missing Other Field")
    func testMatchesFieldRuleMissingOtherField() {
        let rule = MatchesFieldRule(otherField: "password")

        assert(rule.validate("secret123", in: [:]) != nil)
        assert(rule.validate("secret123", in: ["other": "secret123"]) != nil)
    }

    @Test("Matches Field Rule with Non-String Values")
    func testMatchesFieldRuleNonStringValues() {
        let rule = MatchesFieldRule(otherField: "quantity")
        let object: [String: Any] = ["quantity": 3]

        assert(rule.validate(3, in: object) == nil)
        assert(rule.validate(4, in: object) != nil)
        assert(rule.validate("3", in: object) != nil)
    }

    @Test("Matches Field via Schema (Confirm Password)")
    func testMatchesFieldSchema() {
        let schema = ValidationSchema()
            .field("password").required()
            .field("confirmPassword").required().matches("password")
            .ready()

        assert(schema.validate(["password": "secret123", "confirmPassword": "secret123"]).isValid)
        assert(!schema.validate(["password": "secret123", "confirmPassword": "nope"]).isValid)
        assert(!schema.validate(["password": "secret123"]).isValid)
    }

    @Test("Matches Field Custom Message")
    func testMatchesFieldCustomMessage() {
        let schema = ValidationSchema()
            .field("confirmPassword").matches("password", message: "Passwords must match")
            .ready()

        let result = schema.validate(["password": "a", "confirmPassword": "b"])
        assert(result.errors["confirmPassword"]?.first == "Passwords must match")
    }

    // MARK: - DateBeforeFieldRule / DateAfterFieldRule

    @Test("Date Before Field Rule")
    func testDateBeforeFieldRule() {
        let rule = DateBeforeFieldRule(otherField: "endDate")
        let object: [String: Any] = ["endDate": dateFormatter.date(from: "2023-12-31")!]

        assert(rule.validate(dateFormatter.date(from: "2023-01-01")!, in: object) == nil)
        assert(rule.validate(dateFormatter.date(from: "2024-01-01")!, in: object) != nil)
        // strictly before: same date fails
        assert(rule.validate(dateFormatter.date(from: "2023-12-31")!, in: object) != nil)
        assert(rule.validate(nil, in: object) != nil)
    }

    @Test("Date Before Field Rule with String Dates")
    func testDateBeforeFieldRuleStringDates() {
        let rule = DateBeforeFieldRule(otherField: "endDate")
        let object: [String: Any] = ["endDate": "2023-12-31"]

        assert(rule.validate("2023-01-01", in: object) == nil)
        assert(rule.validate("2024-01-01", in: object) != nil)
        assert(rule.validate("not a date", in: object) != nil)
        assert(rule.validate("2023-01-01", in: ["endDate": "not a date"]) != nil)
        assert(rule.validate("2023-01-01", in: [:]) != nil)
    }

    @Test("Date After Field Rule")
    func testDateAfterFieldRule() {
        let rule = DateAfterFieldRule(otherField: "startDate")
        let object: [String: Any] = ["startDate": dateFormatter.date(from: "2023-01-01")!]

        assert(rule.validate(dateFormatter.date(from: "2023-12-31")!, in: object) == nil)
        assert(rule.validate(dateFormatter.date(from: "2022-12-31")!, in: object) != nil)
        // strictly after: same date fails
        assert(rule.validate(dateFormatter.date(from: "2023-01-01")!, in: object) != nil)
        assert(rule.validate(nil, in: object) != nil)
    }

    @Test("Date Field Rules via Schema (Date Range)")
    func testDateFieldSchema() {
        let schema = ValidationSchema()
            .field("startDate").required().dateBefore("endDate")
            .field("endDate").required().dateAfter("startDate")
            .ready()

        assert(schema.validate(["startDate": "2023-01-01", "endDate": "2023-12-31"]).isValid)
        assert(!schema.validate(["startDate": "2023-12-31", "endDate": "2023-01-01"]).isValid)
        assert(!schema.validate(["startDate": "2023-06-15", "endDate": "2023-06-15"]).isValid)
    }

    @Test("Date Field Rules with Custom Format")
    func testDateFieldRulesCustomFormat() {
        let schema = ValidationSchema()
            .field("endDate").dateAfter("startDate", format: "dd/MM/yyyy")
            .ready()

        assert(schema.validate(["startDate": "01/01/2023", "endDate": "31/12/2023"]).isValid)
        assert(!schema.validate(["startDate": "31/12/2023", "endDate": "01/01/2023"]).isValid)
    }

    @Test("Date Field Rule Custom Message")
    func testDateFieldRuleCustomMessage() {
        let schema = ValidationSchema()
            .field("endDate").dateAfter("startDate", message: "End date must be after start date")
            .ready()

        let result = schema.validate(["startDate": "2023-12-31", "endDate": "2023-01-01"])
        assert(result.errors["endDate"]?.first == "End date must be after start date")
    }

    @Test("Cross-Field Rule via Single-Field validate")
    func testCrossFieldRuleSingleFieldFallback() {
        // called without the surrounding object, a cross-field rule cannot pass
        let rule = MatchesFieldRule(otherField: "password")
        assert(rule.validate("secret123") != nil)
    }

    @Test("Cross-Field Rules Alongside Single-Field Rules")
    func testMixedRules() {
        let schema = ValidationSchema()
            .field("email").required().email()
            .field("password").required().passwordStrength(minLength: 8)
            .field("confirmPassword").required().matches("password")
            .ready()

        let valid = schema.validate([
            "email": "test@example.com",
            "password": "supersecret",
            "confirmPassword": "supersecret"
        ])
        assert(valid.isValid)

        let invalid = schema.validate([
            "email": "not-an-email",
            "password": "supersecret",
            "confirmPassword": "mismatch"
        ])
        assert(!invalid.isValid)
        assert(invalid.errors["email"]?.isEmpty == false)
        assert(invalid.errors["confirmPassword"]?.isEmpty == false)
        assert(invalid.errors["password"] == nil)
    }
}
