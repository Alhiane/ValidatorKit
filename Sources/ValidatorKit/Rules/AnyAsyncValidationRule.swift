//
//  AnyAsyncValidationRule.swift
//  ValidatorKit
//
//  Created by Louis Deconinck on 13/9/2026.
//

/// Type-erased `AsyncValidationRule`, mirroring `AnyValidationRule`.
public struct AnyAsyncValidationRule: AsyncValidationRule {
    private let _validate: (Any?) async -> ValidationError?
    public let message: String

    public init<R: AsyncValidationRule>(_ rule: R) {
        _validate = rule.validate
        self.message = rule.message
    }

    public func validate(_ value: Any?) async -> ValidationError? {
        await _validate(value)
    }
}
