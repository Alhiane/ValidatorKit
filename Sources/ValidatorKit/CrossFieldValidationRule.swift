//
//  CrossFieldValidationRule.swift
//  ValidatorKit
//
//  Created by Louis Deconinck on 14/9/2026.
//

/// A rule that needs access to the whole validated object, not just its own
/// field's value — e.g. confirm-password fields or start/end date ordering.
///
/// `ValidationSchema.validate(_:)` passes the full `[String: Any]` object to
/// rules conforming to this protocol.
public protocol CrossFieldValidationRule: ValidationRule {
    func validate(_ value: Any?, in object: [String: Any]) -> ValidationError?
}

public extension CrossFieldValidationRule {
    /// Single-field entry point required by `ValidationRule`. Without the
    /// surrounding object there is no other field to compare against, so the
    /// rule is evaluated with an empty object.
    func validate(_ value: Any?) -> ValidationError? {
        validate(value, in: [:])
    }
}
