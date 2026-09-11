//
//  CreditCardRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 11/9/2026.
//
import Foundation

/// Validates that a string is a plausible credit card number using the
/// standard Luhn checksum algorithm.
///
/// Spaces and dashes are stripped before validation. The remaining string
/// must be 12-19 digits (covering common card number lengths) and must
/// satisfy the Luhn check digit formula. This does not verify that the
/// number belongs to a real, active card or issuer.
public struct CreditCardRule: ValidationRule {
    public let message: String

    public init(message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.creditCardKey, defaultMessage: ValidationMessage.creditCard)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let cardNumber = value as? String else {
            return ValidationError(message: message)
        }

        let stripped = cardNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")

        guard stripped.count >= 12, stripped.count <= 19, stripped.allSatisfy({ $0.isNumber }) else {
            return ValidationError(message: message)
        }

        guard isLuhnValid(stripped) else {
            return ValidationError(message: message)
        }

        return nil
    }

    private func isLuhnValid(_ digits: String) -> Bool {
        var total = 0
        var shouldDouble = false

        for character in digits.reversed() {
            guard let digit = character.wholeNumberValue else { return false }
            var value = digit
            if shouldDouble {
                value *= 2
                if value > 9 { value -= 9 }
            }
            total += value
            shouldDouble.toggle()
        }

        return total % 10 == 0
    }
}
