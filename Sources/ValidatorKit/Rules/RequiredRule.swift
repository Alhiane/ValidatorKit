//
//  RequiredRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 22/9/2024.
//

import Foundation

public struct RequiredRule: ValidationRule {
    public init() {}
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let string = value as? String, !string.isEmpty else {
            return ValidationError(message: "This field is required")
        }
        return nil
    }
}
