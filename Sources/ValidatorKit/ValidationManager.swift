//
//  ValidationManager.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation

import Foundation

@available(iOS 13.0, macOS 10.15, *)
public final class ValidationManager: @unchecked Sendable {
    public static let shared = ValidationManager()
    
    private let validator: ValidatorKit
    
    private init(validator: ValidatorKit = .shared) {
        self.validator = validator
    }
    
    public func setupCustomValidation<R: ValidationRule>(forKey key: String, rules: [R]) {
        validator.register(rules: rules, forKey: key)
    }
}
