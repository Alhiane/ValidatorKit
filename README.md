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

// setup your schema
let schema = ValidationSchema()
    .field("username").required()
    .field("email").required().email()
    .field("gender").requiredIf(username == "johndoe")
    .schema()
        
// start the validation whenever you wan't in your code
let username = "alhiane"
let email = "aie@aie.aie"
let invalidData: [String: Any] = [
    "username": username,
    "email": email,
    "gender": ""
]

// validate function
let validResult = schema.validate(validData)
        
// check your data at once
validResult.isValid

// Access all your data validation rules errors
validResult.errors

validResult.errors.count == 2
validResult.errors["username"]
validResult.errors["email"]
```

## Rules
    
custom()
email()
min()
max()
numeric()
date()
range()
pattern()
URL()
inArray()
requiredIf()
required()
greaterThan()
leassThan()
MIMETypes()
