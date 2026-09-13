//
//  NotCommonPasswordRule.swift
//  ValidatorKit
//
//  Created by Louis Deconinck on 13/9/2026.
//

public struct NotCommonPasswordRule: ValidationRule {
    /// Well-known passwords that are rejected by default, matched case-insensitively.
    /// Compiled from public "most common passwords" lists (NCSC / SplashData style).
    public static let defaultCommonPasswords: Set<String> = [
        "123456", "password", "123456789", "12345", "12345678", "qwerty", "1234567",
        "111111", "1234567890", "123123", "abc123", "1234", "password1", "iloveyou",
        "1q2w3e4r", "000000", "qwerty123", "zaq12wsx", "dragon", "sunshine",
        "princess", "letmein", "654321", "monkey", "1qaz2wsx", "123321", "qwertyuiop",
        "superman", "asdfghjkl", "passw0rd", "master", "hello", "freedom", "whatever",
        "qazwsx", "trustno1", "starwars", "football", "baseball", "welcome", "admin",
        "login", "shadow", "ashley", "michael", "ninja", "mustang", "password123",
        "charlie", "aa123456", "donald", "batman", "access", "soccer", "killer",
        "hockey", "george", "computer", "michelle", "jessica", "pepper", "daniel",
        "summer", "tigger", "joshua", "cheese", "ranger", "thomas", "matrix",
        "jordan", "hunter", "buster", "harley", "andrew", "secret", "banana",
        "purple", "orange", "porsche", "ferrari", "corvette", "maverick", "merlin",
        "morgan", "taylor", "thunder", "titanic", "william", "winner", "wizard",
        "zxcvbnm", "blink182", "scooby", "sparky", "rover", "junior", "internet",
        "silver", "golden"
    ]

    private let commonPasswords: Set<String>
    public let message: String

    public init(commonPasswords: Set<String> = NotCommonPasswordRule.defaultCommonPasswords, message: String? = nil) {
        self.commonPasswords = commonPasswords
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.notCommonPasswordKey, defaultMessage: ValidationMessage.notCommonPassword)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        guard let password = value as? String else {
            return ValidationError(message: message)
        }

        if commonPasswords.contains(password.lowercased()) {
            return ValidationError(message: message)
        }

        return nil
    }
}
