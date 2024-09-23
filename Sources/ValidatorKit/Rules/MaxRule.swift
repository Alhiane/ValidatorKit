//
//  NumericRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct MaxRule: ValidationRule {
    private let maxValue: Double
    private let epsilon = 0.0001 // Precision handling for floating-point numbers

    public init(value: Double) {
        self.maxValue = value
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else {
            return ValidationError(message: "Value cannot be nil")
        }

        // Check if the value is a numeric string
        if let stringValue = value as? String, let numericValue = Double(stringValue) {
            // Treat numeric string as a number and apply numeric validation
            return validateNumeric(numericValue)
        }

        // Handle actual numeric types (Int or Double)
        if let numberValue = value as? Double {
            return validateNumeric(numberValue)
        } else if let intValue = value as? Int {
            return validateNumeric(Double(intValue))
        }

        // Handle non-numeric strings (apply string length validation)
        if let stringValue = value as? String {
            return validateStringLength(stringValue)
        }

        // If the value doesn't match any expected type
        return ValidationError(message: "Invalid value type")
    }

    private func validateNumeric(_ number: Double) -> ValidationError? {
        if number > maxValue + epsilon {
            return ValidationError(message: "Value must be less than or equal to \(maxValue)")
        }
        return nil
    }

    private func validateStringLength(_ string: String) -> ValidationError? {
        if string.count > Int(maxValue) {
            return ValidationError(message: "Maximum length is \(Int(maxValue)) characters")
        }
        return nil
    }
}
