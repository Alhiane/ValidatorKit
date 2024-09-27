//
//  DateRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
import Foundation

public struct DateRange{
    public let from: Date?
    public let to: Date?
    
    public init(from: Date? = nil, to: Date? = nil) {
        self.from = from
        self.to = to
    }
}

public struct DateRule: ValidationRule {
    public let message: String
    private let range: DateRange?
    private let format: String
    private let dateFormatter: DateFormatter

    public init(range: DateRange? = nil,format: String = "yyyy-MM-dd",message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.dateKey, defaultMessage: ValidationMessage.date)
        self.format = format
        self.range = range
        
        // set date format
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = format
    }

    public func validate(_ value: Any?) -> ValidationError? {
        // First, check if the value is nil or not a String or Date
           guard let value = value, value is String || value is Date else {
               return ValidationError(message: message)
           }

           // If it's a Date, validate the range directly
           if let dateValue = value as? Date {
               return validateDateRange(dateValue)
           }

           // If it's a String, try to parse it
           if let stringValue = value as? String {
               guard let date = dateFormatter.date(from: stringValue) else {
                   return ValidationError(message: ValidationMessage.message(for: ValidationMessage.dateFormatKey, defaultMessage: ValidationMessage.dateFormat, dynamicValues: [String(format)]))
               }
               return validateDateRange(date)
           }

           // This should never be reached due to the initial guard, but we'll include it for completeness
        return ValidationError(message: message)
    }
    
    private func validateDateRange(_ date: Date) -> ValidationError? {
            guard let range = range else { return nil }
            
            if let fromDate = range.from, date < fromDate {
                return ValidationError(message: ValidationMessage.message(for: ValidationMessage.dateRangeTooEarlyKey, defaultMessage: ValidationMessage.dateRangeTooEarly,dynamicValues: [String(dateFormatter.string(from: fromDate))]))
            }
            if let toDate = range.to, date > toDate {
                return ValidationError(message: ValidationMessage.message(for: ValidationMessage.dateRangeTooLateKey, defaultMessage: ValidationMessage.dateRangeTooLate,dynamicValues: [String(dateFormatter.string(from: toDate))]))
            }
            return nil
        }
}

