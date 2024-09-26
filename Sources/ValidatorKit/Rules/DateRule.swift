//
//  DateRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation

public struct DateRule: ValidationRule {
    public let message: String

    public init(message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.dateKey, defaultMessage: ValidationMessage.date)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        if !(value is Date) {
            return ValidationError(message: message)
        }
        return nil
    }
}

