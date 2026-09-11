//
//  NumericRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct MaxRule: ValidationRule {
    private let maxValue: Double
    private let epsilon = 0.0001 // Precision handling for floating-point numbers
    public let message: String

    public init(value: Double, message: String? = nil) {
        self.maxValue = value
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.maxKey, defaultMessage: ValidationMessage.max, dynamicValues: [String(value)])
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else {
            return ValidationError(message: ValidationMessage.message(for: ValidationMessage.notNullKey, defaultMessage: ValidationMessage.notNull))
        }

        if let stringValue = value as? String {
            if let numericValue = Double(stringValue) {
                // Preserve numeric-string behavior.
                return validateNumeric(numericValue)
            }
            return validateStringLength(stringValue)
        }

        // Handle actual numeric types (Int or Double)
        if let numberValue = value as? Double {
            return validateNumeric(numberValue)
        } else if let intValue = value as? Int {
            return validateNumeric(Double(intValue))
        }

        // If the value doesn't match any expected type
        return ValidationError(message: ValidationMessage.message(for: ValidationMessage.invalidTypeKey, defaultMessage: ValidationMessage.invalidType))
    }

    private func validateNumeric(_ number: Double) -> ValidationError? {
        if number > maxValue + epsilon {
            return ValidationError(message: message)
        }
        return nil
    }

    private func validateStringLength(_ string: String) -> ValidationError? {
        if Double(string.count) > maxValue + epsilon {
            return ValidationError(message: message)
        }
        return nil
    }
}
