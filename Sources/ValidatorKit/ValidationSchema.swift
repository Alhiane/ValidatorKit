/// A schema is built up through the `field(_:).rule()...` chain and is expected to
/// stop mutating once `ready()` returns, before any validation runs. `@unchecked`
/// is safe under that contract: without it a `@MainActor`-isolated schema (e.g. one
/// stored on a view model) could not be sent into the nonisolated `validateAsync`.
public class ValidationSchema: @unchecked Sendable {
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
            let fieldErrors = fieldRules.compactMap { $0.validate(value, in: object) }
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
    ///
    /// Async rules run concurrently across fields — each field gets its own child
    /// task — while the rules of a single field still run sequentially in
    /// registration order, preserving the order of that field's error messages.
    /// `ValidationResult.errors` is keyed by field, so no cross-field ordering
    /// is promised either way.
    ///
    /// Cancellation is cooperative: a cancelled task stops spawning field tasks
    /// and stops running further rules on each field. In-flight rules observe
    /// `Task.isCancelled == true`; because `AsyncValidationRule.validate` is
    /// non-throwing they cannot propagate `CancellationError`, so a cancelled
    /// `validateAsync` returns the errors collected so far rather than throwing.
    public func validateAsync(_ object: [String: Any]) async -> ValidationResult {
        var errors: [String: [String]] = [:]

        for (field, fieldRules) in rules {
            let value = object[field]
            let fieldErrors = fieldRules.compactMap { $0.validate(value, in: object) }
            if !fieldErrors.isEmpty {
                errors[field] = fieldErrors.map { $0.message }
            }
        }

        // Fields whose sync rules already failed skip their async rules entirely.
        let pending = asyncRules.compactMap { field, fieldRules -> AsyncWorkItem? in
            guard errors[field] == nil else { return nil }
            return AsyncWorkItem(field: field, value: object[field], rules: fieldRules)
        }

        // One child task per field; each runs its rules sequentially so the
        // field's messages keep registration order. Results are collected into
        // a local dictionary — no shared mutable state across tasks.
        let asyncErrors: [String: [String]] = await withTaskGroup(
            of: (field: String, messages: [String]).self,
            returning: [String: [String]].self
        ) { group in
            for workItem in pending {
                if Task.isCancelled { break }
                group.addTask {
                    var messages: [String] = []
                    for rule in workItem.rules {
                        if Task.isCancelled { break }
                        if let error = await rule.validate(workItem.value) {
                            messages.append(error.message)
                        }
                    }
                    return (workItem.field, messages)
                }
            }

            var collected: [String: [String]] = [:]
            for await (field, messages) in group where !messages.isEmpty {
                collected[field] = messages
            }
            return collected
        }

        for (field, messages) in asyncErrors {
            errors[field] = messages
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

/// A field's pending async validation work, captured by the child tasks spawned
/// in `ValidationSchema.validateAsync(_:)`. The `Any?` value under test is not
/// `Sendable`, hence `@unchecked`: safe here because the box is immutable and
/// only ever read for the lifetime of the task group.
private struct AsyncWorkItem: @unchecked Sendable {
    let field: String
    let value: Any?
    let rules: [AnyAsyncValidationRule]
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
        rejectCommon: Bool = false,
        message: String? = nil
    ) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(PasswordStrengthRule(
            minLength: minLength,
            requireUppercase: requireUppercase,
            requireLowercase: requireLowercase,
            requireDigit: requireDigit,
            requireSymbol: requireSymbol,
            rejectCommon: rejectCommon,
            message: message
        )))
        return self
    }

    @discardableResult
    public func notCommonPassword(
        commonPasswords: Set<String> = NotCommonPasswordRule.defaultCommonPasswords,
        message: String? = nil
    ) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(NotCommonPasswordRule(commonPasswords: commonPasswords, message: message)))
        return self
    }

    // cross-field rules
    @discardableResult
    public func matches(_ otherField: String, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(MatchesFieldRule(otherField: otherField, message: message)))
        return self
    }

    @discardableResult
    public func dateBefore(_ otherField: String, format: String = "yyyy-MM-dd", message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(DateBeforeFieldRule(otherField: otherField, format: format, message: message)))
        return self
    }

    @discardableResult
    public func dateAfter(_ otherField: String, format: String = "yyyy-MM-dd", message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(DateAfterFieldRule(otherField: otherField, format: format, message: message)))
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

public struct ValidationResult: Sendable {
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
