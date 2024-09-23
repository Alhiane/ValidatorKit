//
//  NumericRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public struct NumericRule: ValidationRule {
    public init() {}
    
    public func validate(_ value: Any?) -> ValidationError? {
        if !(value is Int || value is Double) {
            return ValidationError(message: "This field must be a number")
        }
        return nil
    }
}
