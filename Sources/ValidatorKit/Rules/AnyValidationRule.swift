//
//  AnyValidationRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct AnyValidationRule: ValidationRule {
    private let _validate: (Any?) -> ValidationError?
    
    public init<R: ValidationRule>(_ rule: R) {
        _validate = rule.validate
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        _validate(value)
    }
}
