//
//  InArrayRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct InArrayRule: ValidationRule {
    private let allowedValues: [Any]
    
    public init(allowedValues: [Any]) {
        self.allowedValues = allowedValues
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else { return ValidationError(message: "This field is required") }
        if !allowedValues.contains(where: { "\($0)" == "\(value)" }) {
            return ValidationError(message: "Value is not in the allowed list")
        }
        return nil
    }
}

