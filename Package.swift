// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftParticles",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SwiftParticles",
            targets: ["SwiftParticles"]
        )
    ],
    targets: [
        .target(
            name: "SwiftParticles",
            path: "Sources/SwiftParticles",
            resources: [
                .process("Renderer/ParticleShader.metal")
            ]
        ),
        .testTarget(
            name: "SwiftParticlesTests",
            dependencies: ["SwiftParticles"],
            path: "Tests/SwiftParticlesTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
