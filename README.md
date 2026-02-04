<p align="center">
  <img src="Assets/logo.png" alt="SwiftParticles" width="200"/>
</p>

<h1 align="center">SwiftParticles</h1>

<p align="center">
  <strong>✨ GPU-accelerated particle system for SwiftUI with Metal shaders</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/SwiftParticles/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/SwiftParticles/actions/workflows/ci.yml/badge.svg" alt="CI"/>
  </a>
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+"/>
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"/>
</p>

---

## Why SwiftParticles?

Creating beautiful particle effects in iOS is complex - Core Animation has limits, SpriteKit is heavy, and Metal requires shader knowledge. **SwiftParticles** provides stunning GPU-accelerated effects with a SwiftUI-native API.

```swift
// Create confetti in one line
ParticleView(.confetti)

// Or customize everything
ParticleView(.custom) {
    $0.emissionRate = 100
    $0.lifetime = 3.0
    $0.velocity = CGVector(dx: 0, dy: -200)
    $0.color = .gradient([.red, .orange, .yellow])
}
```

## Features

| Feature | Description |
|---------|-------------|
| ⚡ **GPU-Powered** | Metal-accelerated, 60fps |
| 🎨 **20+ Presets** | Confetti, snow, fire, rain, stars |
| 🔧 **Customizable** | Full control over every parameter |
| 📱 **SwiftUI Native** | Declarative, reactive API |
| 🎯 **Gestures** | Touch-reactive particles |
| 📊 **Performance** | 10,000+ particles at 60fps |

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftParticles.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftParticles

struct CelebrationView: View {
    var body: some View {
        ZStack {
            // Your content
            Text("🎉 Congratulations!")
            
            // Confetti overlay
            ParticleView(.confetti)
                .allowsHitTesting(false)
        }
    }
}
```

## Presets

| Preset | Effect |
|--------|--------|
| `.confetti` | Celebration confetti |
| `.snow` | Falling snowflakes |
| `.rain` | Rain drops |
| `.fire` | Flickering flames |
| `.smoke` | Rising smoke |
| `.stars` | Twinkling stars |
| `.sparkle` | Magic sparkles |
| `.bubbles` | Floating bubbles |
| `.firework` | Explosion burst |
| `.hearts` | Floating hearts |

## Customization

```swift
ParticleView(.custom) { config in
    // Emission
    config.emissionRate = 50
    config.emissionShape = .circle(radius: 100)
    
    // Appearance
    config.particleImage = Image("spark")
    config.color = .random([.red, .blue, .green])
    config.size = 10...20
    config.opacity = 0.5...1.0
    
    // Motion
    config.velocity = CGVector(dx: 0, dy: -100)
    config.velocityVariation = 50
    config.acceleration = CGVector(dx: 0, dy: 50)
    
    // Lifetime
    config.lifetime = 2.0
    config.lifetimeVariation = 0.5
    
    // Effects
    config.spin = .random(-180...180)
    config.fadeOut = true
    config.scaleOverLife = [1.0, 0.5, 0.0]
}
```

## Touch Interaction

```swift
ParticleView(.sparkle)
    .touchEmission(true) // Emit at touch points
    .gestureVelocity(true) // Particles follow swipe direction
```

## Performance Tips

```swift
// For many particles
ParticleView(.snow) { config in
    config.renderingMode = .metal // Default, fastest
    config.maxParticles = 1000
}

// For battery saving
ParticleView(.stars) { config in
    config.frameRate = 30
    config.reducedMotion = true
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License
