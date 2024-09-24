# ValidatorKit

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
| `leassThan(value)` | Validates that the value is less than the specified value. |
| `MIMETypes(types)` | Validates that the file type matches one of the allowed MIME types. |

