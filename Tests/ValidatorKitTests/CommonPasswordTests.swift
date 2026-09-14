import Testing
import Foundation
@testable import ValidatorKit

// common-password rejection for password fields
@Suite("Common Password Tests")
struct CommonPasswordTests {
    @Test("Password Strength Rule rejects a common password when rejectCommon is enabled")
    func testPasswordStrengthRuleRejectCommon() {
        let rule = PasswordStrengthRule(minLength: 8, rejectCommon: true)
        assert(rule.validate("password") != nil)
        assert(rule.validate("Qwerty123") != nil) // case-insensitive match
        assert(rule.validate("Tr0ub4dor&3") == nil)
    }

    @Test("Password Strength Rule accepts a common password when rejectCommon is disabled")
    func testPasswordStrengthRuleRejectCommonDisabled() {
        let rule = PasswordStrengthRule(minLength: 8)
        assert(rule.validate("password") == nil)
    }

    @Test("Not Common Password Rule rejects well-known common passwords")
    func testNotCommonPasswordRuleRejectsCommon() {
        let rule = NotCommonPasswordRule()
        assert(rule.validate("123456") != nil)
        assert(rule.validate("iloveyou") != nil)
        assert(rule.validate("StarWars") != nil) // case-insensitive match
    }

    @Test("Not Common Password Rule accepts uncommon passwords")
    func testNotCommonPasswordRuleAcceptsUncommon() {
        let rule = NotCommonPasswordRule()
        assert(rule.validate("correct-horse-battery-staple") == nil)
        assert(rule.validate("Tr0ub4dor&3") == nil)
    }

    @Test("Not Common Password Rule rejects non-string values")
    func testNotCommonPasswordRuleRejectsNonString() {
        let rule = NotCommonPasswordRule()
        assert(rule.validate(nil) != nil)
        assert(rule.validate(123456) != nil)
    }

    @Test("Not Common Password Rule honours a custom password list")
    func testNotCommonPasswordRuleCustomList() {
        let rule = NotCommonPasswordRule(commonPasswords: ["hunter2"])
        assert(rule.validate("hunter2") != nil)
        assert(rule.validate("password") == nil) // built-in list no longer applies
    }

    @Test("Not Common Password Rule matches a mixed-case custom list case-insensitively")
    func testNotCommonPasswordRuleCustomListMixedCase() {
        let rule = NotCommonPasswordRule(commonPasswords: ["Hunter2"])
        assert(rule.validate("Hunter2") != nil)
        assert(rule.validate("hunter2") != nil)
        assert(rule.validate("HUNTER2") != nil)
        assert(rule.validate("correct-horse-battery-staple") == nil)
    }

    @Test("Password Strength Rule returns the too-common message when rejecting a common password")
    func testPasswordStrengthRuleRejectCommonMessage() {
        let rule = PasswordStrengthRule(minLength: 8, rejectCommon: true)
        assert(rule.validate("password")?.message == "Password is too common.")
        // other strength failures keep the generic strength message
        assert(rule.validate("s3cure!Pass") == nil)
        assert(rule.validate("short")?.message == "Password does not meet the required strength.")
    }

    @Test("Not Common Password via Schema")
    func testNotCommonPasswordSchema() {
        let schema = ValidationSchema()
            .field("password").required().notCommonPassword()
            .ready()

        assert(schema.validate(["password": "letmein"]).isValid == false)
        assert(schema.validate(["password": "s3cure!Pass"]).isValid)
    }

    @Test("Not Common Password via Schema honours a custom password list")
    func testNotCommonPasswordSchemaCustomList() {
        let schema = ValidationSchema()
            .field("password").required().notCommonPassword(commonPasswords: ["hunter2"])
            .ready()

        // "hunter2" isn't in the default list, but is rejected via the custom list.
        assert(schema.validate(["password": "hunter2"]).isValid == false)
        // A default-list password is accepted since the custom list replaces it.
        assert(schema.validate(["password": "password"]).isValid)
    }
}
