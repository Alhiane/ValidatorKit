# SwiftValidate

    ValidatorKit is a flexible and extensible validation library for Swift, designed to simplify form validation in iOS apps.

## Features

- Easy to use validation system
- Ability to create custom validation rules
- Support for multiple validation rules per field
- Combine integration for reactive validation

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Alhiane/ValidatorKit.git", from: "1.0.0")
]
```

## Usage

```swift
import SwiftValidate

// Setup validation rules
ValidationManager.shared.setupCustomValidation(forKey: "email", rules: [
    RequiredRule(),
    EmailRule(),
    MinLengthRule(minLength: 5)
])

// Validate a value
let errors = Validator.shared.validate("test@example.com", forKey: "email")

// Use with Combine
textField.textPublisher
    .validate(key: "email")
    .sink { errors in
        // Handle validation errors
    }
    .store(in: &cancellables)
```
