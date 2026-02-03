// FirePreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - FirePreset

/// Flickering fire flames effect preset.
///
/// Creates realistic fire with rising flames that change color from
/// yellow to orange to red as they rise and fade.
///
/// ## Customization Options
/// ```swift
/// // Campfire
/// let campfire = FirePreset.campfire()
///
/// // Blue flames
/// let blue = FirePreset.blue()
///
/// // Candle flame
/// let candle = FirePreset.candle()
/// ```
public enum FirePreset {
    
    /// Default fire configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 60
        config.maxParticles = 300
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 0.5...1.5
        
        // Emission shape - base of fire
        config.emissionShape = .line(length: 60)
        config.emissionAngle = -.pi / 2  // Upward
        config.spreadAngle = .pi / 6
        
        // Velocity
        config.speedRange = 80...150
        config.velocityRandomness = 0.4
        
        // Visual properties
        config.sizeRange = 8...20
        config.sizeOverLifetime = [0: 0.5, 0.3: 1.0, 1.0: 0.0]
        config.opacityRange = 0.8...1.0
        config.opacityOverLifetime = [0: 0.8, 0.5: 1.0, 1.0: 0.0]
        config.shape = .circle
        
        // Colors - fire gradient
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 0.6),   // Light yellow
            ParticleColor(red: 1.0, green: 0.9, blue: 0.2),   // Yellow
            ParticleColor(red: 1.0, green: 0.6, blue: 0.1),   // Orange
            ParticleColor(red: 1.0, green: 0.3, blue: 0.1)    // Red-orange
        ]
        config.colorOverLifetime = [
            0.0: ParticleColor(red: 1.0, green: 1.0, blue: 0.6),
            0.3: ParticleColor(red: 1.0, green: 0.7, blue: 0.2),
            0.6: ParticleColor(red: 1.0, green: 0.4, blue: 0.1),
            1.0: ParticleColor(red: 0.5, green: 0.1, blue: 0.0, alpha: 0)
        ]
        
        // No rotation for fire
        config.rotationRange = 0...0
        config.angularVelocityRange = 0...0
        
        // Physics - rises against gravity
        config.gravity = Vector2D(x: 0, y: -50)
        config.drag = 0.05
        config.turbulence = 40
        config.turbulenceFrequency = 2.0
        
        // Rendering - additive for glow
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates a campfire effect.
    public static func campfire() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 80
        config.emissionShape = .circle(radius: 30)
        config.sizeRange = 10...30
        config.speedRange = 60...120
        return config
    }
    
    /// Creates blue/magical flames.
    public static func blue() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.4, green: 0.7, blue: 1.0),
            ParticleColor(red: 0.2, green: 0.4, blue: 1.0),
            ParticleColor(red: 0.1, green: 0.2, blue: 0.8)
        ]
        config.colorOverLifetime = [
            0.0: ParticleColor(red: 0.8, green: 0.9, blue: 1.0),
            0.3: ParticleColor(red: 0.4, green: 0.7, blue: 1.0),
            0.6: ParticleColor(red: 0.2, green: 0.4, blue: 0.9),
            1.0: ParticleColor(red: 0.1, green: 0.1, blue: 0.5, alpha: 0)
        ]
        return config
    }
    
    /// Creates green/mystical flames.
    public static func green() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 1.0, blue: 0.6),
            ParticleColor(red: 0.4, green: 0.9, blue: 0.3),
            ParticleColor(red: 0.2, green: 0.7, blue: 0.2),
            ParticleColor(red: 0.1, green: 0.4, blue: 0.1)
        ]
        return config
    }
    
    /// Creates a small candle flame.
    public static func candle() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 20
        config.maxParticles = 50
        config.emissionShape = .point
        config.sizeRange = 4...10
        config.speedRange = 30...60
        config.lifetimeRange = 0.3...0.8
        config.turbulence = 15
        return config
    }
    
    /// Creates torch/large flame effect.
    public static func torch() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 50
        config.emissionShape = .circle(radius: 10)
        config.sizeRange = 8...18
        config.speedRange = 70...130
        config.turbulence = 30
        return config
    }
    
    /// Creates intense inferno flames.
    public static func inferno() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 150
        config.maxParticles = 500
        config.emissionShape = .line(length: 100)
        config.sizeRange = 15...40
        config.speedRange = 120...250
        config.turbulence = 60
        config.lifetimeRange = 0.8...2.0
        return config
    }
    
    /// Creates ember particles (for combining with fire).
    public static func embers() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        config.emissionRate = 15
        config.maxParticles = 100
        config.lifetimeRange = 1.5...4.0
        config.emissionShape = .circle(radius: 40)
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 3
        config.speedRange = 40...100
        config.sizeRange = 2...5
        config.colorPalette = [.orange, .yellow, .red]
        config.gravity = Vector2D(x: 0, y: -30)
        config.turbulence = 50
        config.blendMode = .additive
        return config
    }
}
