<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20visionOS-blue?style=for-the-badge" alt="Platform">
</p>

<h1 align="center">✨ SwiftParticles</h1>

<p align="center">
  <strong>The most powerful particle system for SwiftUI</strong>
</p>

<p align="center">
  GPU-accelerated • 25+ Presets • Interactive • 3D Ready • VisionOS Native
</p>

<p align="center">
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#presets">Presets</a> •
  <a href="#features">Features</a> •
  <a href="#documentation">Docs</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.9+-orange?style=flat-square&logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-Native-blue?style=flat-square&logo=swift" alt="SwiftUI">
  <img src="https://img.shields.io/badge/Metal-GPU-green?style=flat-square&logo=apple" alt="Metal">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License">
  <img src="https://img.shields.io/github/stars/muhittincamdali/SwiftParticles?style=flat-square" alt="Stars">
</p>

---

## 🎯 Why SwiftParticles?

| Feature | SwiftParticles | Vortex | SpriteKit |
|---------|---------------|--------|-----------|
| **SwiftUI Native** | ✅ | ✅ | ❌ |
| **Metal GPU** | ✅ | ❌ | ✅ |
| **Preset Count** | **25+** | 12 | N/A |
| **Interactive Particles** | ✅ | ❌ | ❌ |
| **3D Particles** | ✅ | ❌ | ❌ |
| **VisionOS Support** | ✅ | ✅ | ❌ |
| **Real-time Editor** | ✅ | ❌ | ❌ |
| **Particle Trails** | ✅ | ❌ | ✅ |
| **Physics Collision** | ✅ | ❌ | ✅ |
| **Performance Profiler** | ✅ | ❌ | ❌ |

---

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftParticles.git", from: "1.0.0")
]
```

### Xcode

1. File → Add Packages
2. Enter: `https://github.com/muhittincamdali/SwiftParticles.git`
3. Click Add Package

---

## 🚀 Quick Start

### One-Line Confetti

```swift
import SwiftParticles

struct ContentView: View {
    var body: some View {
        ParticleView(preset: .confetti)
    }
}
```

### Interactive Magic

```swift
InteractiveParticleView(preset: MagicPreset.configuration)
    .interactionMode(.attract)
    .interactionRadius(100)
```

### View Modifier

```swift
Text("🎉 Celebration!")
    .confetti(isActive: $showConfetti)
```

---

## 🎨 25+ Built-in Presets

### 🎊 Celebration
| Preset | Preview | Usage |
|--------|---------|-------|
| **Confetti** | 🎊 Rainbow celebration | `ParticleView(preset: .confetti)` |
| **Fireworks** | 🎆 Multi-stage explosions | `ParticleView(preset: .fireworks)` |
| **Sparkle** | ✨ Twinkling stars | `ParticleView(preset: .sparkle)` |

### 🔥 Elements
| Preset | Preview | Usage |
|--------|---------|-------|
| **Fire** | 🔥 Realistic flames | `ParticleView(preset: .fire)` |
| **Smoke** | 💨 Rising smoke | `ParticleView(preset: .smoke)` |
| **Rain** | 🌧️ Rain drops | `ParticleView(preset: .rain)` |
| **Snow** | ❄️ Gentle snowfall | `ParticleView(preset: .snow)` |

### 🪄 Magic
| Preset | Preview | Usage |
|--------|---------|-------|
| **Fairy Dust** | 🧚 Magical trail | `MagicPreset.fairyDust()` |
| **Spell Cast** | ⚡ Magic burst | `MagicPreset.spellCast()` |
| **Healing Aura** | 💚 Green glow | `MagicPreset.healing()` |
| **Lightning** | ⚡ Electric sparks | `MagicPreset.lightning()` |

### 🌿 Nature
| Preset | Preview | Usage |
|--------|---------|-------|
| **Autumn Leaves** | 🍂 Falling leaves | `NaturePreset.autumnLeaves()` |
| **Cherry Blossoms** | 🌸 Pink petals | `NaturePreset.cherryBlossoms()` |
| **Bubbles** | 🫧 Underwater bubbles | `NaturePreset.bubbles()` |
| **Fireflies** | ✨ Glowing insects | `NaturePreset.fireflies()` |

### 🌌 Space
| Preset | Preview | Usage |
|--------|---------|-------|
| **Starfield** | ⭐ Twinkling stars | `SpacePreset.starfield()` |
| **Meteor Shower** | ☄️ Shooting stars | `SpacePreset.meteorShower()` |
| **Warp Speed** | 🚀 Hyperspace | `SpacePreset.warpSpeed()` |
| **Nebula** | 🌌 Cosmic clouds | `SpacePreset.nebula()` |

### 🌦️ Weather
| Preset | Preview | Usage |
|--------|---------|-------|
| **Storm Rain** | ⛈️ Heavy rain | `WeatherPreset.stormRain()` |
| **Blizzard** | 🌨️ Snow storm | `WeatherPreset.blizzard()` |
| **Fog** | 🌫️ Mist effect | `WeatherPreset.fog()` |
| **Dust Storm** | 🏜️ Desert wind | `WeatherPreset.dustStorm()` |

### 🎮 Game Effects
| Preset | Preview | Usage |
|--------|---------|-------|
| **Explosion** | 💥 Fiery burst | `GameEffectsPreset.explosion()` |
| **Power Up** | ⬆️ Collection glow | `GameEffectsPreset.powerUp()` |
| **Damage Hit** | ❤️ Red particles | `GameEffectsPreset.damageHit()` |
| **Level Up** | 🎊 Celebration | `GameEffectsPreset.levelUp()` |

---

## 🛠️ Advanced Features

### Metal GPU Rendering

100,000+ particles at 60 FPS:

