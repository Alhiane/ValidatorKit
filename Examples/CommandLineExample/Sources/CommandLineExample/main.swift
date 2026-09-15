//
//  main.swift
//  CommandLineExample
//
//  A minimal, real ValidatorKit consumer. Run it with `swift run` from
//  inside Examples/CommandLineExample/ — see Examples/README.md.
//

import ValidatorKit

// A small "sign-up" style schema mixing a few different rule kinds:
// required + format rules, a numeric comparison, and password strength.
let schema = ValidationSchema()
    .field("email").required().email()
    .field("password").required().passwordStrength(
        minLength: 8,
        requireDigit: true,
        requireSymbol: true,
        rejectCommon: true
    )
    .field("age").required().greaterThan(18)
    .ready()

func report(_ label: String, _ object: [String: Any]) {
    let result = schema.validate(object)
    print("--- \(label) ---")
    print("isValid: \(result.isValid)")
    if result.isValid {
        print("No errors.")
    } else {
        for (field, messages) in result.errors.sorted(by: { $0.key < $1.key }) {
            for message in messages {
                print("  \(field): \(message)")
            }
        }
    }
    print("")
}

let invalidSubmission: [String: Any] = [
    "email": "not-an-email",
    "password": "short",
    "age": 16
]

let validSubmission: [String: Any] = [
    "email": "new-user@example.com",
    "password": "Correct-Horse-42!",
    "age": 27
]

report("Invalid submission", invalidSubmission)
report("Valid submission", validSubmission)
