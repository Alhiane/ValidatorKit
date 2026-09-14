//
//  UITextField+Validation.swift
//  ValidatorKitUIKit
//
//  Created by Alhiane on 14/9/2026.
//

#if os(iOS) || os(tvOS)

import UIKit
import ValidatorKit

/// Real-time `ValidationRule` support for `UITextField`.
///
/// Attach one or more rules to a field, optionally re-validate on every
/// `.editingChanged` event, and observe results through `validationHandler`:
///
/// ```swift
/// emailField.addRule(EmailRule())
/// emailField.validateOnInputChange(isEnabled: true)
/// emailField.validationHandler = { errors in
///     errors.isEmpty ? clearError() : showError(errors.first?.message)
/// }
/// ```
///
/// This works against the field's single `String?` value via
/// `ValidationRule.validate(_:)` directly — it does not go through
/// `ValidationSchema`, which validates a whole `[String: Any]` object instead.
@MainActor
extension UITextField {
    private enum AssociatedKeys {
        /// Only the storage address is used as a per-instance associated-object
        /// key, never its value, so a `nonisolated(unsafe) static var` is the
        /// minimal way to satisfy Swift 6 strict concurrency for this global.
        nonisolated(unsafe) static var box: UInt8 = 0
    }

    /// Backing storage for a field's rules, enabled flag, and handler closure.
    /// A plain extension can't add stored properties to `UITextField`, so this
    /// box is attached via the Objective-C associated-objects runtime.
    private final class ValidationBox {
        var rules: [ValidationRule] = []
        var isInputChangeValidationEnabled = false
        var handler: (([ValidationError]) -> Void)?
    }

    private var validationBox: ValidationBox {
        if let existing = objc_getAssociatedObject(self, &AssociatedKeys.box) as? ValidationBox {
            return existing
        }
        let box = ValidationBox()
        objc_setAssociatedObject(self, &AssociatedKeys.box, box, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return box
    }

    /// Attaches a validation rule to this text field. Multiple calls accumulate rules.
    public func addRule(_ rule: ValidationRule) {
        validationBox.rules.append(rule)
    }

    /// Attaches multiple validation rules to this text field. Multiple calls accumulate rules.
    public func addRules(_ rules: [ValidationRule]) {
        validationBox.rules.append(contentsOf: rules)
    }

    /// Removes every rule previously attached with `addRule(_:)` / `addRules(_:)`.
    public func removeAllRules() {
        validationBox.rules.removeAll()
    }

    /// When enabled, the field re-validates on every `.editingChanged` event and
    /// reports the result through `validationHandler`. Safe to call more than
    /// once, or to toggle back and forth — it never registers duplicate targets.
    public func validateOnInputChange(isEnabled: Bool) {
        let box = validationBox
        box.isInputChangeValidationEnabled = isEnabled

        // Always remove first so repeated or toggled calls stay idempotent.
        removeTarget(self, action: #selector(validatorKit_handleEditingChanged), for: .editingChanged)
        if isEnabled {
            addTarget(self, action: #selector(validatorKit_handleEditingChanged), for: .editingChanged)
        }
    }

    /// Runs all attached rules against the field's current text right now,
    /// regardless of `validateOnInputChange`, reports the result to
    /// `validationHandler`, and returns it.
    @discardableResult
    public func validate() -> [ValidationError] {
        let errors = validationBox.rules.compactMap { $0.validate(text) }
        validationBox.handler?(errors)
        return errors
    }

    /// Called after every validation — whether triggered by live editing or by
    /// calling `validate()` directly — with the resulting errors (empty means
    /// valid).
    ///
    /// - Warning: Capture `self` weakly if the closure references the field
    ///   (or anything that transitively retains it) to avoid a retain cycle;
    ///   the field retains this closure for as long as it's set.
    public var validationHandler: (([ValidationError]) -> Void)? {
        get { validationBox.handler }
        set { validationBox.handler = newValue }
    }

    @objc
    private func validatorKit_handleEditingChanged() {
        validate()
    }
}

#endif
