import Foundation

public final class ValidatorKit: @unchecked Sendable  {
    public static let shared = ValidatorKit()
    
    private var ruleSets: [String: [AnyValidationRule]] = [:]
    private let queue = DispatchQueue(label: "com.swiftvalidate.ValidatorKit", attributes: .concurrent)

    private init() {}
    
    public func register<R: ValidationRule>(rules: [R], forKey key: String) {
        let anyRules = rules.map(AnyValidationRule.init)
        queue.async(flags: .barrier) {
            self.ruleSets[key] = anyRules
        }
    }
    
    public func validate(_ value: Any?, forKey key: String) -> [ValidationError] {
        queue.sync {
            guard let rulesForKey = ruleSets[key] else {
                return []
            }
            return rulesForKey.compactMap { $0.validate(value) }
        }
    }
}
