// SnowPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - SnowPreset

/// Gentle snowfall effect preset.
///
/// Creates a peaceful snowfall with varying snowflake sizes drifting
/// down. Includes gentle turbulence for natural movement.
///
/// ## Customization Options
/// ```swift
/// // Light snow
/// let light = SnowPreset.light()
///
/// // Heavy blizzard
/// let blizzard = SnowPreset.blizzard()
///
/// // Night snow with glow
/// let night = SnowPreset.night()
/// ```
public enum SnowPreset {
    
    /// Default snow configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 30
        config.maxParticles = 400
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 5.0...10.0
        
        // Emission shape - top of screen
        config.emissionShape = .line(length: 450)
        config.emissionAngle = .pi / 2  // Downward
        config.spreadAngle = .pi / 8
        
        // Velocity
        config.speedRange = 20...60
        config.velocityRandomness = 0.3
        
        // Visual properties
        config.sizeRange = 3...12
        config.opacityRange = 0.6...0.95
        config.shape = .circle
        
        // Colors - white with slight blue tint
        config.colorPalette = [
            .white,
            ParticleColor(red: 0.95, green: 0.97, blue: 1.0),
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0)
        ]
        
        // Rotation
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -1...1
        
        // Physics
        config.gravity = Vector2D(x: 0, y: 30)
        config.wind = Vector2D(x: 10, y: 0)
        config.drag = 0.05
        config.turbulence = 25
        config.turbulenceFrequency = 0.3
        
        // Rendering
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates light snowfall.
    public static func light() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 10
        config.maxParticles = 150
        config.sizeRange = 2...6
        config.speedRange = 15...35
        config.gravity = Vector2D(x: 0, y: 20)
        return config
    }
    
    /// Creates heavy blizzard effect.
    public static func blizzard() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 100
        config.maxParticles = 800
        config.sizeRange = 2...15
        config.speedRange = 60...150
        config.gravity = Vector2D(x: 0, y: 80)
        config.wind = Vector2D(x: 80, y: 0)
        config.turbulence = 60
        config.opacityRange = 0.4...0.8
        return config
    }
    
    /// Creates night snow with glow effect.
    public static func night() -> ParticleConfiguration {
        var config = configuration
        config.blendMode = .additive
        config.colorPalette = [
            .white,
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.7, green: 0.85, blue: 1.0)
        ]
        config.opacityRange = 0.5...0.9
        return config
    }
    
    /// Creates magical sparkling snow.
    public static func magical() -> ParticleConfiguration {
        var config = configuration
        config.shape = .snowflake
        config.blendMode = .additive
        config.emissionRate = 20
        config.sizeRange = 8...20
        config.opacityRange = 0.5...1.0
        config.colorPalette = [
            .white,
            .cyan,
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0)
        ]
        config.angularVelocityRange = -2...2
        return config
    }
    
    /// Creates frost/ice particles.
    public static func frost() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 15
        config.sizeRange = 4...10
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.95, blue: 1.0),
            .cyan
        ]
        config.blendMode = .additive
        config.opacityRange = 0.4...0.7
        return config
    }
    
    /// Creates large fluffy snowflakes.
    public static func fluffy() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 8
        config.maxParticles = 100
        config.sizeRange = 15...35
        config.speedRange = 10...30
        config.gravity = Vector2D(x: 0, y: 15)
        config.turbulence = 40
        config.angularVelocityRange = -0.5...0.5
        config.shape = .snowflake
        return config
    }
}
