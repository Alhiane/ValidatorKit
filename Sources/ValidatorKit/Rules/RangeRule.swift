//
//  RangeRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 23/9/2024.
//
public struct RangeRule: ValidationRule {
    private let range: ClosedRange<Int>
    
    public init(range: ClosedRange<Int>) {
        self.range = range
    }
    
    public func validate(_ value: Any?) -> ValidationError? {
        if let number = value as? Int, !range.contains(number) {
            return ValidationError(message: "Value must be between \(range.lowerBound) and \(range.upperBound)")
        }
        return nil
    }
}

