# Contributing to ValidatorKit

Thanks for considering a contribution! A few notes to make the process smooth.

Please note that this project follows a [Code of Conduct](CODE_OF_CONDUCT.md) — by participating, you're expected to uphold it.

## Development

- `swift build` and `swift test` before opening a PR.
- Lint with [SwiftLint](https://github.com/realm/SwiftLint): `swiftlint lint --strict`.
- CI runs both on every PR.

## Adding a rule

Rules live in `Sources/ValidatorKit/Rules/` as a `ValidationRule`-conforming struct. Look at an existing rule (e.g. `EmailRule.swift`) for the expected shape: a `message` property, an `init(..., message: String? = nil)`, and a `validate(_ value: Any?) -> ValidationError?` method. Wire it up as a `FieldValidator` method in `ValidationSchema.swift`, add default + localized messages in `ValidationMessage.swift` and the `Resources/Localization/*.lproj` files, and add test coverage in `Tests/ValidatorKitTests/ValidatorKitTests.swift`.

## Length validation and grapheme clusters

`min`/`max` use Swift's `String.count`, which counts **extended grapheme clusters** rather than Unicode scalars — so emoji (including flag and ZWJ sequences) and combining diacritics are each counted as a single character. Keep this in mind when adding or reviewing length-related rules, especially given the library's Arabic/Hebrew localization use cases.

## Versioning & releases

Releases follow [Semantic Versioning](https://semver.org/). Every pull request should carry exactly one of the `major`, `minor`, or `patch` labels, describing the size of its change:

| Label | When to use it |
|-------|-----------------|
| `major` | Breaking API change (`x.0.0`) |
| `minor` | New backwards-compatible feature (`0.x.0`) |
| `patch` | Backwards-compatible bug fix or tweak (`0.0.x`) |

On every merge to `master`, [Release Drafter](https://github.com/release-drafter/release-drafter) updates a **draft** GitHub Release: it resolves the next version from the merged PRs' labels (highest bump wins) and compiles a changelog from their titles. Nothing is published automatically — review the draft under [Releases](../../releases) and publish it (which also creates the `vX.Y.Z` git tag SPM consumers pin to) whenever ready to ship.
