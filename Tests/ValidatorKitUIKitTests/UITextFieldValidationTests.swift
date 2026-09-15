//
//  UITextFieldValidationTests.swift
//  ValidatorKitUIKitTests
//
//  Created by Alhiane on 14/9/2026.
//

#if os(iOS) || os(tvOS)

import Testing
import UIKit
import ValidatorKit
@testable import ValidatorKitUIKit

@MainActor
@Suite("UITextField Validation Tests")
struct UITextFieldValidationTests {
    @Test("validate() returns the error from a single attached rule")
    func testValidateSingleRule() {
        let field = UITextField()
        field.text = "not-an-email"
        field.addRule(EmailRule())

        let errors = field.validate()
        assert(errors.count == 1)
    }

    @Test("validate() aggregates errors from multiple attached rules")
    func testValidateMultipleRules() {
        let field = UITextField()
        field.text = ""
        field.addRules([RequiredRule(), EmailRule()])

        let errors = field.validate()
        assert(errors.count == 2)
    }

    @Test("validate() returns no errors once every rule passes")
    func testValidateAllRulesPass() {
        let field = UITextField()
        field.text = "test@example.com"
        field.addRule(EmailRule())

        assert(field.validate().isEmpty)
    }

    // NOTE on the four tests below: `UIControl.sendActions(for:)` requires a live
    // `UIApplication` to actually dispatch target-action pairs. SPM test bundles
    // have no host app, so the call silently no-ops instead of invoking the
    // target — see #49. Rather than dispatch through `sendActions(for:)`, these
    // tests verify the two things that actually matter and don't require a host
    // app: (1) that `validateOnInputChange` registers/deregisters the
    // `.editingChanged` target-action pair correctly (via
    // `actions(forTarget:forControlEvent:)`), and (2) that the registered
    // handler itself behaves correctly when invoked, using `perform(Selector:)`
    // with the *actual registered selector name* (never a hardcoded string) to
    // call the private `@objc` handler directly — Objective-C selector dispatch
    // bypasses Swift's `private` access control, so this reaches the same
    // method a real `.editingChanged` event would trigger, without needing
    // `sendActions(for:)`/`UIApplication`. Driving `perform` off the registered
    // action (rather than a literal selector string) also ties the two checks
    // together: the test only passes if the *actually-registered* action both
    // exists and behaves correctly.

    /// The `.editingChanged` action selector names currently registered with
    /// `field` as their own target, or `[]` if none — `actions(forTarget:for
    /// ControlEvent:)` returns `nil` for "no actions", so this normalizes that
    /// away rather than asserting on `nil` vs. `[]` directly.
    private func editingChangedActions(on field: UITextField) -> [String] {
        field.actions(forTarget: field, forControlEvent: .editingChanged) ?? []
    }

    @Test("validateOnInputChange(isEnabled: true) registers the action and re-validates when it fires")
    func testValidateOnInputChangeEnabled() {
        let field = UITextField()
        field.addRule(EmailRule())

        assert(editingChangedActions(on: field).isEmpty)

        field.validateOnInputChange(isEnabled: true)

        let actions = editingChangedActions(on: field)
        assert(actions.count == 1)

        var received: [ValidationError]?
        field.validationHandler = { errors in received = errors }

        field.text = "not-an-email"
        field.perform(Selector(actions[0]))

        assert(received != nil)
        assert(received?.count == 1)
    }

    @Test("validateOnInputChange(isEnabled: false) removes the .editingChanged target-action registration")
    func testValidateOnInputChangeDisabled() {
        let field = UITextField()
        field.addRule(EmailRule())
        field.validateOnInputChange(isEnabled: true)
        assert(editingChangedActions(on: field).count == 1)

        field.validateOnInputChange(isEnabled: false)

        // A real .editingChanged event would now have no target-action pair to
        // dispatch to, so typing would never auto-trigger validation.
        assert(editingChangedActions(on: field).isEmpty)
    }

    @Test("Never enabling validateOnInputChange means no .editingChanged target-action is ever registered")
    func testValidateOnInputChangeNeverEnabled() {
        let field = UITextField()
        field.addRule(RequiredRule())

        assert(editingChangedActions(on: field).isEmpty)
    }

    @Test("validationHandler receives the result of a direct validate() call")
    func testValidationHandlerReceivesDirectValidateResult() {
        let field = UITextField()
        field.text = "test@example.com"
        field.addRule(EmailRule())

        var received: [ValidationError]?
        field.validationHandler = { errors in received = errors }

        let returned = field.validate()

        assert(received != nil)
        assert(received?.isEmpty == true)
        assert(returned.isEmpty)
    }

    @Test("validateOnInputChange does not register duplicate targets across repeated calls")
    func testValidateOnInputChangeIdempotent() {
        let field = UITextField()
        field.addRule(RequiredRule())

        field.validateOnInputChange(isEnabled: true)
        field.validateOnInputChange(isEnabled: true)
        field.validateOnInputChange(isEnabled: true)

        // Repeated enable calls must still leave exactly one target-action pair
        // registered, not one per call.
        let actions = editingChangedActions(on: field)
        assert(actions.count == 1)

        var callCount = 0
        field.validationHandler = { _ in callCount += 1 }

        field.text = ""
        field.perform(Selector(actions[0]))

        assert(callCount == 1)
    }

    @Test("removeAllRules() clears previously attached rules")
    func testRemoveAllRules() {
        let field = UITextField()
        field.text = ""
        field.addRule(RequiredRule())
        assert(!field.validate().isEmpty)

        field.removeAllRules()
        assert(field.validate().isEmpty)
    }
}

#endif
