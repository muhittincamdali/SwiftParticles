// FireworksPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - FireworksPreset

/// Spectacular fireworks explosion effects.
///
/// Creates multi-stage fireworks with launching rockets and colorful
/// explosions. Perfect for celebrations and special events.
///
/// ## Usage Examples
/// ```swift
/// // Standard fireworks
/// ParticleView(preset: .fireworks)
///
/// // Golden celebration
/// let golden = FireworksPreset.golden()
///
/// // Multi-color finale
/// let finale = FireworksPreset.finale()
/// ```
public enum FireworksPreset {
    
    // MARK: - Default Configuration
    
    /// Default fireworks configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings - bursts only
        config.emissionRate = 0
        config.maxParticles = 500
        config.burstCount = 80
        config.burstInterval = 0.8
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 1.2...2.5
        
        // Emission shape - point explosion
        config.emissionShape = .point
        config.emissionAngle = 0
        config.spreadAngle = .pi * 2  // Full circle
        
        // Velocity - explosive outward
        config.speedRange = 150...300
        config.velocityRandomness = 0.3
        
        // Visual properties
        config.sizeRange = 3...8
        config.sizeOverLifetime = [0: 1.0, 0.5: 0.8, 1.0: 0.0]
        config.opacityRange = 1.0...1.0
        config.opacityOverLifetime = [0: 1.0, 0.7: 0.9, 1.0: 0.0]
        config.shape = .circle
        
        // Colors - vibrant firework colors
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.2, blue: 0.2),   // Red
            ParticleColor(red: 0.2, green: 1.0, blue: 0.2),   // Green
            ParticleColor(red: 0.2, green: 0.2, blue: 1.0),   // Blue
            ParticleColor(red: 1.0, green: 1.0, blue: 0.2),   // Yellow
            ParticleColor(red: 1.0, green: 0.5, blue: 0.0),   // Orange
            ParticleColor(red: 1.0, green: 0.0, blue: 1.0),   // Magenta
            ParticleColor(red: 0.0, green: 1.0, blue: 1.0),   // Cyan
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0)    // White
        ]
        
        // No rotation
        config.rotationRange = 0...0
        config.angularVelocityRange = 0...0
        
        // Physics
        config.gravity = Vector2D(x: 0, y: 100)
        config.drag = 0.03
        config.turbulence = 10
        
        // Rendering - additive for glow
        config.blendMode = .additive
        
        // Trail effect
        config.trailEnabled = true
        config.trailLength = 8
        config.trailFadeRate = 0.3
        
        return config
    }
    
    // MARK: - Variants
    
    /// Creates golden fireworks.
    public static func golden() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.9, blue: 0.5),
            ParticleColor(red: 1.0, green: 0.8, blue: 0.3),
            ParticleColor(red: 1.0, green: 0.7, blue: 0.2),
            ParticleColor(red: 0.9, green: 0.6, blue: 0.1)
        ]
        return config
    }
    
    /// Creates silver sparkler fireworks.
    public static func silver() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0),
            ParticleColor(red: 0.9, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.8, blue: 0.9),
            ParticleColor(red: 0.7, green: 0.7, blue: 0.8)
        ]
        config.burstCount = 120
        return config
    }
    
    /// Creates patriotic red/white/blue fireworks.
    public static func patriotic() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.2, blue: 0.2),
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0),
            ParticleColor(red: 0.2, green: 0.2, blue: 1.0)
        ]
        return config
    }
    
    /// Creates grand finale with multiple explosions.
    public static func finale() -> ParticleConfiguration {
        var config = configuration
        config.burstCount = 150
        config.burstInterval = 0.3
        config.maxParticles = 1000
        config.speedRange = 200...400
        return config
    }
    
    /// Creates heart-shaped firework.
    public static func heart() -> ParticleConfiguration {
        var config = configuration
        config.emissionShape = .circle(radius: 30)
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.2, blue: 0.4),
            ParticleColor(red: 1.0, green: 0.4, blue: 0.5),
            ParticleColor(red: 1.0, green: 0.6, blue: 0.7)
        ]
        config.burstCount = 60
        return config
    }
    
    /// Creates star-shaped firework.
    public static func star() -> ParticleConfiguration {
        var config = configuration
        config.emissionShape = .ring(radius: 40)
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 0.5),
            ParticleColor(red: 1.0, green: 0.9, blue: 0.3)
        ]
        config.burstCount = 50
        return config
    }
    
    /// Creates willow/waterfall firework.
    public static func willow() -> ParticleConfiguration {
        var config = configuration
        config.gravity = Vector2D(x: 0, y: 200)
        config.drag = 0.08
        config.lifetimeRange = 2.0...4.0
        config.trailLength = 15
        config.speedRange = 100...200
        return config
    }
    
    /// Creates crackling palm firework.
    public static func palm() -> ParticleConfiguration {
        var config = configuration
        config.burstCount = 40
        config.speedRange = 80...200
        config.gravity = Vector2D(x: 0, y: 120)
        config.trailEnabled = true
        config.trailLength = 20
        return config
    }
    
}
