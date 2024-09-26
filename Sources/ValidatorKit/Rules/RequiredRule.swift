//
//  RequiredRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 22/9/2024.
//

import Foundation

public struct RequiredRule: ValidationRule {
    public let message: String
    
    public init(message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.requiredKey, defaultMessage: ValidationMessage.required)
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
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
}
