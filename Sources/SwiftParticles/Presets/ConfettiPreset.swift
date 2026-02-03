// ConfettiPreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ConfettiPreset

/// Colorful celebration confetti effect preset.
///
/// Creates a festive confetti effect with multicolored pieces falling
/// and spinning. Perfect for celebrations, achievements, and success states.
///
/// ## Customization Options
/// ```swift
/// // Rainbow confetti
/// let rainbow = ConfettiPreset.rainbow()
///
/// // Gold celebration
/// let gold = ConfettiPreset.gold()
///
/// // Custom colors
/// let custom = ConfettiPreset.withColors([.red, .blue, .green])
/// ```
public enum ConfettiPreset {
    
    /// Default confetti configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 40
        config.maxParticles = 300
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 3.0...5.0
        
        // Emission shape - top of screen, full width
        config.emissionShape = .line(length: 400)
        config.emissionAngle = .pi / 2  // Downward
        config.spreadAngle = .pi / 6
        
        // Velocity
        config.speedRange = 100...200
        config.velocityRandomness = 0.3
        
        // Visual properties
        config.sizeRange = 8...15
        config.opacityRange = 0.9...1.0
        config.shape = .square
        
        // Colors - festive palette
        config.colorPalette = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple,
            .pink,
            .cyan
        ]
        
        // Rotation
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -6...6
        
        // Physics
        config.gravity = Vector2D(x: 0, y: 150)
        config.wind = Vector2D(x: 20, y: 0)
        config.drag = 0.02
        config.turbulence = 30
        config.turbulenceFrequency = 0.5
        
        // Rendering
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates rainbow confetti.
    public static func rainbow() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.0, blue: 0.0),   // Red
            ParticleColor(red: 1.0, green: 0.5, blue: 0.0),   // Orange
            ParticleColor(red: 1.0, green: 1.0, blue: 0.0),   // Yellow
            ParticleColor(red: 0.0, green: 1.0, blue: 0.0),   // Green
            ParticleColor(red: 0.0, green: 0.0, blue: 1.0),   // Blue
            ParticleColor(red: 0.5, green: 0.0, blue: 0.5),   // Indigo
            ParticleColor(red: 0.9, green: 0.0, blue: 0.9)    // Violet
        ]
        return config
    }
    
    /// Creates gold/golden confetti.
    public static func gold() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            .gold,
            ParticleColor(red: 1.0, green: 0.9, blue: 0.5),
            ParticleColor(red: 0.9, green: 0.75, blue: 0.3),
            ParticleColor(red: 0.8, green: 0.65, blue: 0.2)
        ]
        config.blendMode = .additive
        return config
    }
    
    /// Creates silver confetti.
    public static func silver() -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            .silver,
            .white,
            ParticleColor(red: 0.85, green: 0.85, blue: 0.9),
            ParticleColor(red: 0.7, green: 0.7, blue: 0.8)
        ]
        return config
    }
    
    /// Creates confetti with custom colors.
    /// - Parameter colors: Array of colors to use.
    public static func withColors(_ colors: [ParticleColor]) -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = colors
        return config
    }
    
    /// Creates a burst of confetti.
    /// - Parameter count: Number of confetti pieces in the burst.
    public static func burst(count: Int = 100) -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 0
        config.burstCount = count
        config.burstInterval = 0.5
        config.duration = 3.0
        config.speedRange = 200...400
        config.spreadAngle = .pi
        config.emissionShape = .point
        config.emissionAngle = -.pi / 2  // Upward burst
        return config
    }
    
    /// Creates gentle floating confetti.
    public static func gentle() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 15
        config.speedRange = 30...80
        config.gravity = Vector2D(x: 0, y: 50)
        config.turbulence = 50
        config.lifetimeRange = 5.0...8.0
        return config
    }
    
    /// Creates heavy confetti shower.
    public static func shower() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 100
        config.maxParticles = 500
        config.speedRange = 150...300
        config.gravity = Vector2D(x: 0, y: 250)
        config.lifetimeRange = 2.0...4.0
        return config
    }
}
