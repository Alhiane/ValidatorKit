// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CommandLineExample",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Standalone consumer pattern: depend on ValidatorKit the same way an
        // external app would, just pointed at the local checkout instead of a
        // git URL/tag. The explicit `name:` pins the package identity to
        // "ValidatorKit" regardless of what the checkout directory happens to
        // be named on disk (SwiftPM would otherwise derive it from the
        // directory name).
        .package(name: "ValidatorKit", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "CommandLineExample",
            dependencies: [
                .product(name: "ValidatorKit", package: "ValidatorKit")
            ]
        )
    ]
)
