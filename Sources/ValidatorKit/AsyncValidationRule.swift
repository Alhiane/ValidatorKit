//
//  AsyncValidationRule.swift
//  ValidatorKit
//
//  Created by Louis Deconinck on 13/9/2026.
//

import Foundation

/// The async counterpart of `ValidationRule`, for checks that cannot complete
/// synchronously — e.g. asking a backend whether a username is still available.
///
/// Register async rules through `FieldValidator.customAsync(message:validation:)`
/// or `FieldValidator.asyncRule(_:)`, then evaluate the schema with
/// `ValidationSchema.validateAsync(_:)`. `ValidationSchema.validate(_:)`
/// only runs synchronous rules and never awaits async ones.
public protocol AsyncValidationRule {
    func validate(_ value: Any?) async -> ValidationError?
    var message: String { get }
}
