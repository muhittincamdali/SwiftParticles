// ParticlePreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ParticlePreset

/// Predefined particle effect presets for common use cases.
///
/// `ParticlePreset` provides ready-to-use configurations for popular
/// particle effects. Each preset is optimized for visual quality and
/// performance.
///
/// ## Usage Example
/// ```swift
/// // Using a preset directly
/// let system = ParticleSystem.withPreset(.confetti)
///
/// // Getting configuration from preset
/// let config = ParticlePreset.snow.configuration
/// ```
public enum ParticlePreset: String, CaseIterable, Sendable {
    /// Colorful celebration confetti.
    case confetti
    /// Gentle falling snowflakes.
    case snow
    /// Flickering fire flames.
    case fire
    /// Billowing smoke clouds.
    case smoke
    /// Twinkling sparkles.
    case sparkle
    /// Falling rain drops.
    case rain
    /// Floating bubbles.
    case bubbles
    /// Magical fairy dust.
    case fairyDust
    /// Electric sparks.
    case sparks
    /// Explosion burst.
    case explosion
    /// Falling autumn leaves.
    case leaves
    /// Heart confetti.
    case hearts
    /// Star field.
    case stars
    
    /// Gets the configuration for this preset.
    public var configuration: ParticleConfiguration {
        switch self {
        case .confetti:
            return ConfettiPreset.configuration
        case .snow:
            return SnowPreset.configuration
        case .fire:
            return FirePreset.configuration
        case .smoke:
            return SmokePreset.configuration
        case .sparkle:
            return SparklePreset.configuration
        case .rain:
            return RainPreset.configuration
        case .bubbles:
            return BubblesPreset.configuration
        case .fairyDust:
            return FairyDustPreset.configuration
        case .sparks:
            return SparksPreset.configuration
        case .explosion:
            return ExplosionPreset.configuration
        case .leaves:
            return LeavesPreset.configuration
        case .hearts:
            return HeartsPreset.configuration
        case .stars:
            return StarsPreset.configuration
        }
    }
    
    /// Display name for the preset.
    public var displayName: String {
        switch self {
        case .confetti: return "Confetti"
        case .snow: return "Snow"
        case .fire: return "Fire"
        case .smoke: return "Smoke"
        case .sparkle: return "Sparkle"
        case .rain: return "Rain"
        case .bubbles: return "Bubbles"
        case .fairyDust: return "Fairy Dust"
        case .sparks: return "Sparks"
        case .explosion: return "Explosion"
        case .leaves: return "Leaves"
        case .hearts: return "Hearts"
        case .stars: return "Stars"
        }
    }
    
    /// Description of the preset effect.
    public var description: String {
        switch self {
        case .confetti:
            return "Colorful celebration confetti falling from above"
        case .snow:
            return "Gentle snowflakes drifting down"
        case .fire:
            return "Flickering flames rising upward"
        case .smoke:
            return "Billowing smoke clouds"
        case .sparkle:
            return "Twinkling magical sparkles"
        case .rain:
            return "Falling rain drops"
        case .bubbles:
            return "Floating soap bubbles"
        case .fairyDust:
            return "Magical glowing fairy dust"
        case .sparks:
            return "Electric sparks flying"
        case .explosion:
            return "Explosive burst effect"
        case .leaves:
            return "Autumn leaves falling"
        case .hearts:
            return "Heart-shaped confetti"
        case .stars:
            return "Twinkling star field"
        }
    }
}

// MARK: - Additional Presets

/// Bubbles preset configuration.
public enum BubblesPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 15
        config.maxParticles = 100
        config.lifetimeRange = 3.0...6.0
        config.speedRange = 20...40
        config.emissionAngle = -.pi / 2  // Upward
        config.spreadAngle = .pi / 4
        config.sizeRange = 15...40
        config.opacityRange = 0.4...0.7
        config.shape = .ring
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.5),
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.6)
        ]
        config.gravity = Vector2D(x: 0, y: -20)
        config.drag = 0.1
        config.blendMode = .normal
        return config
    }
}

/// Fairy dust preset configuration.
public enum FairyDustPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 80
        config.maxParticles = 500
        config.lifetimeRange = 1.0...2.5
        config.speedRange = 30...80
        config.emissionAngle = 0
        config.spreadAngle = .pi
        config.sizeRange = 2...6
        config.opacityRange = 0.6...1.0
        config.shape = .circle
        config.colorPalette = [.gold, .yellow, .white, .pink]
        config.gravity = Vector2D(x: 0, y: 20)
        config.turbulence = 30
        config.blendMode = .additive
        return config
    }
}

/// Sparks preset configuration.
public enum SparksPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 100
        config.maxParticles = 300
        config.lifetimeRange = 0.3...1.0
        config.speedRange = 100...300
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 3
        config.sizeRange = 2...4
        config.opacityRange = 0.8...1.0
        config.shape = .spark
        config.colorPalette = [.orange, .yellow, .white]
        config.gravity = Vector2D(x: 0, y: 200)
        config.drag = 0.05
        config.blendMode = .additive
        return config
    }
}

/// Explosion preset configuration.
public enum ExplosionPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 0
        config.burstCount = 200
        config.maxParticles = 500
        config.lifetimeRange = 0.5...2.0
        config.speedRange = 150...400
        config.emissionAngle = 0
        config.spreadAngle = .pi
        config.emissionShape = .point
        config.sizeRange = 4...12
        config.opacityRange = 0.8...1.0
        config.shape = .circle
        config.colorPalette = [.orange, .yellow, .red, .white]
        config.gravity = Vector2D(x: 0, y: 150)
        config.drag = 0.03
        config.blendMode = .additive
        return config
    }
}

/// Leaves preset configuration.
public enum LeavesPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 10
        config.maxParticles = 100
        config.lifetimeRange = 4.0...8.0
        config.speedRange = 20...50
        config.emissionAngle = .pi / 2  // Downward
        config.spreadAngle = .pi / 4
        config.sizeRange = 12...25
        config.opacityRange = 0.8...1.0
        config.shape = .leaf
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.5, blue: 0.1),
            ParticleColor(red: 0.8, green: 0.3, blue: 0.1),
            ParticleColor(red: 0.7, green: 0.6, blue: 0.1),
            .red
        ]
        config.gravity = Vector2D(x: 0, y: 30)
        config.turbulence = 40
        config.angularVelocityRange = -3...3
        config.blendMode = .normal
        return config
    }
}

/// Hearts preset configuration.
public enum HeartsPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 25
        config.maxParticles = 150
        config.lifetimeRange = 2.0...4.0
        config.speedRange = 80...150
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 3
        config.sizeRange = 15...30
        config.opacityRange = 0.7...1.0
        config.shape = .heart
        config.colorPalette = [.red, .pink, ParticleColor(red: 1, green: 0.3, blue: 0.5)]
        config.gravity = Vector2D(x: 0, y: 80)
        config.angularVelocityRange = -2...2
        config.blendMode = .normal
        return config
    }
}

/// Stars preset configuration.
public enum StarsPreset {
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 5
        config.maxParticles = 200
        config.lifetimeRange = 2.0...5.0
        config.speedRange = 0...10
        config.emissionShape = .rectangle
        config.sizeRange = 2...6
        config.opacityRange = 0.3...1.0
        config.shape = .star
        config.colorPalette = [.white, .yellow, .cyan]
        config.gravity = .zero
        config.blendMode = .additive
        return config
    }
}
