//
//  URLRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation

public struct URLRule: ValidationRule {
    public let message: String
    
    public init(message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.urlKey, defaultMessage: ValidationMessage.url)
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        guard let string = value as? String, let url = URL(string: string), url.scheme != nil && url.host != nil else {
            return ValidationError(message: message)
        }
        return nil
    }
}
