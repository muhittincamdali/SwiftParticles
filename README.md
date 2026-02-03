# SwiftParticles

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%2016+%20|%20macOS%2013+%20|%20tvOS%2016+%20|%20visionOS%201+-blue.svg)](https://developer.apple.com)
[![SPM Compatible](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

A powerful, GPU-accelerated particle system for SwiftUI. Create stunning visual effects like confetti, snow, fire, smoke, and more with minimal code.

## Features

- 🚀 **GPU-Accelerated** - Metal-based rendering for thousands of particles
- 🎨 **13+ Built-in Presets** - Confetti, snow, fire, smoke, rain, sparkles, and more
- 🔧 **Highly Customizable** - Fine-tune every aspect of particle behavior
- 🎯 **SwiftUI Native** - Easy integration with view modifiers
- ⚡ **High Performance** - Object pooling and efficient update loops
- 🎭 **Multiple Emitter Types** - Point, line, circle, rectangle, custom shapes
- 💪 **Physics System** - Gravity, wind, turbulence, attractors, vortices
- 🎬 **Behaviors** - Fade, scale, color transitions, rotation over lifetime

## Installation

### Swift Package Manager

Add SwiftParticles to your project using Xcode:

1. File → Add Packages...
2. Enter: `https://github.com/muhittinc/SwiftParticles.git`
3. Select version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittinc/SwiftParticles.git", from: "1.0.0")
]
```

## Quick Start

### Basic Usage

```swift
import SwiftUI
import SwiftParticles

struct ContentView: View {
    var body: some View {
        ParticleView(preset: .confetti)
    }
}
```

### View Modifier

```swift
struct CelebrationView: View {
    @State private var showConfetti = false
    
    var body: some View {
        Button("Celebrate!") {
            showConfetti = true
        }
        .confetti(isActive: $showConfetti, duration: 3.0)
    }
}
```

### Custom Configuration

```swift
var config = ParticleConfiguration()
config.emissionRate = 100
config.lifetimeRange = 2.0...4.0
config.colorPalette = [.red, .orange, .yellow]
config.gravity = Vector2D(x: 0, y: 150)
config.shape = .star

ParticleView(configuration: config)
```

## Presets

SwiftParticles includes 13+ ready-to-use presets:

| Preset | Description |
|--------|-------------|
| `.confetti` | Colorful celebration confetti |
| `.snow` | Gentle falling snowflakes |
| `.fire` | Flickering flames |
| `.smoke` | Billowing smoke clouds |
| `.rain` | Falling rain drops |
| `.sparkle` | Twinkling sparkles |
| `.bubbles` | Floating soap bubbles |
| `.fairyDust` | Magical glowing particles |
| `.sparks` | Electric sparks |
| `.explosion` | Explosive burst |
| `.leaves` | Falling autumn leaves |
| `.hearts` | Heart-shaped confetti |
| `.stars` | Twinkling star field |

### Preset Variations

Each preset includes variations:

```swift
// Snow variations
SnowPreset.light()      // Light snowfall
SnowPreset.blizzard()   // Heavy blizzard
SnowPreset.magical()    // Sparkling snow

// Fire variations
FirePreset.campfire()   // Campfire flames
FirePreset.blue()       // Blue magical fire
FirePreset.candle()     // Small candle flame
```

## Emitter Types

### Point Emitter
```swift
let emitter = PointEmitter(
    position: Vector2D(x: 200, y: 300),
    emissionAngle: -.pi / 2,  // Upward
    spreadAngle: .pi / 4
)
```

### Line Emitter
```swift
let emitter = LineEmitter(
    startPoint: Vector2D(x: 0, y: 0),
    endPoint: Vector2D(x: 400, y: 0)
)
```

### Circle Emitter
```swift
let emitter = CircleEmitter(
    center: Vector2D(x: 200, y: 200),
    radius: 50
)
.emittingOutward()
```

### Rectangle Emitter
```swift
let emitter = RectangleEmitter(
    rect: CGRect(x: 0, y: 0, width: 400, height: 100)
)
.withEmissionMode(.topEdge)
```

### Custom Shape Emitter
```swift
let star = CustomShapeEmitter.star(
    center: Vector2D(x: 200, y: 200),
    points: 5,
    outerRadius: 100,
    innerRadius: 40
)
```

## Forces

### Gravity
```swift
let gravity = GravityForce(strength: 98)
system.addForce(gravity)
```

### Wind
```swift
let wind = WindForce(direction: Vector2D(x: 1, y: 0), strength: 50)
    .withGusting()
system.addForce(wind)
```

### Turbulence
```swift
let turbulence = TurbulenceForce(strength: 30, frequency: 0.01, octaves: 3)
system.addForce(turbulence)
```

### Attractor
```swift
let attractor = AttractorForce(
    position: Vector2D(x: 200, y: 200),
    strength: 500,
    radius: 200
)
system.addForce(attractor)
```

### Vortex
```swift
let vortex = VortexForce.whirlpool(
    center: Vector2D(x: 200, y: 400),
    strength: 300
)
system.addForce(vortex)
```

## Behaviors

### Fade Out
```swift
let fade = FadeOutBehavior(startOpacity: 1.0, endOpacity: 0.0, easing: .easeOut)
system.addBehavior(fade)
```

### Scale Over Lifetime
```swift
let scale = ScaleBehavior(startScale: 1.0, endScale: 0.0)
    .withPulse(amplitude: 0.2, frequency: 2.0)
system.addBehavior(scale)
```

### Color Gradient
```swift
let color = ColorBehavior.gradient([.yellow, .orange, .red])
system.addBehavior(color)
```

### Rotation
```swift
let rotation = RotationBehavior.alignedToVelocity()
system.addBehavior(rotation)
```

## Advanced Usage

### Custom Particle System

```swift
@StateObject var system = ParticleSystem()

var body: some View {
    ParticleView { system in
        // Add emitter
        let emitter = CircleEmitter(
            center: .zero,
            radius: 30
        )
        system.addEmitter(emitter)
        
        // Add forces
        system.addForce(GravityForce(strength: 50))
        system.addForce(TurbulenceForce.smoke)
        
        // Add behaviors
        system.addBehavior(FadeOutBehavior())
        system.addBehavior(ScaleBehavior.shrink)
        system.addBehavior(ColorBehavior.fire)
    }
}
```

### Interactive Particles

```swift
InteractiveParticleOverlay(preset: .sparkle)
```

### Particle Overlay

```swift
ZStack {
    ContentView()
    
    ParticleOverlay.snow
        .opacity(isSnowing ? 1 : 0)
}
```

## Performance Tips

1. **Limit particle count** - Set `maxParticles` appropriately
2. **Use object pooling** - Enabled by default
3. **Disable unused features** - Trails, shadows when not needed
4. **Use simpler shapes** - Circles render faster than complex shapes
5. **Batch similar particles** - Group by texture/blend mode

## Requirements

- iOS 16.0+
- macOS 13.0+
- tvOS 16.0+
- watchOS 9.0+
- visionOS 1.0+
- Swift 5.9+
- Xcode 15.0+

## Architecture

```
SwiftParticles/
├── Core/
│   ├── ParticleSystem      # Main coordinator
│   ├── ParticleEmitter     # Spawns particles
│   └── ParticleConfiguration
├── Particles/
│   ├── Particle            # Individual particle
│   ├── ParticlePool        # Object pooling
│   └── ParticleState       # State tracking
├── Emitters/
│   ├── PointEmitter
│   ├── LineEmitter
│   ├── CircleEmitter
│   ├── RectangleEmitter
│   └── CustomShapeEmitter
├── Forces/
│   ├── GravityForce
│   ├── WindForce
│   ├── TurbulenceForce
│   ├── AttractorForce
│   └── VortexForce
├── Behaviors/
│   ├── FadeOutBehavior
│   ├── ScaleBehavior
│   ├── ColorBehavior
│   └── RotationBehavior
├── Rendering/
│   ├── ParticleRenderer    # Metal rendering
│   └── RenderConfiguration
├── Presets/
│   └── [13+ effect presets]
└── SwiftUI/
    ├── ParticleView
    ├── ParticleModifier
    └── ParticleOverlay
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

SwiftParticles is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Author

**Muhittin Camdali**
- GitHub: [@muhittinc](https://github.com/muhittinc)

---

Made with ❤️ for the SwiftUI community
