//
//  InArrayRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct InArrayRule: ValidationRule {
    private let allowedValues: [Any]
    public let message: String
    
    
    public init(allowedValues: [Any],message: String? = nil) {
        self.allowedValues = allowedValues
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.inArrayKey, defaultMessage: ValidationMessage.inArray)
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let value = value else { return ValidationError(message: message) }
        if !allowedValues.contains(where: { "\($0)" == "\(value)" }) {
            return ValidationError(message: message)
        }
        return nil
    }
}

