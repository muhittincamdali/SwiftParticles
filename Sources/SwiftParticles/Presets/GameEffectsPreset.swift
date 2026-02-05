// GameEffectsPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - GameEffectsPreset

/// Game-specific particle effects.
///
/// Creates common game effects including explosions, impacts, trails,
/// power-ups, damage indicators, and collectible effects.
///
/// ## Usage Examples
/// ```swift
/// // Explosion on hit
/// let explosion = GameEffectsPreset.explosion()
///
/// // Coin collect sparkle
/// let collect = GameEffectsPreset.collectItem()
///
/// // Power-up aura
/// let powerUp = GameEffectsPreset.powerUp()
/// ```
public enum GameEffectsPreset {
    
    // MARK: - Explosions
    
    /// Creates standard explosion effect.
    public static func explosion() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 80
        config.maxParticles = 150
        config.lifetimeRange = 0.3...0.8
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 150...400
        config.velocityRandomness = 0.4
        
        config.sizeRange = 8...25
        config.sizeOverLifetime = [0: 1.0, 0.3: 1.2, 1.0: 0.0]
        config.opacityOverLifetime = [0: 1.0, 0.7: 0.8, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 0.8),
            ParticleColor(red: 1.0, green: 0.8, blue: 0.3),
            ParticleColor(red: 1.0, green: 0.5, blue: 0.1),
            ParticleColor(red: 0.8, green: 0.2, blue: 0.1)
        ]
        config.colorOverLifetime = [
            0.0: ParticleColor(red: 1.0, green: 1.0, blue: 0.9),
            0.2: ParticleColor(red: 1.0, green: 0.7, blue: 0.3),
            0.5: ParticleColor(red: 1.0, green: 0.4, blue: 0.1),
            1.0: ParticleColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0)
        ]
        
        config.drag = 0.05
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates large fiery explosion.
    public static func bigExplosion() -> ParticleConfiguration {
        var config = explosion()
        config.burstCount = 150
        config.maxParticles = 300
        config.sizeRange = 15...50
        config.speedRange = 200...500
        config.lifetimeRange = 0.5...1.2
        return config
    }
    
    /// Creates small spark explosion.
    public static func sparkExplosion() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 40
        config.maxParticles = 60
        config.lifetimeRange = 0.2...0.5
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 100...250
        config.sizeRange = 2...6
        config.shape = .circle
        
        config.colorPalette = [
            .white,
            ParticleColor(red: 1.0, green: 0.9, blue: 0.5)
        ]
        
        config.drag = 0.08
        config.gravity = Vector2D(x: 0, y: 200)
        
        config.blendMode = .additive
        config.trailEnabled = true
        config.trailLength = 5
        
        return config
    }
    
    // MARK: - Impacts
    
    /// Creates bullet/projectile impact.
    public static func bulletImpact() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 20
        config.maxParticles = 30
        config.lifetimeRange = 0.1...0.3
        
        config.emissionShape = .point
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 2
        
        config.speedRange = 100...200
        config.sizeRange = 2...5
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.85, blue: 0.6),
            ParticleColor(red: 0.8, green: 0.7, blue: 0.5)
        ]
        
        config.gravity = Vector2D(x: 0, y: 400)
        
        return config
    }
    
    /// Creates energy/laser impact.
    public static func energyImpact() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 30
        config.maxParticles = 50
        config.lifetimeRange = 0.2...0.4
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 80...180
        config.sizeRange = 3...10
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.3, green: 0.8, blue: 1.0),
            ParticleColor(red: 0.5, green: 0.9, blue: 1.0),
            .white
        ]
        
        config.blendMode = .additive
        
        return config
    }
    
    // MARK: - Trails
    
    /// Creates motion trail effect.
    public static func motionTrail() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 60
        config.maxParticles = 80
        config.lifetimeRange = 0.3...0.6
        
        config.emissionShape = .point
        config.spreadAngle = .pi / 8
        
        config.speedRange = 5...20
        
        config.sizeRange = 5...12
        config.sizeOverLifetime = [0: 1.0, 1.0: 0.3]
        config.opacityOverLifetime = [0: 0.8, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [.white]
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates speed boost trail.
    public static func speedTrail() -> ParticleConfiguration {
        var config = motionTrail()
        config.emissionRate = 100
        config.stretchFactor = 3.0
        config.colorPalette = [
            ParticleColor(red: 0.5, green: 0.8, blue: 1.0),
            ParticleColor(red: 0.3, green: 0.6, blue: 1.0)
        ]
        return config
    }
    
    // MARK: - Power-ups & Collectibles
    
    /// Creates power-up aura effect.
    public static func powerUp() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 30
        config.maxParticles = 100
        config.lifetimeRange = 0.8...1.5
        
        config.emissionShape = .circle(radius: 30)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 20...50
        
        config.sizeRange = 4...10
        config.opacityOverLifetime = [0: 0.0, 0.2: 0.8, 0.8: 0.6, 1.0: 0.0]
        config.shape = .star
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.9, blue: 0.3),
            ParticleColor(red: 1.0, green: 0.8, blue: 0.2)
        ]
        
        config.gravity = Vector2D(x: 0, y: -30)
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates item collection sparkle.
    public static func collectItem() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 30
        config.maxParticles = 40
        config.lifetimeRange = 0.4...0.8
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 60...150
        
        config.sizeRange = 3...8
        config.sizeOverLifetime = [0: 0.5, 0.3: 1.0, 1.0: 0.0]
        config.shape = .star
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.85, blue: 0.3),
            ParticleColor(red: 1.0, green: 0.95, blue: 0.6),
            .white
        ]
        
        config.gravity = Vector2D(x: 0, y: -50)
        config.drag = 0.1
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates coin collect effect.
    public static func coinCollect() -> ParticleConfiguration {
        var config = collectItem()
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.85, blue: 0.2),
            ParticleColor(red: 0.9, green: 0.75, blue: 0.1)
        ]
        return config
    }
    
    /// Creates health pickup effect.
    public static func healthPickup() -> ParticleConfiguration {
        var config = collectItem()
        config.colorPalette = [
            ParticleColor(red: 0.2, green: 1.0, blue: 0.4),
            ParticleColor(red: 0.4, green: 1.0, blue: 0.6)
        ]
        config.shape = .star
        return config
    }
    
    // MARK: - Damage & Status
    
    /// Creates damage hit indicator.
    public static func damageHit() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 15
        config.maxParticles = 20
        config.lifetimeRange = 0.3...0.6
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 50...120
        
        config.sizeRange = 3...8
        config.opacityOverLifetime = [0: 1.0, 0.6: 0.8, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.2, blue: 0.2),
            ParticleColor(red: 0.9, green: 0.1, blue: 0.1)
        ]
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates poison/DOT effect.
    public static func poisonEffect() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 20
        config.maxParticles = 60
        config.lifetimeRange = 0.8...1.5
        
        config.emissionShape = .circle(radius: 20)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 10...30
        
        config.sizeRange = 4...10
        config.opacityOverLifetime = [0: 0.0, 0.2: 0.6, 0.8: 0.4, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.4, green: 0.9, blue: 0.2),
            ParticleColor(red: 0.3, green: 0.8, blue: 0.1)
        ]
        
        config.gravity = Vector2D(x: 0, y: -20)
        config.turbulence = 20
        
        return config
    }
    
    /// Creates freeze/ice effect.
    public static func freezeEffect() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 25
        config.maxParticles = 80
        config.lifetimeRange = 1.0...2.0
        
        config.emissionShape = .circle(radius: 25)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 5...20
        
        config.sizeRange = 3...10
        config.shape = .snowflake
        
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.95, blue: 1.0),
            .white
        ]
        
        config.angularVelocityRange = -2...2
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates burn/fire DOT effect.
    public static func burnEffect() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 30
        config.maxParticles = 80
        config.lifetimeRange = 0.4...0.8
        
        config.emissionShape = .circle(radius: 20)
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 3
        
        config.speedRange = 30...80
        
        config.sizeRange = 5...15
        config.sizeOverLifetime = [0: 0.8, 0.5: 1.0, 1.0: 0.0]
        config.shape = .circle
        
        config.colorOverLifetime = [
            0.0: ParticleColor(red: 1.0, green: 1.0, blue: 0.7),
            0.3: ParticleColor(red: 1.0, green: 0.6, blue: 0.2),
            0.6: ParticleColor(red: 0.9, green: 0.3, blue: 0.1),
            1.0: ParticleColor(red: 0.3, green: 0.1, blue: 0.1, alpha: 0)
        ]
        
        config.blendMode = .additive
        
        return config
    }
    
    // MARK: - Level Up & Achievement
    
    /// Creates level up celebration.
    public static func levelUp() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 100
        config.burstInterval = 0.5
        config.maxParticles = 200
        config.lifetimeRange = 1.0...2.0
        
        config.emissionShape = .circle(radius: 50)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 80...200
        
        config.sizeRange = 5...15
        config.shape = .star
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.9, blue: 0.3),
            ParticleColor(red: 1.0, green: 0.8, blue: 0.2),
            ParticleColor(red: 1.0, green: 1.0, blue: 0.6),
            .white
        ]
        
        config.gravity = Vector2D(x: 0, y: -100)
        config.drag = 0.05
        
        config.blendMode = .additive
        
        return config
    }
    
}
