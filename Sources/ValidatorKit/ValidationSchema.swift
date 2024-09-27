public class ValidationSchema {
    private var rules: [String: [AnyValidationRule]] = [:]
    
    public init() {}
    
    @discardableResult
    public func field(_ name: String) -> FieldValidator {
        return FieldValidator(name: name, schema: self)
    }
    
    public func validate(_ object: [String: Any]) -> ValidationResult {
        var errors: [String: [String]] = [:]
        
        for (field, fieldRules) in rules {
            if let value = object[field] {
                let fieldErrors = fieldRules.compactMap { $0.validate(value) }
                if !fieldErrors.isEmpty {
                    errors[field] = fieldErrors.map { $0.message }
                }
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
    public func custom(message: String,validation: @escaping (Any?) -> Bool ) -> FieldValidator {
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
    public func max(_ value: Double,message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(MinRule(value: value,message: message)))
        return self
    }
    
    @discardableResult
    public func numeric(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(NumericRule(message: message)))
        return self
    }
    
    @discardableResult
    public func date(range: DateRange? = nil, format: String = "yyyy-MM-dd",message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(DateRule(range: range,format: format,message: message)))
        return self
    }
    
    @discardableResult
    public func range(_ range: ClosedRange<Int>, message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(RangeRule(range: range, message: message)))
        return self
    }

    @discardableResult
    public func pattern(_ pattern: String,message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(PatternRule(pattern: pattern,message: message)))
        return self
    }
    
    @discardableResult
    public func URL(message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(URLRule(message: message)))
        return self
    }
    
    @discardableResult
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
    
    public func leassThan(_ value: Double,message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(LessThanRule(maxValue: value, message: message)))
        return self
    }
    
    @discardableResult
    public func MIMETypes(_ MIMETypes: [String],message: String? = nil) -> FieldValidator {
        schema.addRule(name, AnyValidationRule(FileExtensionsRule(allowedExtensions: MIMETypes,message: message)))
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
