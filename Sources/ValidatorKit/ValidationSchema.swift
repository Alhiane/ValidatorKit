public class ValidationSchema {
    private var rules: [String: [AnyValidationRule]] = [:]
    private var asyncRules: [String: [AnyAsyncValidationRule]] = [:]

    public init() {}

    @discardableResult
    public func field(_ name: String) -> FieldValidator {
        return FieldValidator(name: name, schema: self)
    }

    public func validate(_ object: [String: Any]) -> ValidationResult {
        var errors: [String: [String]] = [:]

        for (field, fieldRules) in rules {
            let value = object[field]
            let fieldErrors = fieldRules.compactMap { $0.validate(value) }
            if !fieldErrors.isEmpty {
                errors[field] = fieldErrors.map { $0.message }
            }
        }

        return ValidationResult(errors: errors)
    }

    /// Async variant of `validate(_:)` that also runs the `AsyncValidationRule`s
    /// registered via `FieldValidator.customAsync(message:validation:)` and
    /// `FieldValidator.asyncRule(_:)`.
    ///
    /// Sync rules run first, exactly as in `validate(_:)`. A field's async rules are
    /// only awaited when all of its sync rules pass, so a cheap local failure
    /// (e.g. a malformed or empty username) never triggers a remote check.
    public func validateAsync(_ object: [String: Any]) async -> ValidationResult {
        var errors: [String: [String]] = [:]

        for (field, fieldRules) in rules {
            let value = object[field]
            let fieldErrors = fieldRules.compactMap { $0.validate(value) }
            if !fieldErrors.isEmpty {
                errors[field] = fieldErrors.map { $0.message }
            }
        }

        for (field, fieldRules) in asyncRules where errors[field] == nil {
            let value = object[field]
            var fieldErrors: [ValidationError] = []
            for rule in fieldRules {
                if let error = await rule.validate(value) {
                    fieldErrors.append(error)
                }
            }
            if !fieldErrors.isEmpty {
                errors[field] = fieldErrors.map { $0.message }
            }
        }

        return ValidationResult(errors: errors)
    }

    fileprivate func addRule(_ name: String, _ rule: AnyValidationRule) {
        if rules[name] == nil {
            rules[name] = []
        }
        rules[name]?.append(rule)
    }

    fileprivate func addAsyncRule(_ name: String, _ rule: AnyAsyncValidationRule) {
        if asyncRules[name] == nil {
            asyncRules[name] = []
        }
        asyncRules[name]?.append(rule)
    }
}

public class FieldValidator {
    private let name: String
    private let schema: ValidationSchema

    fileprivate init(name: String, schema: ValidationSchema) {
        self.name = name
        self.schema = schema
    }

    @discardableResult
    public func field(_ name: String) -> FieldValidator {
        return schema.field(name)
    }

