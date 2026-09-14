//
//  AnyValidationRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct AnyValidationRule: ValidationRule {
    private let _validate: (Any?) -> ValidationError?
    private let _validateInObject: ((Any?, [String: Any]) -> ValidationError?)?
    public let message: String

    public init<R: ValidationRule>(_ rule: R) {
        _validate = rule.validate
        self.message = rule.message
        if let crossFieldRule = rule as? CrossFieldValidationRule {
            _validateInObject = { crossFieldRule.validate($0, in: $1) }
        } else {
            _validateInObject = nil
        }
    }

    public func validate(_ value: Any?) -> ValidationError? {
        _validate(value)
    }

    /// Validates `value`, forwarding the whole object to rules that conform to
    /// `CrossFieldValidationRule`. Plain rules fall back to `validate(_:)`.
    public func validate(_ value: Any?, in object: [String: Any]) -> ValidationError? {
        if let validateInObject = _validateInObject {
            return validateInObject(value, object)
        }
        return _validate(value)
    }
}
