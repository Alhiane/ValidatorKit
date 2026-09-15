//
//  SignUpView.swift
//  SwiftUIExample
//
//  Reference code, not a buildable target: SwiftUI apps need a real iOS/macOS
//  app target, which Swift Package Manager can't produce standalone, so this
//  file isn't wired into any Package.swift here. Copy it (and adjust to
//  taste) into an actual app project that depends on ValidatorKit and
//  ValidatorKitSwiftUI. See Examples/README.md.
//
//  It shows ObservableValidationSchema driving a sign-up form: an email
//  field and a password field (with passwordStrength), live-validated as
//  the user types, with errors displayed inline.
//

import SwiftUI
import ValidatorKit
import ValidatorKitSwiftUI

@MainActor
final class SignUpFormModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""

    let schema = ObservableValidationSchema(
        schema: ValidationSchema()
            .field("email").required().email()
            .field("password").required().passwordStrength(
                minLength: 8,
                requireUppercase: true,
                requireDigit: true,
                requireSymbol: true,
                rejectCommon: true
            )
            .ready()
    )

    init() {
        schema.bind("email", to: $email)
        schema.bind("password", to: $password)
    }

    var canSubmit: Bool {
        schema.validateNow().isValid
    }
}

struct SignUpView: View {
    @StateObject private var form = SignUpFormModel()

    var body: some View {
        Form {
            Section("Account") {
                TextField("Email", text: $form.email)
                    #if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    #endif
                errorText(for: "email")

                SecureField("Password", text: $form.password)
                errorText(for: "password")
            }

            Section {
                Button("Sign Up") {
                    guard form.canSubmit else { return }
                    // Submit form.email / form.password to your backend here.
                }
                .disabled(!form.schema.result.isValid)
            }
        }
        .navigationTitle("Sign Up")
    }

    @ViewBuilder
    private func errorText(for field: String) -> some View {
        if let message = form.schema.errors(for: field).first {
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
        }
    }
}
