//
//  DateRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation

public struct DateRule: ValidationRule {
    public init() {}

    public func validate(_ value: Any?) -> ValidationError? {
        if !(value is Date) {
            return ValidationError(message: "Invalid date")
        }
        return nil
    }
}

