//
//  RequireIfRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct RequireIfRule: ValidationRule {
    private let conditionValue: Bool
    
    public init(conditionValue: Bool) {
        self.conditionValue = conditionValue
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        if (conditionValue) {
            
            // Check for nil value
            if value == nil {
                return ValidationError(message: "This field is required")
            }

            // String check (empty string)
            if let string = value as? String, string.isEmpty {
                return ValidationError(message: "This field is required")
            }
            
            // Array check (empty array)
            if let array = value as? [Any], array.isEmpty {
                return ValidationError(message: "This field is required")
            }
            
            // Dictionary check (empty dictionary)
            if let dict = value as? [AnyHashable: Any], dict.isEmpty {
                return ValidationError(message: "This field is required")
            }

            // No need to validate Int, Double, Bool since non-nil is valid, even if 0 or false
            return nil
            
        }
        return nil
    }
}
