//
//  LessThanRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct LessThanRule: ValidationRule {
    private let maxValue: Double
    
    public init(maxValue: Double) {
        self.maxValue = maxValue
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let doubleValue = value as? Double else { return ValidationError(message: "Invalid value") }
        if doubleValue >= maxValue {
            return ValidationError(message: "Must be less than \(maxValue)")
        }
        return nil
    }
}
