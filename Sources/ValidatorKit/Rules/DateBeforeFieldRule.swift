//
//  DateBeforeFieldRule.swift
//  ValidatorKit
//
//  Created by Louis Deconinck on 14/9/2026.
//

import Foundation

public struct DateBeforeFieldRule: CrossFieldValidationRule {
    private let otherField: String
    private let format: String
    public let message: String
    private let dateFormatter: DateFormatter

    public init(otherField: String, format: String = "yyyy-MM-dd", message: String? = nil) {
        self.otherField = otherField
        self.format = format
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.dateBeforeFieldKey, defaultMessage: ValidationMessage.dateBeforeField, dynamicValues: [otherField])
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = format
    }

    public func validate(_ value: Any?, in object: [String: Any]) -> ValidationError? {
        guard let date = parseDate(value), let otherDate = parseDate(object[otherField]) else {
            return ValidationError(message: message)
        }

        return date < otherDate ? nil : ValidationError(message: message)
    }

    private func parseDate(_ value: Any?) -> Date? {
        if let date = value as? Date {
            return date
        }
        if let string = value as? String {
            return dateFormatter.date(from: string)
        }
        return nil
    }
}
