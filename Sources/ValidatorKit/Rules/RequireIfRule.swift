//
//  RequireIfRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct RequireIfRule: ValidationRule {
    private let conditionValue: Bool
    public let message: String
    
    public init(conditionValue: Bool, message: String? = nil) {
        self.conditionValue = conditionValue
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.requiredIfKey, defaultMessage: ValidationMessage.requiredIf)
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        if (conditionValue) {
            
            // Check for nil value
            if value == nil {
                return ValidationError(message: message)
            }

            // String check (empty string)
            if let string = value as? String, string.isEmpty {
                return ValidationError(message: message)
            }
            
            // Array check (empty array)
            if let array = value as? [Any], array.isEmpty {
                return ValidationError(message: message)
            }
            
            // Dictionary check (empty dictionary)
            if let dict = value as? [AnyHashable: Any], dict.isEmpty {
                return ValidationError(message: message)
            }

            // No need to validate Int, Double, Bool since non-nil is valid, even if 0 or false
            return nil
            
        }
        return nil
    }
}
