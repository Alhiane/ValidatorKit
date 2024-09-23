//
//  MinLengthRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct MinRule: ValidationRule {
    private let minValue: Double
    
    public init(value: Double) {
        self.minValue = Double(value)
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        // Handle number validation (Int or Double)
        if let number = value as? Double, number < minValue {
            return ValidationError(message: "Value must be greater than or equal to \(minValue)")
        } else if let number = value as? Int, Double(number) < minValue {
            return ValidationError(message: "Value must be greater than or equal to \(minValue)")
        }

        // Handle string length validation
        if let string = value as? String, string.count < Int(minValue) {
            return ValidationError(message: "Minimum length is \(Int(minValue)) characters")
        }
        
        return nil
    }
}


