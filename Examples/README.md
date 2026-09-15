# Examples

- **[CommandLineExample](CommandLineExample)** — a real, runnable SPM executable that depends on `ValidatorKit` (via a local path dependency on this repo) and validates a small sign-up-style schema against a valid and an invalid record, printing the results. Run it with:

  ```sh
  cd Examples/CommandLineExample
  swift run
  ```

- **[SwiftUIExample/SignUpView.swift](SwiftUIExample/SignUpView.swift)** — reference code (not a buildable package — SwiftUI apps need a real app target, which SPM can't produce standalone) showing `ObservableValidationSchema` wired into a sign-up form, with live per-field error display. Copy it into an app project that depends on `ValidatorKit` and `ValidatorKitSwiftUI`.
