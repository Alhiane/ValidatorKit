import Testing
import Combine
import Foundation
import ValidatorKit
@testable import ValidatorKitSwiftUI

/// A stand-in for a SwiftUI view model, with `@Published` fields to bind in tests.
@MainActor
private final class TestForm: ObservableObject {
    @Published var email: String = ""
    @Published var age: Double = 0
}

/// Scheduled on `DispatchQueue.main` via the internal `bind(_:to:debounce:scheduler:)`
/// overload, since `RunLoop.main` (the public API's default) only fires while a run loop
/// is actively spinning, which isn't the case in a headless test process. `RunLoop.main`
/// is exactly right for a real running SwiftUI app, just not for tests -- see
/// `bind(_:to:debounce:)`'s doc comment.
///
/// Deliberately generous relative to the sleeps below, to leave headroom against
/// scheduling jitter on a loaded CI runner: assertions that check "before the debounce"
/// sleep for a small fraction of this interval, and assertions that check "after the
/// debounce" sleep for several times it.
@MainActor
private let testDebounce: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(300)

@MainActor
@Suite("ObservableValidationSchema")
struct ObservableValidationSchemaTests {
    @Test("Does not re-validate before the debounce interval elapses")
    func testNoRevalidationBeforeDebounce() async throws {
        var validationCount = 0
        let schema = ValidationSchema()
            .field("email").custom(message: "invalid") { _ in
                validationCount += 1
                return true
            }
            .ready()

        let form = TestForm()
        let observable = ObservableValidationSchema(schema: schema)
        observable.bind("email", to: form.$email, debounce: testDebounce, scheduler: DispatchQueue.main)

        // Let the initial subscription settle before measuring.
        try await Task.sleep(nanoseconds: 600_000_000)
        validationCount = 0

        form.email = "a"
        try await Task.sleep(nanoseconds: 60_000_000) // well under the 300ms debounce
        assert(validationCount == 0, "expected no re-validation before the debounce interval elapses")
    }

    @Test("Re-validates once the debounce interval elapses")
    func testRevalidatesAfterDebounce() async throws {
        let schema = ValidationSchema()
            .field("email").required().email()
            .ready()

        let form = TestForm()
        let observable = ObservableValidationSchema(schema: schema)
        observable.bind("email", to: form.$email, debounce: testDebounce, scheduler: DispatchQueue.main)

        form.email = "alice@example.com"
        try await Task.sleep(nanoseconds: 600_000_000) // past the 300ms debounce

        assert(observable.isValid("email"))
        assert(observable.errors(for: "email").isEmpty)
    }

    @Test("Rapid successive emissions coalesce into a single re-validation")
    func testRapidEmissionsCoalesce() async throws {
        var validationCount = 0
        let schema = ValidationSchema()
            .field("email").custom(message: "invalid") { value in
                validationCount += 1
                return (value as? String)?.contains("@") == true
            }
            .ready()

        let form = TestForm()
        let observable = ObservableValidationSchema(schema: schema)
        observable.bind("email", to: form.$email, debounce: testDebounce, scheduler: DispatchQueue.main)

        try await Task.sleep(nanoseconds: 600_000_000) // let initial subscription settle
        validationCount = 0

        for keystroke in ["a", "al", "ali", "ali@", "ali@example.com"] {
            form.email = keystroke
        }
        try await Task.sleep(nanoseconds: 600_000_000) // past the debounce

        assert(validationCount == 1, "expected rapid keystrokes to coalesce into a single re-validation, got \(validationCount)")
        assert(observable.isValid("email"), "expected the schema to have settled on the last value, ali@example.com")
    }

    @Test("Multiple bound fields each contribute to the same schema-wide result")
    func testMultipleFieldsContributeToSharedResult() async throws {
        let schema = ValidationSchema()
            .field("email").required().email()
            .field("age").required().greaterThan(18)
            .ready()

        let form = TestForm()
        let observable = ObservableValidationSchema(schema: schema)
        observable.bind("email", to: form.$email, debounce: testDebounce, scheduler: DispatchQueue.main)
        observable.bind("age", to: form.$age, debounce: testDebounce, scheduler: DispatchQueue.main)

        form.email = "bob@example.com"
        form.age = 10 // fails greaterThan(18)
        try await Task.sleep(nanoseconds: 600_000_000)

        assert(observable.isValid("email"))
        assert(!observable.isValid("age"))
        assert(!observable.result.isValid, "schema-wide result should be invalid due to the age field")

        form.age = 21
        try await Task.sleep(nanoseconds: 600_000_000)

        assert(observable.isValid("age"))
        assert(observable.isValid("email"), "email's validity shouldn't be disturbed by re-validating age")
        assert(observable.result.isValid)
    }

    @Test("validateNow() forces immediate re-validation, bypassing the debounce")
    func testValidateNowBypassesDebounce() async throws {
        let schema = ValidationSchema()
            .field("age").required().greaterThan(18)
            .ready()

        let form = TestForm()
        let observable = ObservableValidationSchema(schema: schema)
        // A long debounce that would not fire within this test's lifetime on its own.
        observable.bind("age", to: form.$age, debounce: .seconds(30), scheduler: DispatchQueue.main)

        try await Task.sleep(nanoseconds: 600_000_000) // let the initial subscription settle
        form.age = 25

        // No sleep here: the 30s debounce has not fired.
        let forced = observable.validateNow()

        assert(forced.isValid, "validateNow() should immediately reflect the latest captured value")
        assert(observable.isValid("age"))
    }

    @Test("Public bind(_:to:debounce:) works against its default RunLoop.main scheduler")
    func testPublicBindDefaultsToRunLoopMain() {
        // Every other test in this file goes through the internal
        // bind(_:to:debounce:scheduler:) overload with DispatchQueue.main, since
        // RunLoop.main doesn't fire on its own in a headless test process (see the
        // doc comment on `bind(_:to:debounce:)`). This test instead calls the public
        // API exactly as a real app would -- no scheduler argument, so it defaults to
        // RunLoop.main -- and drives that run loop directly so its debounce timer can
        // actually fire.
        var validationCount = 0
        let schema = ValidationSchema()
            .field("email").custom(message: "invalid") { value in
                validationCount += 1
                return (value as? String)?.contains("@") == true
            }
            .ready()

        let form = TestForm()
        let observable = ObservableValidationSchema(schema: schema)
        observable.bind("email", to: form.$email, debounce: .milliseconds(150))

        RunLoop.main.run(until: Date().addingTimeInterval(0.4)) // let the initial subscription settle
        validationCount = 0

        form.email = "alice@example.com"
        RunLoop.main.run(until: Date().addingTimeInterval(0.4)) // past the 150ms debounce

        assert(validationCount == 1, "expected exactly one re-validation via the default RunLoop.main scheduler")
        assert(observable.isValid("email"))
    }
}
