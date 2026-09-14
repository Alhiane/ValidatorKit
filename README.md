# ValidatorKit

A lightweight, fluent validation library for Swift — chainable rules, localized error messages, zero dependencies.

[![CI](https://github.com/Alhiane/ValidatorKit/actions/workflows/ci.yml/badge.svg)](https://github.com/Alhiane/ValidatorKit/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Alhiane/ValidatorKit/graph/badge.svg)](https://codecov.io/gh/Alhiane/ValidatorKit)
[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAlhiane%2FValidatorKit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Alhiane/ValidatorKit)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAlhiane%2FValidatorKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/Alhiane/ValidatorKit)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

📖 **[Full documentation & rules reference](https://alhiane.com/open-source/validatorkit)**

## Why ValidatorKit

- **Fluent, chainable schemas** — describe every field's rules in one readable expression
- **Zero dependencies** — pure Swift, Foundation only
- **Localized out of the box** — error messages ship in English, Arabic, Spanish, and French
- **25+ built-in rules** — email, phone, credit card (Luhn), IBAN, password strength, dates, regex, file size, and more
- **Cross-field & async-ready** — confirm-password/date-range checks that see the whole object, plus async rules for server round-trips like username availability
- **Works anywhere** — validate a decoded JSON payload, a form dictionary, or a view model's fields the same way

## Requirements

| Platform | Minimum Version |
|----------|------------------|
| iOS      | 13.0+            |
| macOS    | 10.15+           |
| tvOS     | 13.0+            |
| watchOS  | 6.0+             |
| Swift    | 6.0+             |

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

Cross-field rules see the whole object being validated, not just their own field — useful for confirm-password fields or date ranges:

```swift
let schema = ValidationSchema()
    .field("password").required()
    .field("confirmPassword").required().matches("password")
    .field("startDate").required().dateBefore("endDate")
    .field("endDate").required().dateAfter("startDate")
    .ready()
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

### UIKit

`ValidatorKitUIKit` (a separate product, so the core library stays dependency-free) adds real-time validation to `UITextField` — attach rules, optionally re-validate as the user types, and observe results via a closure:

```swift
import ValidatorKitUIKit

emailField.addRule(EmailRule())
emailField.validateOnInputChange(isEnabled: true)
emailField.validationHandler = { errors in
    errorLabel.text = errors.first?.message
    errorLabel.isHidden = errors.isEmpty
}
```

`validate()` runs the attached rules on demand — regardless of `validateOnInputChange` — and also returns the errors directly:

```swift
if emailField.validate().isEmpty {
    submit()
}
```

For the complete list of rules, localization details, and more examples, see the **[full docs](https://alhiane.com/open-source/validatorkit)**.

### SwiftUI

The `ValidatorKitSwiftUI` product (a separate target, so the core stays Foundation-only) binds a schema to `@Published` form state with debounced, reactive re-validation:

```swift
import SwiftUI
import ValidatorKit
import ValidatorKitSwiftUI

@MainActor
final class SignUpForm: ObservableObject {
    @Published var email = ""
    let schema = ObservableValidationSchema(
        schema: ValidationSchema().field("email").required().email().ready()
    )

    init() {
        schema.bind("email", to: $email)
    }
}

struct SignUpView: View {
    @StateObject private var form = SignUpForm()

    var body: some View {
        TextField("Email", text: $form.email)
        if let error = form.schema.errors(for: "email").first {
            Text(error).foregroundColor(.red)
        }
    }
}
```

## Communication

- 🐛 Found a bug? [Open an issue](https://github.com/Alhiane/ValidatorKit/issues/new)
- 💡 Have a feature request? [Open an issue](https://github.com/Alhiane/ValidatorKit/issues/new)
- ❓ Questions? [Start a discussion](https://github.com/Alhiane/ValidatorKit/discussions)

## Contributing

Issues and PRs are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) for the development and release workflow.

## License

MIT — see [LICENSE](LICENSE).
