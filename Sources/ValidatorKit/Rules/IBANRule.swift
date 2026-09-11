//
//  IBANRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 11/9/2026.
//
import Foundation

/// Validates that a string is a well-formed IBAN (International Bank
/// Account Number): a 2-letter country code, 2 check digits, and up to 30
/// alphanumeric characters, verified with the standard mod-97 checksum.
///
/// Spaces are stripped and the value is uppercased before validation. This
/// checks structural and checksum validity only; it does not verify that
/// the IBAN corresponds to a real, existing bank account.
public struct IBANRule: ValidationRule {
    public let message: String

    public init(message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.ibanKey, defaultMessage: ValidationMessage.iban)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let iban = value as? String else {
            return ValidationError(message: message)
        }

        let stripped = iban.replacingOccurrences(of: " ", with: "").uppercased()

        let ibanRegex = "[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}"
        let ibanPredicate = NSPredicate(format: "SELF MATCHES %@", ibanRegex)

        guard ibanPredicate.evaluate(with: stripped) else {
            return ValidationError(message: message)
        }

        guard isChecksumValid(stripped) else {
            return ValidationError(message: message)
        }

        return nil
    }

    /// Performs the ISO 7064 mod-97-10 checksum: move the first 4 characters
    /// to the end, convert letters to numbers (A=10 ... Z=35), and confirm
    /// the resulting numeric string is congruent to 1 mod 97. The remainder
    /// is folded digit-by-digit so the value never needs to fit in an Int.
    private func isChecksumValid(_ iban: String) -> Bool {
        let rearranged = String(iban.dropFirst(4)) + String(iban.prefix(4))

        var remainder = 0
        for character in rearranged {
            if character.isNumber, let digit = character.wholeNumberValue {
                remainder = (remainder * 10 + digit) % 97
            } else if character.isLetter, let asciiValue = character.asciiValue {
                let letterValue = Int(asciiValue) - 55 // A=10 ... Z=35
                remainder = (remainder * 10 + letterValue / 10) % 97
                remainder = (remainder * 10 + letterValue % 10) % 97
            } else {
                return false
            }
        }

        return remainder == 1
    }
}
