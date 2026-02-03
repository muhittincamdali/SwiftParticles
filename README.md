<p align="center">
  <img src="https://raw.githubusercontent.com/muhittincamdali/SwiftParticles/main/Assets/logo.png" alt="SwiftParticles Logo" width="200">
</p>

<h1 align="center">SwiftParticles</h1>

<p align="center">
  <strong>✨ High-performance particle system for Swift and SwiftUI</strong>
</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.9+-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9+"></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20visionOS-blue?style=flat-square" alt="Platforms"></a>
  <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-Compatible-brightgreen?style=flat-square&logo=swift" alt="SPM Compatible"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License: MIT"></a>
  <br>
  <a href="https://github.com/muhittincamdali/SwiftParticles/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/muhittincamdali/SwiftParticles/ci.yml?branch=main&style=flat-square&logo=github&label=CI" alt="CI Status"></a>
  <a href="https://github.com/muhittincamdali/SwiftParticles/stargazers"><img src="https://img.shields.io/github/stars/muhittincamdali/SwiftParticles?style=flat-square&logo=github" alt="Stars"></a>
  <a href="https://github.com/muhittincamdali/SwiftParticles/graphs/contributors"><img src="https://img.shields.io/github/contributors/muhittincamdali/SwiftParticles?style=flat-square" alt="Contributors"></a>
  <a href="https://github.com/muhittincamdali/SwiftParticles/issues"><img src="https://img.shields.io/github/issues/muhittincamdali/SwiftParticles?style=flat-square" alt="Issues"></a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#presets">Presets</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## ✨ Features

- **🚀 Metal-Powered** — GPU-accelerated rendering for thousands of particles at 60+ FPS
- **🎨 SwiftUI Native** — First-class SwiftUI support with declarative API
- **📦 Pre-built Presets** — Fire, smoke, snow, rain, confetti, and more
- **🔧 Highly Customizable** — Control every aspect of particle behavior
- **🌊 Physics Simulation** — Gravity, wind, turbulence, and collision
- **🎭 Lifetime Animations** — Color, size, and alpha changes over time
- **⚡ Optimized** — Particle pooling and efficient memory management
- **📱 Multi-Platform** — iOS, macOS, tvOS, and visionOS support

## 📋 Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 15.0+          |
| macOS    | 12.0+          |
| tvOS     | 15.0+          |
| visionOS | 1.0+           |
| Swift    | 5.9+           |
| Xcode    | 15.0+          |

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftParticles.git", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'SwiftParticles', '~> 1.0'
```

## 🚀 Quick Start

### SwiftUI

```swift
import SwiftUI
import SwiftParticles

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
            ParticleEmitter(preset: .fire)
                .frame(width: 200, height: 300)
        }
    }
}
```

### Custom Configuration

```swift
let emitter = ParticleEmitter {
    Particle()
        .birthRate(100)
        .lifetime(2.0...4.0)
        .velocity(50...150)
        .emissionAngle(-90, spread: 30)
        .scale(0.1...0.5)
        .colorOverLifetime([.white, .yellow, .orange, .clear])
}
```

## 🎨 Presets

| Preset | Description |
|--------|-------------|
| `.fire` | Realistic flame effect |
| `.smoke` | Soft, billowing smoke |
| `.snow` | Gentle falling snowflakes |
| `.rain` | Rainfall with streaks |
| `.confetti` | Celebration confetti burst |
| `.sparkle` | Twinkling sparkle effect |

## 📖 Documentation

See the [Documentation](Documentation/) folder.

## 🛡️ Security

See [SECURITY.md](SECURITY.md).

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 License

MIT License - see [LICENSE](LICENSE).

## 👨‍💻 Author

**Muhittin Camdali** - [@muhittincamdali](https://github.com/muhittincamdali)

---

<p align="center">
  <sub>Built with ❤️ for the Swift community</sub>
</p>
