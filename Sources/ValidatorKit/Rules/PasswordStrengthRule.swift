//
//  PasswordStrengthRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 11/9/2026.
//

public struct PasswordStrengthRule: ValidationRule {
    private let minLength: Int
    private let requireUppercase: Bool
    private let requireLowercase: Bool
    private let requireDigit: Bool
    private let requireSymbol: Bool
    private let rejectCommon: Bool
    public let message: String

    public init(
        minLength: Int = 8,
        requireUppercase: Bool = false,
        requireLowercase: Bool = false,
        requireDigit: Bool = false,
        requireSymbol: Bool = false,
        rejectCommon: Bool = false,
        message: String? = nil
    ) {
        self.minLength = minLength
        self.requireUppercase = requireUppercase
        self.requireLowercase = requireLowercase
        self.requireDigit = requireDigit
        self.requireSymbol = requireSymbol
        self.rejectCommon = rejectCommon
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.passwordStrengthKey, defaultMessage: ValidationMessage.passwordStrength)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let password = value as? String else {
            return ValidationError(message: message)
        }

        guard password.count >= minLength else {
            return ValidationError(message: message)
        }

        if requireUppercase && !password.contains(where: { $0.isUppercase }) {
            return ValidationError(message: message)
        }

        if requireLowercase && !password.contains(where: { $0.isLowercase }) {
            return ValidationError(message: message)
        }

        if requireDigit && !password.contains(where: { $0.isNumber }) {
            return ValidationError(message: message)
        }

        if requireSymbol && !password.contains(where: { !$0.isLetter && !$0.isNumber }) {
            return ValidationError(message: message)
        }

        if rejectCommon && NotCommonPasswordRule.defaultCommonPasswords.contains(password.lowercased()) {
            return ValidationError(message: message)
        }

        return nil
    }
}
