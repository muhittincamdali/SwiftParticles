// RainPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - RainPreset

/// Falling rain drops effect preset.
///
/// Creates realistic rain with fast-falling droplets. Can be configured
/// for light drizzle to heavy downpour.
///
/// ## Customization Options
/// ```swift
/// // Light drizzle
/// let drizzle = RainPreset.drizzle()
///
/// // Heavy storm
/// let storm = RainPreset.storm()
///
/// // Rain with wind
/// let windy = RainPreset.windy(angle: .pi / 6)
/// ```
public enum RainPreset {
    
    /// Default rain configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 100
        config.maxParticles = 500
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 0.8...1.5
        
        // Emission shape - top of screen, full width
        config.emissionShape = .line(length: 450)
        config.emissionAngle = .pi / 2  // Downward
        config.spreadAngle = 0.05  // Very narrow spread
        
        // Velocity - fast falling
        config.speedRange = 400...600
        config.velocityRandomness = 0.1
        
        // Visual properties - elongated drops
        config.sizeRange = 2...4
        config.opacityRange = 0.4...0.7
        config.shape = .line  // Elongated raindrop
        
        // Colors - blue-ish water
        config.colorPalette = [
            ParticleColor(red: 0.6, green: 0.7, blue: 0.9),
            ParticleColor(red: 0.7, green: 0.8, blue: 0.95),
            ParticleColor(red: 0.65, green: 0.75, blue: 0.9)
        ]
        
        // No rotation for rain
        config.rotationRange = 0...0
        config.angularVelocityRange = 0...0
        
        // Physics
        config.gravity = Vector2D(x: 0, y: 200)
        config.wind = .zero
        config.drag = 0.01
        config.turbulence = 0
        
        // Rendering
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates light drizzle effect.
    public static func drizzle() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 30
        config.maxParticles = 200
        config.sizeRange = 1...2
        config.speedRange = 250...350
        config.opacityRange = 0.3...0.5
        config.lifetimeRange = 1.0...2.0
        return config
    }
    
    /// Creates heavy storm rain.
    public static func storm() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 250
        config.maxParticles = 1000
        config.sizeRange = 3...6
        config.speedRange = 500...800
        config.opacityRange = 0.5...0.8
        config.lifetimeRange = 0.5...1.0
        config.wind = Vector2D(x: 50, y: 0)
        config.spreadAngle = 0.1
        return config
    }
    
    /// Creates rain at an angle (windy).
    /// - Parameter angle: Wind angle in radians from vertical.
    public static func windy(angle: Double = .pi / 6) -> ParticleConfiguration {
        var config = configuration
        config.emissionAngle = .pi / 2 + angle
        config.wind = Vector2D(x: sin(angle) * 100, y: 0)
        return config
    }
    
    /// Creates tropical monsoon rain.
    public static func monsoon() -> ParticleConfiguration {
        var config = storm()
        config.emissionRate = 300
        config.sizeRange = 4...8
        config.wind = Vector2D(x: 80, y: 0)
        config.turbulence = 10
        return config
    }
    
    /// Creates gentle spring shower.
    public static func springShower() -> ParticleConfiguration {
        var config = drizzle()
        config.emissionRate = 50
        config.opacityRange = 0.3...0.6
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.8, blue: 0.9),
            ParticleColor(red: 0.75, green: 0.85, blue: 0.95)
        ]
        return config
    }
    
    /// Creates rain with visible drops (cartoon style).
    public static func cartoon() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 40
        config.sizeRange = 6...12
        config.shape = .raindrop
        config.speedRange = 300...450
        config.opacityRange = 0.7...0.9
        config.colorPalette = [
            ParticleColor(red: 0.5, green: 0.7, blue: 1.0),
            ParticleColor(red: 0.6, green: 0.8, blue: 1.0)
        ]
        return config
    }
    
    /// Creates mist/fog rain.
    public static func mist() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 60
        config.maxParticles = 300
        config.lifetimeRange = 2.0...4.0
        config.emissionShape = .rectangle
        config.emissionSize = CGSize(width: 400, height: 600)
        config.speedRange = 10...30
        config.sizeRange = 15...30
        config.opacityRange = 0.1...0.25
        config.shape = .circle
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.85, blue: 0.9, alpha: 0.3),
            ParticleColor(red: 0.85, green: 0.9, blue: 0.95, alpha: 0.2)
        ]
        config.gravity = Vector2D(x: 0, y: 5)
        config.turbulence = 20
        config.blendMode = .normal
        return config
    }
    
    /// Creates sleet (rain/snow mix).
    public static func sleet() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 80
        config.sizeRange = 2...5
        config.speedRange = 200...400
        config.colorPalette = [
            .white,
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0),
            ParticleColor(red: 0.7, green: 0.8, blue: 0.9)
        ]
        config.opacityRange = 0.5...0.8
        config.turbulence = 15
        return config
    }
}
