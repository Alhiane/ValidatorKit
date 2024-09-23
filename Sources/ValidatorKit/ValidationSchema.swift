//
//  ValidationSchema.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//

public class ValidationSchema {
    private var rules: [String: [AnyValidationRule]] = [:]
    
    public init() {}
    
    public func field(_ name: String) -> FieldValidator {
        return FieldValidator(name: name, schema: self)
    }
    
    public func validate(_ object: [String: Any]) -> ValidationResult {
        var errors: [String: [String]] = [:]
        
        for (field, fieldRules) in rules {
            if let value = object[field] {
                let fieldErrors = fieldRules.compactMap { $0.validate(value) }
                if !fieldErrors.isEmpty {
                    errors[field] = fieldErrors.map { $0.message }
                }
            }
        }
        
        return ValidationResult(errors: errors)
    }
    
    fileprivate func addRule(_ name: String, _ rule: AnyValidationRule) {
        if rules[name] == nil {
            rules[name] = []
        }
        rules[name]?.append(rule)
    }
}

public class FieldValidator {
    private let name: String
    private let schema: ValidationSchema
    
    fileprivate init(name: String, schema: ValidationSchema) {
        self.name = name
        self.schema = schema
    }
    
    @discardableResult
    public func required() -> FieldValidator {
        schema.addRule(name, AnyValidationRule(RequiredRule()))
        return self
    }
    
//    @discardableResult
//    public func email() -> FieldValidator {
//        schema.addRule(name, AnyValidationRule(EmailRule()))
//        return self
//    }
    
    // Add more validation methods as needed
}

public struct ValidationResult {
    public let errors: [String: [String]]
    
    public var isValid: Bool {
        return errors.isEmpty
    }
}
