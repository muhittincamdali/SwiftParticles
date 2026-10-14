<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-light.svg" alt="Animation Masterclass: Physics-based motion, particles, change effects and transitions for SwiftUI on iOS and macOS."></picture></p>

<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a></p>

# SwiftParticles has moved

**This project now lives in [SwiftUI-Animation-Masterclass](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass).**
This repository is archived and will not change again. Its last release here is
[v1.0.0](https://github.com/muhittincamdali/SwiftParticles/releases/tag/v1.0.0).

## Where the code went

SwiftUI-Animation-Masterclass 2.0.0 rewrote the useful parts of this repository as its
[Particles](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/tree/main/Sources/SwiftUIAnimationMasterclass/Particles)
module, drawn in a single SwiftUI `Canvas` and covered by tests.

| Here                  | In SwiftUI-Animation-Masterclass                                                                                                                                                                                                        |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Emitters              | [`ParticleEmitter`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticleEmitter.swift)                                                                     |
| Forces                | [`ParticleForce`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticleForce.swift): gravity, wind, turbulence, attractor and vortex                        |
| Presets               | [`ParticlePresets`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticlePresets.swift): confetti, fireworks, snow, rain, sparkles, bubbles, hearts, embers |
| SwiftUI view modifier | [`ParticleView`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticleView.swift) with `.particleEffect(_:isActive:)` and `.particleBurst(_:trigger:)`      |

Not everything came along. The package has 8 presets, not the 25 that were listed here. The Metal
renderer, the fluid dynamics skeleton, 3D particles, the visionOS integration and the `Enterprise`
helpers (`CircuitBreaker`, `RetryPolicy`, `EventBus`) were not carried over. See the
[2.0.0 changelog](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/CHANGELOG.md)
for the exact scope.

## Install the new package

```swift
.package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "2.0.0")
```

Then add `.product(name: "SwiftUIAnimationMasterclass", package: "SwiftUI-Animation-Masterclass")` to
your target. It needs iOS 17 or macOS 14, and Swift 6.2. Full documentation:
[SwiftUI-Animation-Masterclass README](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass#readme).

## License

MIT, see [LICENSE](LICENSE).
