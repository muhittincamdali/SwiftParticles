// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftParticles",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "SwiftParticles", targets: ["SwiftParticles"]),
    ],
    targets: [
        .target(
            name: "SwiftParticles",
            path: "Sources/SwiftParticles",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftParticlesTests",
            dependencies: ["SwiftParticles"]
        )
    ]
)