```swift
let renderer = MetalParticleRenderer(maxParticles: 100_000)
renderer.render(to: metalView, particles: system.particles)
```

### Interactive Particles

Touch to attract, repel, or create turbulence:

```swift
InteractiveParticleView(preset: MagicPreset.configuration)
    .interactionMode(.attract)     // or .repel, .turbulence, .trail
    .interactionRadius(120)
    .interactionStrength(500)
    .burstOnTap(true)
    .burstCount(50)
```

### Particle Trails

Beautiful motion trails:

```swift
var config = ParticleConfiguration()
config.trailEnabled = true
config.trailLength = 15
config.trailFadeRate = 0.2
```

### 3D Particles

Full 3D particle systems:

```swift
let system = Particle3DSystem(configuration: .init())
system.configuration.emissionShape = .sphere(radius: 100)
system.configuration.gravity = Vector3D(x: 0, y: -98, z: 0)
```

### VisionOS Integration

Native spatial particles:

```swift
#if os(visionOS)
VisionParticleView(configuration: VisionParticlePresets.magic3D)
    .enableHandTracking()
    .spatialAudio(true)
#endif
```

### Real-time Editor

Build effects visually:

```swift
ParticleEditorView()
    .onExport { configuration in
        saveConfiguration(configuration)
    }
```

### Performance Profiler

Monitor and optimize:

```swift
let profiler = PerformanceProfiler()
profiler.attach(to: particleSystem)

// Show debug overlay
PerformanceOverlayView(profiler: profiler)
```

---

## 📐 Custom Particle Configuration

```swift
var config = ParticleConfiguration()

// Emission
config.emissionRate = 100
config.maxParticles = 500
config.emissionShape = .circle(radius: 50)

// Lifetime
config.lifetimeRange = 1.0...3.0

// Velocity
config.speedRange = 50...200
config.emissionAngle = -.pi / 2  // Upward
config.spreadAngle = .pi / 4

// Visual
config.sizeRange = 5...15
config.colorPalette = [.red, .orange, .yellow]
config.blendMode = .additive

// Physics
config.gravity = Vector2D(x: 0, y: 98)
config.turbulence = 30
config.drag = 0.02

// Size over lifetime
config.sizeOverLifetime = [
    0.0: 0.5,
    0.3: 1.0,
    1.0: 0.0
]

// Color over lifetime
config.colorOverLifetime = [
    0.0: ParticleColor(red: 1, green: 1, blue: 0.8),
    0.5: ParticleColor(red: 1, green: 0.5, blue: 0.1),
    1.0: ParticleColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0)
]

ParticleView(configuration: config)
```

---

## 🧩 Architecture

```
SwiftParticles/
├── Core/
│   ├── ParticleSystem          # Main coordinator
│   ├── ParticleEmitter         # Particle spawning
│   ├── ParticleConfiguration   # All settings
│   └── Particle                # Individual particle
├── Presets/
│   ├── ConfettiPreset
│   ├── FirePreset
│   ├── FireworksPreset
│   ├── MagicPreset
│   ├── NaturePreset
│   ├── SpacePreset
│   ├── WeatherPreset
│   └── GameEffectsPreset
├── Metal/
│   ├── MetalParticleRenderer   # GPU rendering
│   └── ParticleShaders.metal   # Compute shaders
├── Interactive/
│   └── InteractiveParticleView # Touch interaction
├── 3D/
│   └── Particle3D              # 3D support
├── VisionOS/
│   └── VisionParticleView      # visionOS native
├── Editor/
│   └── ParticleEditorView      # Visual editor
├── Trails/
│   └── ParticleTrail           # Motion trails
└── Performance/
    └── PerformanceProfiler     # Optimization
```

---

## 📊 Performance

| Configuration | Particles | FPS | Device |
|--------------|-----------|-----|--------|
| Default (Canvas) | 1,000 | 60 | iPhone 12 |
| Default (Canvas) | 5,000 | 60 | iPhone 14 Pro |
| Metal GPU | 50,000 | 60 | iPhone 14 Pro |
| Metal GPU | 100,000 | 45 | iPhone 14 Pro |
| Metal GPU | 100,000 | 60 | M1 Mac |

---

## 📱 Platform Support

| Platform | Minimum Version |
|----------|----------------|
| iOS | 16.0+ |
| macOS | 13.0+ |
| tvOS | 16.0+ |
| watchOS | 9.0+ |
| visionOS | 1.0+ |

---

## 🎓 Examples

### Confetti on Button Tap

```swift
struct CelebrationView: View {
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Button("Celebrate! 🎉") {
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                }
            }
            .buttonStyle(.borderedProminent)
            
            if showConfetti {
                ParticleView(preset: .confetti)
                    .allowsHitTesting(false)
            }
        }
    }
}
```

### Game Explosion Effect

```swift
func triggerExplosion(at position: CGPoint) {
    var config = GameEffectsPreset.explosion()
    config.emissionShape = .point
    
    let system = ParticleSystem()
    system.burst(at: position, count: 80)
}
```

### Weather Background

```swift
struct WeatherBackground: View {
    let condition: WeatherCondition
    
    var body: some View {
        Group {
            switch condition {
            case .rain:
                ParticleView(configuration: WeatherPreset.stormRain())
            case .snow:
                ParticleView(configuration: WeatherPreset.gentleSnow())
            case .fog:
                ParticleView(configuration: WeatherPreset.fog())
            }
        }
        .ignoresSafeArea()
    }
}
```

---

## 📄 License

MIT License - Use freely in personal and commercial projects.

---

## 🤝 Contributing

Contributions welcome! Please read our [Contributing Guide](CONTRIBUTING.md).

---

## ⭐ Star History

If you find this useful, please star the repo! It helps others discover it.

---

<p align="center">
  Made with ❤️ for the Swift community
</p>
