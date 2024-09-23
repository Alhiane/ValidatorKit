//
//  MaxLengthRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct MaxRule: ValidationRule {
    private let maxValue: Double
    
    public init(value: Double) {
        self.maxValue = value
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        // Handle number validation (Int or Double)
        if let number = value as? Double, number > maxValue {
            return ValidationError(message: "Value must be less than or equal to \(maxValue)")
        } else if let number = value as? Int, Double(number) > maxValue {
            return ValidationError(message: "Value must be less than or equal to \(maxValue)")
        }

        // Handle string length validation
        if let string = value as? String, string.count > Int(maxValue) {
            return ValidationError(message: "Maximum length is \(Int(maxValue)) characters")
        }
        
        return nil
    }
}
