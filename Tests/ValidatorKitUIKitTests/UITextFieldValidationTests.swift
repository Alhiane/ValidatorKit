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

    @Test("validateOnInputChange(isEnabled: true) re-validates on .editingChanged")
    func testValidateOnInputChangeEnabled() {
        let field = UITextField()
        field.addRule(EmailRule())
        field.validateOnInputChange(isEnabled: true)

        var received: [ValidationError]?
        field.validationHandler = { errors in received = errors }

        field.text = "not-an-email"
        field.sendActions(for: .editingChanged)

        assert(received != nil)
        assert(received?.count == 1)
    }

    @Test("validateOnInputChange(isEnabled: false) does not auto-trigger validation on typing")
    func testValidateOnInputChangeDisabled() {
        let field = UITextField()
        field.addRule(EmailRule())
        field.validateOnInputChange(isEnabled: true)
        field.validateOnInputChange(isEnabled: false)

        var received: [ValidationError]?
        field.validationHandler = { errors in received = errors }

        field.text = "not-an-email"
        field.sendActions(for: .editingChanged)

        assert(received == nil)
    }

    @Test("Never enabling validateOnInputChange means typing never auto-triggers validation")
    func testValidateOnInputChangeNeverEnabled() {
        let field = UITextField()
        field.addRule(RequiredRule())

        var received: [ValidationError]?
        field.validationHandler = { errors in received = errors }

        field.text = ""
        field.sendActions(for: .editingChanged)

        assert(received == nil)
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

        var callCount = 0
        field.validationHandler = { _ in callCount += 1 }

        field.validateOnInputChange(isEnabled: true)
        field.validateOnInputChange(isEnabled: true)
        field.validateOnInputChange(isEnabled: true)

        field.text = ""
        field.sendActions(for: .editingChanged)

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
