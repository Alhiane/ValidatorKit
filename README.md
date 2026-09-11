# ValidatorKit

    ValidatorKit is a flexible and extensible validation library for Swift, designed to simplify form validation in iOS apps.

## Features

- Easy to use validation system
- Ability to create custom validation rules
- Support for multiple validation rules per field
- SwiftUI/Combine live-binding validation is planned (tracked in #11)

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/Alhiane/ValidatorKit.git", from: "1.0.0-beta")
]
```

## Usage

```swift
import ValidatorKit

// Setup your schema
let schema = ValidationSchema()
    .field("username").required() // Field must be present and not empty
    .field("email").required().email() // Field must be a valid email format
    .field("gender").requiredIf(username == "johndoe") // Required if username is "johndoe"
    .field("age").required().greaterThan(18) // Must be greater than 18
    .field("amount").numeric().min(100.08) // Must be a number and at least 100.08
    .field("password").required().custom(message: "Password must be at least 8 characters") { value in
        guard let password = value as? String, password.count >= 8 else {
            return false
        }
        return true
    }
    .field("url").required().URL() // Must be a valid URL
    .field("dateOfBirth").required().date() // Must be a valid date
    .field("file").required().MIMETypes(["image/jpeg", "image/png"]) // Must be a valid file type
    .field("hobbies").inArray(["coding", "reading", "traveling"]) // Must be one of the allowed values
    .field("score").numeric().min(0).max(100) // Must be a number between 0 and 100
    .field("customField").pattern("^[A-Z]{3}-\\d{3}$") // Must match the pattern "XXX-123"
    .ready()

// Example data for validation
let validData: [String: Any] = [
    "username": "alhiane",
    "email": "aie@aie.aie",
    "gender": "male",
    "age": 25,
    "amount": "150.00",
    "password": "securePassword123",
    "url": "https://example.com",
    "dateOfBirth": Date(),
    "file": "image/jpeg",
    "hobbies": "coding",
    "score": 85,
    "customField": "ABC-123"
]

let invalidData: [String: Any] = [
    "username": "",
    "email": "not-an-email",
    "gender": "",
    "age": 16,
    "amount": "50.00",
    "password": "short",
    "url": "invalid-url",
    "dateOfBirth": "not-a-date",
    "file": "text/plain",
    "hobbies": "sports",
    "score": 150,
    "customField": "invalid"
]

// Validate function
let validResult = schema.validate(validData)
let invalidResult = schema.validate(invalidData)

// Check validation results
print(validResult.isValid) // true
print(invalidResult.isValid) // false

// Access validation errors
print(invalidResult.errors) // Display all errors
```

`required()` also catches a field whose key is missing entirely from the
input, not just an empty value:

```swift
let nameSchema = ValidationSchema()
    .field("name").required()
    .ready()

let result = nameSchema.validate([:]) // "name" key is absent, not just empty
print(result.isValid) // false
print(result.errors["name"]!) // ["This field is required."]
```

## Rules

| Rule Name      | Description                                           |
|----------------|-------------------------------------------------------|
| `custom()`     | Allows for custom validation logic with a message.   |
| `email()`      | Validates that the field contains a valid email format. |
| `min(value)`   | Ensures the value is greater than or equal to the specified minimum. |
| `max(value)`   | Ensures the value is less than or equal to the specified maximum. |
| `numeric()`    | Validates that the field contains a numeric value.   |
| `date()`       | Validates that the field contains a valid date.      |
| `range(range)` | Validates that the value falls within a specified range. |
| `pattern(pattern)` | Validates that the value matches a specified regex pattern. |
| `URL()`        | Validates that the field contains a valid URL.       |
| `inArray(array)` | Validates that the value is one of the allowed values in the array. |
| `requiredIf(condition)` | Makes the field required based on a specified condition. |
| `required()`   | Ensures the field is present and not empty.          |
| `greaterThan(value)` | Validates that the value is greater than the specified value. |
| `lessThan(value)` | Validates that the value is less than the specified value. |
| `MIMETypes(types)` | Validates that the file type matches one of the allowed MIME types. |



## Length Validation and Grapheme Clusters

ValidatorKit's length-based rules (`min`, `max`) use Swift's `String.count`, which counts **extended grapheme clusters**. This means:

- Emoji are counted correctly as single characters (e.g., "😀" = 1, "🇺🇸" = 1)
- Combining diacritics are handled properly (e.g., "e\u{0301}" = 1, not 2)
- ZWJ sequences count as single characters (e.g., "👨‍👩‍👧‍👦" = 1)

This is the correct behavior for user-facing validation, especially for internationalized applications using Arabic, Hebrew, or other languages with combining marks.

## Releasing

Releases follow [Semantic Versioning](https://semver.org/). Every pull request should carry exactly one of the `major`, `minor`, or `patch` labels, describing the size of its change:

| Label | When to use it |
|-------|-----------------|
| `major` | Breaking API change (`x.0.0`) |
| `minor` | New backwards-compatible feature (`0.x.0`) |
| `patch` | Backwards-compatible bug fix or tweak (`0.0.x`) |

On every merge to `master`, [Release Drafter](https://github.com/release-drafter/release-drafter) updates a **draft** GitHub Release: it resolves the next version from the merged PRs' labels (highest bump wins) and compiles a changelog from their titles. Nothing is published automatically — review the draft under [Releases](../../releases) and publish it (which also creates the `vX.Y.Z` git tag SPM consumers pin to) whenever you're ready to ship.
