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
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.lessThanKey, defaultMessage: ValidationMessage.lessThan,dynamicValues: [String(maxValue)])
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let doubleValue = value as? Double else { return ValidationError(message: ValidationMessage.message(for: ValidationMessage.invalidValueKey, defaultMessage: ValidationMessage.invalidValue)) }
        if doubleValue >= maxValue {
            return ValidationError(message: message)
        }
        return nil
    }
}
