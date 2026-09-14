//
//  MatchesFieldRule.swift
//  ValidatorKit
//
//  Created by Louis Deconinck on 14/9/2026.
//

public struct MatchesFieldRule: CrossFieldValidationRule {
    private let otherField: String
    public let message: String

    public init(otherField: String, message: String? = nil) {
        self.otherField = otherField
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.matchesFieldKey, defaultMessage: ValidationMessage.matchesField, dynamicValues: [otherField])
    }

    public func validate(_ value: Any?, in object: [String: Any]) -> ValidationError? {
        guard let value = value, let otherValue = object[otherField] else {
            return ValidationError(message: message)
        }

        return isEqual(value, otherValue) ? nil : ValidationError(message: message)
    }

    private func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        guard let lhs = lhs as? AnyHashable, let rhs = rhs as? AnyHashable else {
            return false
        }
        return lhs == rhs
    }
}
