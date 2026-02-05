// WeatherPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - WeatherPreset

/// Weather and atmospheric particle effects.
///
/// Creates realistic weather phenomena including rain, snow, hail, fog,
/// storm effects, and various precipitation types.
///
/// ## Usage Examples
/// ```swift
/// // Heavy rainstorm
/// let storm = WeatherPreset.stormRain()
///
/// // Blizzard effect
/// let blizzard = WeatherPreset.blizzard()
///
/// // Morning fog
/// let fog = WeatherPreset.fog()
/// ```
public enum WeatherPreset {
    
    // MARK: - Rain Variants
    
    /// Creates light drizzle effect.
    public static func drizzle() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 30
        config.maxParticles = 200
        config.lifetimeRange = 1.0...2.0
        
        config.emissionShape = .line(length: 500)
        config.emissionAngle = .pi / 2 + 0.1
        config.spreadAngle = .pi / 20
        
        config.speedRange = 200...300
        config.sizeRange = 1...3
        config.shape = .spark
        
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 0.4)
        ]
        
        config.gravity = Vector2D(x: 0, y: 500)
        config.wind = Vector2D(x: 20, y: 0)
        
        config.stretchFactor = 3.0
        
        return config
    }
    
    /// Creates heavy storm rain effect.
    public static func stormRain() -> ParticleConfiguration {
        var config = drizzle()
        
        config.emissionRate = 150
        config.maxParticles = 800
        config.lifetimeRange = 0.5...1.0
        
        config.speedRange = 500...800
        config.sizeRange = 2...4
        
        config.emissionAngle = .pi / 2 + 0.2
        config.wind = Vector2D(x: 100, y: 0)
        config.gravity = Vector2D(x: 0, y: 800)
        
        config.stretchFactor = 5.0
        
        return config
    }
    
    /// Creates tropical monsoon rain.
    public static func monsoon() -> ParticleConfiguration {
        var config = stormRain()
        config.emissionRate = 200
        config.maxParticles = 1000
        config.speedRange = 600...1000
        config.wind = Vector2D(x: 150, y: 0)
        return config
    }
    
    // MARK: - Snow Variants
    
    /// Creates gentle snowfall.
    public static func gentleSnow() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 20
        config.maxParticles = 200
        config.lifetimeRange = 5.0...10.0
        
        config.emissionShape = .line(length: 500)
        config.emissionAngle = .pi / 2
        config.spreadAngle = .pi / 4
        
        config.speedRange = 20...60
        config.velocityRandomness = 0.5
        
        config.sizeRange = 4...12
        config.shape = .snowflake
        
        config.colorPalette = [.white]
        
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -1...1
        
        config.gravity = Vector2D(x: 0, y: 30)
        config.wind = Vector2D(x: 15, y: 0)
        config.turbulence = 40
        config.turbulenceFrequency = 0.3
        
        return config
    }
    
    /// Creates heavy blizzard effect.
    public static func blizzard() -> ParticleConfiguration {
        var config = gentleSnow()
        
        config.emissionRate = 100
        config.maxParticles = 600
        config.lifetimeRange = 2.0...5.0
        
        config.speedRange = 100...200
        config.sizeRange = 3...10
        
        config.wind = Vector2D(x: 150, y: 0)
        config.turbulence = 80
        
        config.opacityRange = 0.5...0.9
        
        return config
    }
    
    /// Creates ice crystals/sleet.
    public static func sleet() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 50
        config.maxParticles = 300
        config.lifetimeRange = 1.0...2.5
        
        config.emissionShape = .line(length: 500)
        config.emissionAngle = .pi / 2 + 0.15
        config.spreadAngle = .pi / 10
        
        config.speedRange = 200...400
        config.sizeRange = 2...5
        config.shape = .diamond
        
        config.colorPalette = [
            ParticleColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 0.8),
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.7)
        ]
        
        config.gravity = Vector2D(x: 0, y: 400)
        config.wind = Vector2D(x: 60, y: 0)
        
        return config
    }
    
    /// Creates hail effect.
    public static func hail() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 30
        config.maxParticles = 150
        config.lifetimeRange = 0.8...1.5
        
        config.emissionShape = .line(length: 500)
        config.emissionAngle = .pi / 2
        config.spreadAngle = .pi / 12
        
        config.speedRange = 300...500
        config.sizeRange = 5...15
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.9),
            ParticleColor(red: 0.85, green: 0.9, blue: 0.98, alpha: 0.85)
        ]
        
        config.gravity = Vector2D(x: 0, y: 600)
        config.bounceOnGround = true
        config.bounceFactor = 0.4
        
        return config
    }
    
    // MARK: - Fog & Mist
    
    /// Creates fog/mist effect.
    public static func fog() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 5
        config.maxParticles = 50
        config.lifetimeRange = 8.0...15.0
        
        config.emissionShape = .point
        config.spreadAngle = .pi
        
        config.speedRange = 5...20
        config.velocityRandomness = 0.8
        
        config.sizeRange = 80...200
        config.sizeOverLifetime = [0: 0.5, 0.3: 1.0, 0.7: 1.2, 1.0: 0.8]
        config.opacityRange = 0.1...0.3
        config.opacityOverLifetime = [0: 0.0, 0.2: 0.25, 0.8: 0.25, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 0.2)
        ]
        
        config.wind = Vector2D(x: 10, y: 0)
        config.turbulence = 15
        
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates morning mist effect.
    public static func mist() -> ParticleConfiguration {
        var config = fog()
        config.opacityRange = 0.05...0.15
        config.sizeRange = 100...250
        config.emissionRate = 3
        return config
    }
    
    /// Creates steam/vapor effect.
    public static func steam() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 15
        config.maxParticles = 80
        config.lifetimeRange = 2.0...4.0
        
        config.emissionShape = .line(length: 50)
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 4
        
        config.speedRange = 30...80
        
        config.sizeRange = 20...50
        config.sizeOverLifetime = [0: 0.3, 0.5: 1.0, 1.0: 1.5]
        config.opacityRange = 0.3...0.6
        config.opacityOverLifetime = [0: 0.5, 0.5: 0.4, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        ]
        
        config.gravity = Vector2D(x: 0, y: -30)
        config.turbulence = 30
        
        return config
    }
    
    // MARK: - Storm Effects
    
    /// Creates dust storm effect.
    public static func dustStorm() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 100
        config.maxParticles = 500
        config.lifetimeRange = 2.0...5.0
        
        config.emissionShape = .point
        config.spreadAngle = .pi / 4
        
        config.speedRange = 100...250
        
        config.sizeRange = 2...10
        config.opacityRange = 0.3...0.7
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.65, blue: 0.4, alpha: 0.6),
            ParticleColor(red: 0.7, green: 0.55, blue: 0.35, alpha: 0.5),
            ParticleColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.4)
        ]
        
        config.wind = Vector2D(x: 200, y: 0)
        config.turbulence = 60
        
        return config
    }
    
    /// Creates sandstorm effect.
    public static func sandstorm() -> ParticleConfiguration {
        var config = dustStorm()
        config.emissionRate = 150
        config.speedRange = 150...300
        config.sizeRange = 1...6
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 0.5),
            ParticleColor(red: 0.85, green: 0.7, blue: 0.4, alpha: 0.4)
        ]
        return config
    }
    
}
