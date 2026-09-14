//
//  ObservableValidationSchema.swift
//  ValidatorKitSwiftUI
//

import Combine
import Foundation
import ValidatorKit

/// Binds a `ValidationSchema` to live SwiftUI/Combine form state.
///
/// Bind each field to its view model's `@Published` publisher (typically the
/// projected value, e.g. `viewModel.$email`) with `bind(_:to:debounce:)`. Every time a
/// bound publisher emits, the field's latest value is captured immediately and the whole
/// schema is re-validated after `debounce` elapses without a further emission — so
/// `result` updates live as the user types without re-running every rule on every
/// keystroke.
///
/// `ValidatorKit`'s core target stays pure Swift + Foundation with zero dependencies;
/// this type lives in the separate `ValidatorKitSwiftUI` product so SwiftUI/Combine
/// remain opt-in for consumers who don't need reactive bindings.
///
/// ```swift
/// final class SignUpForm: ObservableObject {
///     @Published var email = ""
///     @Published var age = 0
/// }
///
/// let form = SignUpForm()
/// let schema = ObservableValidationSchema(
///     schema: ValidationSchema()
///         .field("email").required().email()
///         .field("age").required().greaterThan(18)
///         .ready()
/// )
/// schema.bind("email", to: form.$email)
/// schema.bind("age", to: form.$age)
/// ```
@MainActor
public final class ObservableValidationSchema: ObservableObject {
    /// The result of the most recent validation run. Starts out as the wrapped schema
    /// validating an empty object, before any field has been bound or has emitted.
    @Published public private(set) var result: ValidationResult

    private let schema: ValidationSchema
    private var values: [String: Any] = [:]
    private var subscriptions: [String: Set<AnyCancellable>] = [:]

    /// Wraps an already-built schema, created via the `ValidationSchema().field(...).ready()`
    /// chain. `ObservableValidationSchema` only drives re-validation of an existing schema —
    /// it doesn't replicate the builder API.
    public init(schema: ValidationSchema) {
        self.schema = schema
        self.result = schema.validate([:])
    }

    /// Binds a field's live publisher to this schema.
    ///
    /// The field's value is captured on every emission, but the schema is only
    /// re-validated after `debounce` elapses without a further emission on this
    /// publisher — rapid emissions (e.g. fast typing) coalesce into a single
    /// re-validation instead of one per keystroke. Because the whole `[String: Any]`
    /// object is validated together, the re-validation uses the latest known value of
    /// every field bound so far, not just this one.
    ///
    /// Binding the same field name again cancels its previous subscription first.
    public func bind<Value>(
        _ field: String,
        to publisher: Published<Value>.Publisher,
        debounce interval: RunLoop.SchedulerTimeType.Stride = .milliseconds(300)
    ) {
        bind(field, to: publisher, debounce: interval, scheduler: RunLoop.main)
    }

    /// Same as `bind(_:to:debounce:)`, but lets the caller supply the Combine scheduler
    /// the debounce timer runs on. `bind(_:to:debounce:)` forwards to this with
    /// `RunLoop.main`, which is what actually spins in a running SwiftUI app; this
    /// overload exists so tests (and anything else off the main run loop) can supply a
    /// scheduler that's reliably serviced, such as `DispatchQueue.main`.
    func bind<Value, S: Scheduler>(
        _ field: String,
        to publisher: Published<Value>.Publisher,
        debounce interval: S.SchedulerTimeType.Stride,
        scheduler: S
    ) {
        var bag = Set<AnyCancellable>()

        // Captured on every emission so `validateNow()` always sees the latest value,
        // even one still waiting out the debounce interval below.
        publisher
            .sink { [weak self] value in
                self?.values[field] = value
            }
            .store(in: &bag)

        // Coalesces rapid emissions into a single re-validation per quiet period.
        publisher
            .debounce(for: interval, scheduler: scheduler)
            .sink { [weak self] _ in
                self?.revalidate()
            }
            .store(in: &bag)

        subscriptions[field] = bag
    }

    /// Re-validates the schema against the current snapshot of bound field values
    /// immediately, bypassing any pending debounce — useful right before submit, so a
    /// value typed just before tapping submit isn't missed while its debounce is still
    /// pending.
    @discardableResult
    public func validateNow() -> ValidationResult {
        revalidate()
        return result
    }

    /// The errors currently recorded for `field`, or an empty array if it has none (or
    /// hasn't been validated yet).
    public func errors(for field: String) -> [String] {
        result.errors[field] ?? []
    }

    /// Whether `field` currently has no recorded errors.
    public func isValid(_ field: String) -> Bool {
        errors(for: field).isEmpty
    }

    private func revalidate() {
        result = schema.validate(values)
    }
}
