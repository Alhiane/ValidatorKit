//
//  NumericRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

import Foundation

public struct NumericRule: ValidationRule {
    public init() {}
    
    public func validate(_ value: Any?) -> ValidationError? {
        // Check if value is nil
        guard let value = value else {
            return ValidationError(message: "This field must be a number")
        }
        
        // Handle numeric types directly
        if value is Int || value is Double || value is Float || value is Decimal {
            return nil
        }
        
        // Handle string representations of numbers
        if let stringValue = value as? String {
            // Try to convert the string to a numeric type
            if let _ = Double(stringValue) {
                return nil
            }
        }
        
        // If none of the above checks passed, return an error
        return ValidationError(message: "This field must be a valid number")
    }
}
