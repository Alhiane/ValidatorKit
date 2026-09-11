//
//  PhoneNumberRule.swift
//  ValidatorKit
//
//  Created by Alhiane on 11/9/2026.
//
import Foundation

/// Validates that a string is a basic, E.164-ish international phone number.
///
/// What it checks: an optional leading `+`, followed by 7-15 digits. Spaces,
/// dashes and parentheses are allowed in the input and stripped before the
/// digit-count check, so values like `+1 (415) 555-2671` are accepted.
///
/// What it does NOT check: this is not a full libphonenumber-level parser.
/// It does not validate country calling codes, national numbering plans,
/// area code lengths, or whether the number is actually reachable/assigned.
/// It is a lightweight sanity check suitable for form validation, not a
/// substitute for a dedicated phone number parsing library.
public struct PhoneNumberRule: ValidationRule {
    public let message: String

    public init(message: String? = nil) {
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.phoneNumberKey, defaultMessage: ValidationMessage.phoneNumber)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let phoneNumber = value as? String else {
            return ValidationError(message: message)
        }

        let stripped = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        let phoneRegex = "\\+?[0-9]{7,15}"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)

        guard phonePredicate.evaluate(with: stripped) else {
            return ValidationError(message: message)
        }

        return nil
    }
}
