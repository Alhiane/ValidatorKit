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
        .library(
            name: "ValidatorKitSwiftUI",
            targets: ["ValidatorKitSwiftUI"]),
        .library(
            name: "ValidatorKitUIKit",
            targets: ["ValidatorKitUIKit"]),
    ],
    targets: [
        .target(
            name: "ValidatorKit",
            resources: [
                .process("Resources/Localization")
            ]
        ),
        .target(
            name: "ValidatorKitSwiftUI",
            dependencies: ["ValidatorKit"]
        ),
        .target(
            name: "ValidatorKitUIKit",
            dependencies: ["ValidatorKit"]
        ),
        .testTarget(
            name: "ValidatorKitTests",
            dependencies: ["ValidatorKit"]
        ),
        .testTarget(
            name: "ValidatorKitSwiftUITests",
            dependencies: ["ValidatorKitSwiftUI"]
        ),
        .testTarget(
            name: "ValidatorKitUIKitTests",
            dependencies: ["ValidatorKitUIKit"]
        ),
    ]
)
