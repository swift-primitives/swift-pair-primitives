// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-pair",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Pair",
            targets: ["Pair"]
        ),
        .library(
            name: "Pair Standard Library Integration",
            targets: ["Pair Standard Library Integration"]
        ),
        .library(
            name: "Pair Apple Foundation Integration",
            targets: ["Pair Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Pair",
            dependencies: []
        ),
        .target(
            name: "Pair Standard Library Integration",
            dependencies: ["Pair"]
        ),
        .target(
            name: "Pair Apple Foundation Integration",
            dependencies: [
                "Pair",
                "Pair Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Pair Tests",
            dependencies: ["Pair"],
            path: "Tests/Pair Tests"
        ),
        .testTarget(
            name: "Pair Standard Library Integration Tests",
            dependencies: [
                "Pair",
                "Pair Standard Library Integration",
            ],
            path: "Tests/Pair Standard Library Integration Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
