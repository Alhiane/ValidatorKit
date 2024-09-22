//
//  ValidationRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 22/9/2024.
//

import Foundation

public protocol ValidationRule {
    func validate(_ value: Any?) -> ValidationError?
}

public struct AnyValidationRule: ValidationRule, @unchecked Sendable {
    private let validateClosure: (Any?) -> ValidationError?
    
    public init<R: ValidationRule>(_ rule: R) {
        self.validateClosure = rule.validate
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        validateClosure(value)
    }
}
