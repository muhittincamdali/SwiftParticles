<div align="center">

# ✨ SwiftParticles

**GPU-accelerated particle system for SwiftUI with Metal shaders**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start)

</div>

---

## ✨ Features

- 🎆 **GPU Powered** — Metal-based rendering for 60fps
- 🎨 **Customizable** — Colors, sizes, behaviors
- 📱 **SwiftUI Native** — Works as view modifier
- 🎯 **Presets** — Snow, fire, confetti, sparkles
- ⚡ **High Performance** — Handles 10,000+ particles

---

## 📦 Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftParticles.git", from: "1.0.0")
]
```

---

## 🚀 Quick Start

```swift
import SwiftParticles

struct ContentView: View {
    var body: some View {
        Text("Hello")
            .particleEffect(.confetti)
    }
}

// Custom particles
ParticleView(
    emitter: .init(
        rate: 100,
        lifetime: 2.0,
        colors: [.red, .orange, .yellow]
    )
)
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 👨‍💻 Author

**Muhittin Camdali** • [@muhittincamdali](https://github.com/muhittincamdali)
