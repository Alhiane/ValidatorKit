//
//  AnyValidationRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct AnyValidationRule: ValidationRule {
    private let _validate: (Any?) -> ValidationError?
    public let message: String
    
    public init<R: ValidationRule>(_ rule: R) {
        _validate = rule.validate
        self.message = rule.message
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        _validate(value)
    }
}
