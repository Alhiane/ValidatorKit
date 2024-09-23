//
//  PatternRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation

public struct PatternRule: ValidationRule {
    private let pattern: String
    
    public init(pattern: String) {
        self.pattern = pattern
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        if let string = value as? String, !NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: string) {
            return ValidationError(message: "Invalid format")
        }
        return nil
    }
}
