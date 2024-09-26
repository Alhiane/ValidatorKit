//
//  RangeRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct RangeRule: ValidationRule {
    private let range: ClosedRange<Int>
    public let message: String
    
    public init(range: ClosedRange<Int>,message: String? = nil) {
        self.range = range
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.rangeKey, defaultMessage: ValidationMessage.range,dynamicValues: [String(range.lowerBound),String(range.upperBound)])
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        if let number = value as? Int, !range.contains(number) {
            return ValidationError(message: message)
        }
        return nil
    }
}

