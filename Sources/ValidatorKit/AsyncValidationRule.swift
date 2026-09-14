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
///
/// `validateAsync` evaluates each field on its own child task, so rules of
/// different fields run concurrently and share the caller's cancellation:
/// once the task is cancelled, `Task.isCancelled` is `true` inside `validate`
/// and implementations should return as early as they can. Since `validate`
/// is non-throwing, a `CancellationError` cannot be propagated out of it.
public protocol AsyncValidationRule {
    func validate(_ value: Any?) async -> ValidationError?
    var message: String { get }
}
