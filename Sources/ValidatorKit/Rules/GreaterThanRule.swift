//
//  GreaterThanRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct GreaterThanRule: ValidationRule {
    private let minValue: Double
    
    public init(minValue: Double) {
        self.minValue = minValue
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let doubleValue = value as? Double else { return ValidationError(message: "Invalid value") }
        if doubleValue <= minValue {
            return ValidationError(message: "Must be greater than \(minValue)")
        }
        return nil
    }
}

