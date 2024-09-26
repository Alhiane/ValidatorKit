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
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.greaterThanKey, defaultMessage: ValidationMessage.greaterThan,dynamicValues: [String(minValue)])
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let doubleValue = value as? Double else { return ValidationError(message: ValidationMessage.message(for: ValidationMessage.invalidValueKey, defaultMessage: ValidationMessage.invalidValue)) }
        if doubleValue <= minValue {
            return ValidationError(message: message)
        }
        return nil
    }
}

