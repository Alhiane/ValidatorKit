// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ValidatorKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "ValidatorKit",
            targets: ["ValidatorKit"]),
    ],
    targets: [
        .target(
            name: "ValidatorKit",
            resources: [
                .process("Resources/Localization")
            ]
        ),
        .testTarget(
            name: "ValidatorKitTests",
            dependencies: ["ValidatorKit"]
        ),
    ]
)
