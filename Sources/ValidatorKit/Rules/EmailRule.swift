//
//  EmailRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

import Foundation

public struct EmailRule: ValidationRule {
    public init() {}
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let email = value as? String else {
            return ValidationError(message: "Invalid email format")
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            return ValidationError(message: "Invalid email format")
        }
        
        return nil
    }
}
