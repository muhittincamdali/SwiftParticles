// MagicPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - MagicPreset

/// Magical sparkle and enchantment effects.
///
/// Creates mystical particle effects with twinkling stars, magical dust,
/// and enchanted auras. Perfect for fantasy themes and special moments.
///
/// ## Usage Examples
/// ```swift
/// // Fairy dust trail
/// let fairy = MagicPreset.fairyDust()
///
/// // Magical wand trail
/// let wand = MagicPreset.wandTrail()
///
/// // Enchanted aura
/// let aura = MagicPreset.aura()
/// ```
public enum MagicPreset {
    
    // MARK: - Default Configuration
    
    /// Default magic sparkle configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 30
        config.maxParticles = 200
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 1.0...2.5
        
        // Emission shape
        config.emissionShape = .circle(radius: 50)
        config.emissionAngle = 0
        config.spreadAngle = .pi * 2
        
        // Velocity - slow floating
        config.speedRange = 20...60
        config.velocityRandomness = 0.5
        
        // Visual properties
        config.sizeRange = 4...12
        config.sizeOverLifetime = [0: 0.0, 0.2: 1.0, 0.8: 0.8, 1.0: 0.0]
        config.opacityRange = 0.6...1.0
        config.opacityOverLifetime = [0: 0.0, 0.1: 1.0, 0.7: 0.8, 1.0: 0.0]
        config.shape = .star
        
        // Colors - magical palette
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.9, blue: 0.5),   // Gold
            ParticleColor(red: 0.9, green: 0.7, blue: 1.0),   // Lavender
            ParticleColor(red: 0.5, green: 0.9, blue: 1.0),   // Cyan
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0)    // White
        ]
        
        // Rotation
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -2...2
        
        // Physics - gentle floating
        config.gravity = Vector2D(x: 0, y: -20)
        config.drag = 0.02
        config.turbulence = 30
        config.turbulenceFrequency = 0.5
        
        // Rendering
        config.blendMode = .additive
        
        return config
    }
    
    // MARK: - Variants
    
    /// Creates fairy dust effect.
    public static func fairyDust() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 50
        config.sizeRange = 2...6
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.8, blue: 0.9),
            ParticleColor(red: 0.9, green: 0.9, blue: 1.0),
            ParticleColor(red: 1.0, green: 1.0, blue: 0.8),
            ParticleColor(red: 0.8, green: 1.0, blue: 0.9)
        ]
        config.shape = .circle
        config.trailEnabled = true
        config.trailLength = 5
        return config
    }
    
    /// Creates magical wand trail effect.
    public static func wandTrail() -> ParticleConfiguration {
        var config = configuration
        config.emissionShape = .point
        config.emissionRate = 80
        config.sizeRange = 3...10
        config.speedRange = 10...40
        config.gravity = Vector2D(x: 0, y: 30)
        config.trailEnabled = true
        config.trailLength = 8
        config.trailFadeRate = 0.4
        return config
    }
    
    /// Creates enchanted aura effect.
    public static func aura() -> ParticleConfiguration {
        var config = configuration
        config.emissionShape = .circle(radius: 80)
        config.emissionRate = 40
        config.speedRange = 5...20
        config.lifetimeRange = 2.0...4.0
        config.sizeRange = 6...15
        config.colorPalette = [
            ParticleColor(red: 0.6, green: 0.4, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.5, blue: 1.0),
            ParticleColor(red: 0.4, green: 0.6, blue: 1.0)
        ]
        return config
    }
    
    /// Creates twinkling stars effect.
    public static func twinkle() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 15
        config.sizeRange = 8...20
        config.shape = .star
        config.sizeOverLifetime = [
            0: 0.0,
            0.1: 1.0,
            0.2: 0.6,
            0.3: 1.0,
            0.5: 0.5,
            0.7: 1.0,
            0.9: 0.4,
            1.0: 0.0
        ]
        config.colorPalette = [
            .white,
            ParticleColor(red: 1.0, green: 1.0, blue: 0.9)
        ]
        return config
    }
    
    /// Creates spell casting effect.
    public static func spellCast() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 0
        config.burstCount = 100
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        config.speedRange = 100...250
        config.lifetimeRange = 0.8...1.5
        config.colorPalette = [
            ParticleColor(red: 0.3, green: 0.8, blue: 1.0),
            ParticleColor(red: 0.5, green: 0.5, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.4, blue: 1.0)
        ]
        return config
    }
    
    /// Creates healing aura effect.
    public static func healing() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 0.3, green: 1.0, blue: 0.5),
            ParticleColor(red: 0.5, green: 1.0, blue: 0.7),
            ParticleColor(red: 0.8, green: 1.0, blue: 0.8),
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0)
        ]
        config.gravity = Vector2D(x: 0, y: -40)
        config.sizeRange = 5...15
        return config
    }
    
    /// Creates dark/shadow magic effect.
    public static func shadow() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 0.4, green: 0.1, blue: 0.6),
            ParticleColor(red: 0.3, green: 0.0, blue: 0.5),
            ParticleColor(red: 0.2, green: 0.0, blue: 0.3),
            ParticleColor(red: 0.1, green: 0.0, blue: 0.2)
        ]
        config.blendMode = .normal
        config.gravity = Vector2D(x: 0, y: 20)
        return config
    }
    
    /// Creates ice magic effect.
    public static func ice() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.95, blue: 1.0),
            ParticleColor(red: 0.6, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.4, green: 0.85, blue: 1.0),
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0)
        ]
        config.shape = .snowflake
        config.angularVelocityRange = -1...1
        return config
    }
    
    /// Creates lightning/electric effect.
    public static func lightning() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 100
        config.lifetimeRange = 0.1...0.3
        config.sizeRange = 2...8
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.6, green: 0.8, blue: 1.0),
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0)
        ]
        config.opacityOverLifetime = [0: 1.0, 0.5: 0.0, 0.6: 1.0, 1.0: 0.0]
        return config
    }
    
}
