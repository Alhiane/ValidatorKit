//
//  LessThanRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct LessThanRule: ValidationRule {
    private let maxValue: Double
    public let message: String

    public init(maxValue: Double, message: String? = nil) {
        self.maxValue = maxValue
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.lessThanKey, defaultMessage: ValidationMessage.lessThan, dynamicValues: [String(maxValue)])
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
        if number >= maxValue {
            return ValidationError(message: message)
        }
        return nil
    }
}
