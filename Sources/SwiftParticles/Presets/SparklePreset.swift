// SparklePreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - SparklePreset

/// Twinkling sparkle effect preset.
///
/// Creates magical twinkling sparkles that appear and fade. Perfect for
/// highlighting, magic effects, or attention-grabbing animations.
///
/// ## Customization Options
/// ```swift
/// // Gold sparkles
/// let gold = SparklePreset.gold()
///
/// // Diamond sparkles
/// let diamond = SparklePreset.diamond()
///
/// // Magic wand trail
/// let magic = SparklePreset.magicTrail()
/// ```
public enum SparklePreset {
    
    /// Default sparkle configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 40
        config.maxParticles = 200
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime - short for quick twinkle
        config.lifetimeRange = 0.3...1.0
        
        // Emission shape - spread area
        config.emissionShape = .circle(radius: 50)
        config.emissionAngle = 0
        config.spreadAngle = .pi
        
        // Velocity - minimal movement
        config.speedRange = 5...20
        config.velocityRandomness = 0.5
        
        // Visual properties - star shape
        config.sizeRange = 4...12
        config.sizeOverLifetime = [0: 0.0, 0.2: 1.2, 0.5: 1.0, 1.0: 0.0]
        config.opacityRange = 0.7...1.0
        config.opacityOverLifetime = [0: 0.0, 0.1: 1.0, 0.6: 1.0, 1.0: 0.0]
        config.shape = .star
        
        // Colors - white/gold sparkles
        config.colorPalette = [
            .white,
            ParticleColor(red: 1.0, green: 0.95, blue: 0.8),
            ParticleColor(red: 1.0, green: 0.9, blue: 0.6)
        ]
        
        // Rotation
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -3...3
        
        // Physics - minimal
        config.gravity = .zero
        config.drag = 0.1
        config.turbulence = 5
        
        // Rendering - additive for glow
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates gold/treasure sparkles.
    public static func gold() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            .gold,
            ParticleColor(red: 1.0, green: 0.9, blue: 0.5),
            ParticleColor(red: 1.0, green: 0.85, blue: 0.3),
            .white
        ]
        return config
    }
    
    /// Creates diamond/crystal sparkles.
    public static func diamond() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            .white,
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0),
            .cyan
        ]
        config.sizeRange = 3...10
        return config
    }
    
    /// Creates silver sparkles.
    public static func silver() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            .silver,
            .white,
            ParticleColor(red: 0.85, green: 0.85, blue: 0.9)
        ]
        return config
    }
    
    /// Creates magic wand trail sparkles.
    public static func magicTrail() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 60
        config.emissionShape = .point
        config.lifetimeRange = 0.5...1.5
        config.speedRange = 30...80
        config.spreadAngle = .pi / 2
        config.gravity = Vector2D(x: 0, y: 50)
        config.colorPalette = [
            .white,
            .gold,
            .cyan,
            .pink
        ]
        return config
    }
    
    /// Creates rainbow sparkles.
    public static func rainbow() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink
        ]
        config.emissionRate = 50
        return config
    }
    
    /// Creates intense glitter effect.
    public static func glitter() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 100
        config.maxParticles = 400
        config.sizeRange = 2...6
        config.lifetimeRange = 0.2...0.6
        config.shape = .diamond
        config.colorPalette = [
            .white,
            .gold,
            .silver,
            ParticleColor(red: 1.0, green: 0.95, blue: 0.9)
        ]
        return config
    }
    
    /// Creates firefly-like sparkles.
    public static func fireflies() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 15
        config.maxParticles = 50
        config.emissionShape = .rectangle
        config.emissionSize = CGSize(width: 300, height: 200)
        config.sizeRange = 3...8
        config.lifetimeRange = 2.0...5.0
        config.speedRange = 10...30
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 1.0, blue: 0.4),
            ParticleColor(red: 0.9, green: 1.0, blue: 0.5)
        ]
        config.opacityOverLifetime = [
            0: 0, 0.1: 1, 0.3: 0.2, 0.5: 1, 0.7: 0.3, 0.9: 0.8, 1: 0
        ]
        config.turbulence = 30
        return config
    }
    
    /// Creates stardust/cosmic sparkles.
    public static func stardust() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 30
        config.sizeRange = 2...8
        config.colorPalette = [
            .white,
            .cyan,
            ParticleColor(red: 0.8, green: 0.8, blue: 1.0),
            ParticleColor(red: 1.0, green: 0.8, blue: 0.9)
        ]
        config.lifetimeRange = 0.5...2.0
        config.turbulence = 15
        return config
    }
}