    // rules
    @discardableResult
    public func custom(message: String, validation: @escaping (Any?) -> Bool ) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(CustomRule(validation: validation, message: message)))
        return self
    }

    @discardableResult
    public func required(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(RequiredRule(message: message)))
        return self
    }

    @discardableResult
    public func email(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(EmailRule(message: message)))
        return self
    }

    @discardableResult
    public func min(_ value: Double, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(MinRule(value: value, message: message)))
        return self
    }

    @discardableResult
    public func max(_ value: Double, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(MaxRule(value: value, message: message)))
        return self
    }

    @discardableResult
    public func numeric(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(NumericRule(message: message)))
        return self
    }

    @discardableResult
    public func date(range: DateRange? = nil, format: String = "yyyy-MM-dd", message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(DateRule(range: range, format: format, message: message)))
        return self
    }

    @discardableResult
    public func range(_ range: ClosedRange<Int>, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(RangeRule(range: range, message: message)))
        return self
    }

    @discardableResult
    public func pattern(_ pattern: String, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(PatternRule(pattern: pattern, message: message)))
        return self
    }

    @discardableResult
    public func URL(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(URLRule(message: message)))
        return self
    }

    @discardableResult
    // swiftlint:disable:next identifier_name - parameter label `Array` matches the public API surface; renaming is a breaking change for consumers.
    public func inArray(_ Array: [Any], message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(InArrayRule(allowedValues: Array, message: message)))
        return self
    }

    @discardableResult
    public func requiredIf(_ condition: Bool, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(RequireIfRule(conditionValue: condition, message: message)))
        return self
    }

    @discardableResult
    public func greaterThan(_ value: Double, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(GreaterThanRule(minValue: value, message: message)))
        return self
    }

    @discardableResult
    public func lessThan(_ value: Double, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(LessThanRule(maxValue: value, message: message)))
        return self
    }

    @available(*, deprecated, renamed: "lessThan")
    @discardableResult
    public func leassThan(_ value: Double, message: String? = nil) -> FieldValidator {
        lessThan(value, message: message)
    }

    @discardableResult
    public func MIMETypes(_ MIMETypes: [String], message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(FileExtensionsRule(allowedExtensions: MIMETypes, message: message)))
        return self
    }

    @discardableResult
    public func phoneNumber(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(PhoneNumberRule(message: message)))
        return self
    }

    @discardableResult
    public func creditCard(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(CreditCardRule(message: message)))
        return self
    }

    @discardableResult
    public func IBAN(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(IBANRule(message: message)))
        return self
    }

    @discardableResult
    public func maxFileSize(_ bytes: Int, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(FileSizeRule(maxBytes: bytes, message: message)))
        return self
    }

    @discardableResult
    public func passwordStrength(
        minLength: Int = 8,
        requireUppercase: Bool = false,
        requireLowercase: Bool = false,
        requireDigit: Bool = false,
        requireSymbol: Bool = false,
        message: String? = nil
    ) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(PasswordStrengthRule(minLength: minLength, requireUppercase: requireUppercase, requireLowercase: requireLowercase, requireDigit: requireDigit, requireSymbol: requireSymbol, message: message)))
        return self
    }

    /// The async counterpart of `custom(message:validation:)`, for checks that must be
    /// awaited — e.g. asking a backend whether a username or email is still available.
    /// Only evaluated by `ValidationSchema.validateAsync(_:)`.
    @discardableResult
    public func customAsync(message: String, validation: @escaping (Any?) async -> Bool) -> FieldValidator {
        schema.addAsyncRule(name, AnyAsyncValidationRule(CustomAsyncRule(validation: validation, message: message)))
        return self
    }

    /// Registers any `AsyncValidationRule` conformance on this field.
    /// Only evaluated by `ValidationSchema.validateAsync(_:)`.
    @discardableResult
    public func asyncRule<R: AsyncValidationRule>(_ rule: R) -> FieldValidator {
        schema.addAsyncRule(name, AnyAsyncValidationRule(rule))
        return self
    }

    // return schema
    @discardableResult
    public func ready() -> ValidationSchema {
        return schema
    }
}

public struct ValidationResult {
    public let errors: [String: [String]]

    public var isValid: Bool {
        return errors.isEmpty
    }
}

public struct CustomRule: ValidationRule {
    let validation: (Any?) -> Bool
    public let message: String

    public init(validation: @escaping (Any?) -> Bool, message: String? = nil) {
        self.validation = validation
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.customKey, defaultMessage: ValidationMessage.custom)
    }

    public func validate(_ value: Any?) -> ValidationError? {
        return validation(value) ? nil : ValidationError(message: message)
    }
}

/// Closure-based `AsyncValidationRule`, the async counterpart of `CustomRule`.
public struct CustomAsyncRule: AsyncValidationRule {
    let validation: (Any?) async -> Bool
    public let message: String

    public init(validation: @escaping (Any?) async -> Bool, message: String? = nil) {
        self.validation = validation
        self.message = message ?? ValidationMessage.message(for: ValidationMessage.customKey, defaultMessage: ValidationMessage.custom)
    }

    public func validate(_ value: Any?) async -> ValidationError? {
        return await validation(value) ? nil : ValidationError(message: message)
    }
}
