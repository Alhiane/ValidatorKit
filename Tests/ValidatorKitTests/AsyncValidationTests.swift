import Testing
import Foundation
@testable import ValidatorKit

/// A backend-style availability check used across the async tests.
private struct UsernameAvailableRule: AsyncValidationRule {
    let takenUsernames: Set<String>
    let message: String

    init(takenUsernames: Set<String>, message: String? = nil) {
        self.takenUsernames = takenUsernames
        self.message = message ?? "This username is already taken."
    }

    func validate(_ value: Any?) async -> ValidationError? {
        guard let username = value as? String else { return nil }
        return takenUsernames.contains(username) ? ValidationError(message: message) : nil
    }
}

/// Mutable probe for asserting whether an async rule body actually ran.
private final class AsyncProbe {
    private(set) var callCount = 0
    func mark() { callCount += 1 }
}

@Suite("Async Validation")
struct AsyncValidationTests {

    @Test("CustomAsyncRule returns an error when the closure fails")
    func testCustomAsyncRule() async {
        let rule = CustomAsyncRule(validation: { value in
            value as? String == "newuser"
        }, message: "Not available")
        let passing = await rule.validate("newuser")
        assert(passing == nil)
        let error = await rule.validate("taken")
        assert(error?.message == "Not available")
        let nilValue = await rule.validate(nil)
        assert(nilValue != nil)
    }

    @Test("CustomAsyncRule falls back to the localized custom message")
    func testCustomAsyncRuleDefaultMessage() async {
        let rule = CustomAsyncRule { _ in false }
        let error = await rule.validate("value")
        assert(error != nil)
        assert(error?.message.isEmpty == false)
    }

    @Test("validateAsync runs sync rules just like validate")
    func testValidateAsyncRunsSyncRules() async {
        let schema = ValidationSchema()
            .field("email").required().email()
            .ready()

        let result = await schema.validateAsync(["email": "not-an-email"])
        assert(!result.isValid)
        assert(result.errors["email"]?.count == 1)
    }

    @Test("validate ignores async rules entirely")
    func testSyncValidateSkipsAsyncRules() {
        let probe = AsyncProbe()
        let schema = ValidationSchema()
            .field("username")
            .customAsync(message: "This username is already taken.") { _ in
                probe.mark()
                return false
            }
            .ready()

        let result = schema.validate(["username": "taken"])
        assert(result.isValid)
        assert(probe.callCount == 0)
    }

    @Test("validateAsync collects async errors")
    func testValidateAsyncCollectsAsyncErrors() async {
        let schema = ValidationSchema()
            .field("username")
            .required()
            .customAsync(message: "This username is already taken.") { value in
                value as? String != "taken"
            }
            .ready()

        let taken = await schema.validateAsync(["username": "taken"])
        assert(!taken.isValid)
        assert(taken.errors["username"] == ["This username is already taken."])

        let available = await schema.validateAsync(["username": "newuser"])
        assert(available.isValid)
    }

    @Test("Async rules are skipped for fields that already failed sync rules")
    func testAsyncRulesSkippedAfterSyncFailure() async {
        let probe = AsyncProbe()
        let schema = ValidationSchema()
            .field("username")
            .required()
            .customAsync(message: "This username is already taken.") { _ in
                probe.mark()
                return false
            }
            .ready()

        let result = await schema.validateAsync(["username": ""])
        assert(!result.isValid)
        assert(result.errors["username"]?.count == 1)
        assert(probe.callCount == 0)
    }

    @Test("Every async rule on a field runs once sync rules pass")
    func testMultipleAsyncRulesPerField() async {
        let schema = ValidationSchema()
            .field("username")
            .customAsync(message: "Too similar to an existing name.") { _ in false }
            .customAsync(message: "This username is already taken.") { _ in false }
            .ready()

        let result = await schema.validateAsync(["username": "taken"])
        assert(result.errors["username"] == [
            "Too similar to an existing name.",
            "This username is already taken."
        ])
    }

    @Test("asyncRule registers any AsyncValidationRule conformance")
    func testAsyncRuleRegistration() async {
        let schema = ValidationSchema()
            .field("username")
            .required()
            .asyncRule(UsernameAvailableRule(takenUsernames: ["admin", "root"]))
            .ready()

        let taken = await schema.validateAsync(["username": "admin"])
        assert(taken.errors["username"] == ["This username is already taken."])

        let free = await schema.validateAsync(["username": "newuser"])
        assert(free.isValid)
    }

    @Test("Mixed schema reports sync and async errors across fields")
    func testMixedSchema() async {
        let schema = ValidationSchema()
            .field("email").required().email()
            .field("username")
            .required()
            .asyncRule(UsernameAvailableRule(takenUsernames: ["admin"]))
            .ready()

        let result = await schema.validateAsync(["email": "bad", "username": "admin"])
        assert(!result.isValid)
        assert(result.errors["email"]?.isEmpty == false)
        assert(result.errors["username"] == ["This username is already taken."])
    }
}
