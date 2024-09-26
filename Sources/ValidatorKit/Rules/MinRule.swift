//
//  MinRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct MinRule: ValidationRule {
    private let minValue: Double
    private let epsilon = 0.0001 // Precision handling for floating-point numbers

    public let message: String
    
    public init(value: Double,message: String? = nil) {
        self.minValue = value
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.minKey, defaultMessage: ValidationMessage.min,dynamicValues: [String(value)])
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else {
            return ValidationError(message: ValidationMessage.message(for: ValidationMessage.notNullKey, defaultMessage: ValidationMessage.notNull))
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
        
        // If the value doesn't match any expected type
        return ValidationError(message: ValidationMessage.message(for: ValidationMessage.invalidTypeKey, defaultMessage: ValidationMessage.invalidType))
    }
    
    private func validateNumeric(_ number: Double) -> ValidationError? {
        if number < minValue - epsilon {
            return ValidationError(message: message)
        }
        return nil
    }
}
