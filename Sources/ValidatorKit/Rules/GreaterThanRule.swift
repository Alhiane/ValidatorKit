//
//  GreaterThanRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct GreaterThanRule: ValidationRule {
    public let message: String
    private let minValue: Double

    public init(minValue: Double, message: String? = nil) {
        self.minValue = minValue
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.greaterThanKey, defaultMessage: ValidationMessage.greaterThan, dynamicValues: [String(minValue)])
    }

    public func validate(_ value: Any?) -> ValidationError? {
        if let stringValue = value as? String, let numericValue = Double(stringValue) {
            return validateNumeric(numericValue)
        }

        if let numberValue = value as? Double {
            return validateNumeric(numberValue)
        } else if let intValue = value as? Int {
            return validateNumeric(Double(intValue))
        }

        return ValidationError(message: ValidationMessage.message(for: ValidationMessage.invalidValueKey, defaultMessage: ValidationMessage.invalidValue))
    }

    private func validateNumeric(_ number: Double) -> ValidationError? {
        if number <= minValue {
            return ValidationError(message: message)
        }
        return nil
    }
}
