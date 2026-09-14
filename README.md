# ValidatorKit

A lightweight, fluent validation library for Swift — chainable rules, localized error messages, zero dependencies.

[![CI](https://github.com/Alhiane/ValidatorKit/actions/workflows/ci.yml/badge.svg)](https://github.com/Alhiane/ValidatorKit/actions/workflows/ci.yml)
[![Swift 6.0](https://img.shields.io/badge/swift-6.0-orange.svg)](https://swift.org)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](Package.swift)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

📖 **[Full documentation & rules reference](https://alhiane.com/open-source/validatorkit)**

## Why ValidatorKit

- **Fluent, chainable schemas** — describe every field's rules in one readable expression
- **Zero dependencies** — pure Swift, Foundation only
- **Localized out of the box** — error messages ship in English, Arabic, Spanish, and French
- **20+ built-in rules** — email, phone, credit card (Luhn), IBAN, password strength, dates, regex, file size, and more
- **Works anywhere** — validate a decoded JSON payload, a form dictionary, or a view model's fields the same way

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/Alhiane/ValidatorKit.git", from: "1.0.0-beta")
]
```

## Quick start

```swift
import ValidatorKit

let schema = ValidationSchema()
    .field("email").required().email()
    .field("password").required().passwordStrength(minLength: 8, requireDigit: true, requireSymbol: true, rejectCommon: true)
    .field("age").required().greaterThan(18)
    .ready()

let result = schema.validate([
    "email": "not-an-email",
    "password": "short",
    "age": 16
])

result.isValid            // false
result.errors["email"]    // ["Please enter a valid email address."]
```

Custom validation when a built-in rule isn't enough:

```swift
.field("username").required().custom(message: "Must be lowercase, no spaces") { value in
    guard let username = value as? String else { return false }
    return username == username.lowercased() && !username.contains(" ")
}
```

Async rules cover checks that need a server round-trip, like username availability — sync rules still run first, and a field's async rules are skipped if it already failed locally:

```swift
let schema = ValidationSchema()
    .field("username").required().customAsync(message: "This username is already taken.") { value in
        await api.isUsernameAvailable(value as? String ?? "")
    }
    .ready()

let result = await schema.validateAsync(["username": "newuser"])
```

For the complete list of rules, localization details, and more examples, see the **[full docs](https://alhiane.com/open-source/validatorkit)**.

## Contributing

Issues and PRs are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for the development and release workflow.

## License

MIT — see [LICENSE](LICENSE).
