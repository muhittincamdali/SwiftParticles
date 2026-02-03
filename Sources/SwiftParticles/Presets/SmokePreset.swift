// SmokePreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - SmokePreset

/// Billowing smoke clouds effect preset.
///
/// Creates soft, expanding smoke that rises and dissipates. Great for
/// atmospheric effects, explosions, or chimney smoke.
///
/// ## Customization Options
/// ```swift
/// // Light wispy smoke
/// let wispy = SmokePreset.wispy()
///
/// // Dark heavy smoke
/// let heavy = SmokePreset.heavy()
///
/// // Colored smoke
/// let colored = SmokePreset.colored(.purple)
/// ```
public enum SmokePreset {
    
    /// Default smoke configuration.
    public static var configuration: ParticleConfiguration {
        var config = ParticleConfiguration()
        
        // Emission settings
        config.emissionRate = 25
        config.maxParticles = 200
        config.burstCount = 0
        config.duration = .infinity
        
        // Particle lifetime
        config.lifetimeRange = 2.0...5.0
        
        // Emission shape
        config.emissionShape = .circle(radius: 15)
        config.emissionAngle = -.pi / 2  // Upward
        config.spreadAngle = .pi / 4
        
        // Velocity
        config.speedRange = 30...60
        config.velocityRandomness = 0.4
        
        // Visual properties - smoke expands as it rises
        config.sizeRange = 20...40
        config.sizeOverLifetime = [0: 0.3, 0.5: 1.0, 1.0: 1.5]
        config.opacityRange = 0.4...0.7
        config.opacityOverLifetime = [0: 0.0, 0.1: 0.6, 0.7: 0.4, 1.0: 0.0]
        config.shape = .circle
        
        // Colors - gray smoke
        config.colorPalette = [
            ParticleColor(red: 0.5, green: 0.5, blue: 0.5),
            ParticleColor(red: 0.6, green: 0.6, blue: 0.6),
            ParticleColor(red: 0.4, green: 0.4, blue: 0.45)
        ]
        
        // Slow rotation
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -0.5...0.5
        
        // Physics
        config.gravity = Vector2D(x: 0, y: -20)
        config.wind = Vector2D(x: 15, y: 0)
        config.drag = 0.08
        config.turbulence = 20
        config.turbulenceFrequency = 0.3
        
        // Rendering
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates light wispy smoke.
    public static func wispy() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 10
        config.maxParticles = 80
        config.sizeRange = 15...30
        config.opacityRange = 0.2...0.4
        config.speedRange = 20...40
        config.lifetimeRange = 3.0...6.0
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.7, blue: 0.7),
            ParticleColor(red: 0.8, green: 0.8, blue: 0.8)
        ]
        return config
    }
    
    /// Creates heavy dark smoke.
    public static func heavy() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 50
        config.maxParticles = 300
        config.sizeRange = 30...60
        config.opacityRange = 0.5...0.8
        config.speedRange = 40...80
        config.lifetimeRange = 2.5...5.0
        config.colorPalette = [
            ParticleColor(red: 0.2, green: 0.2, blue: 0.2),
            ParticleColor(red: 0.3, green: 0.3, blue: 0.3),
            ParticleColor(red: 0.15, green: 0.15, blue: 0.15)
        ]
        return config
    }
    
    /// Creates colored smoke.
    /// - Parameter color: Base color for the smoke.
    public static func colored(_ color: ParticleColor) -> ParticleConfiguration {
        var config = configuration
        config.colorPalette = [
            color,
            color.brightened(by: 0.1),
            color.darkened(by: 0.1)
        ]
        return config
    }
    
    /// Creates steam/mist effect.
    public static func steam() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 30
        config.sizeRange = 15...35
        config.opacityRange = 0.15...0.35
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.9, blue: 0.95),
            .white
        ]
        config.lifetimeRange = 1.5...3.5
        config.speedRange = 40...80
        return config
    }
    
    /// Creates dust cloud effect.
    public static func dust() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 40
        config.sizeRange = 10...25
        config.opacityRange = 0.3...0.6
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.6, blue: 0.5),
            ParticleColor(red: 0.6, green: 0.55, blue: 0.45),
            ParticleColor(red: 0.65, green: 0.58, blue: 0.48)
        ]
        config.gravity = Vector2D(x: 0, y: 10)
        config.turbulence = 40
        return config
    }
    
    /// Creates exhaust/vehicle smoke.
    public static func exhaust() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 35
        config.emissionAngle = .pi  // Backward
        config.spreadAngle = .pi / 6
        config.sizeRange = 8...20
        config.speedRange = 60...120
        config.lifetimeRange = 1.0...2.5
        config.colorPalette = [
            ParticleColor(red: 0.4, green: 0.4, blue: 0.45),
            ParticleColor(red: 0.5, green: 0.5, blue: 0.55)
        ]
        return config
    }
    
    /// Creates explosion smoke burst.
    public static func explosion() -> ParticleConfiguration {
        var config = configuration
        config.emissionRate = 0
        config.burstCount = 80
        config.emissionShape = .circle(radius: 10)
        config.spreadAngle = .pi
        config.sizeRange = 25...50
        config.speedRange = 80...200
        config.lifetimeRange = 1.5...3.5
        config.opacityRange = 0.6...0.9
        config.colorPalette = [
            ParticleColor(red: 0.3, green: 0.3, blue: 0.3),
            ParticleColor(red: 0.4, green: 0.35, blue: 0.3),
            ParticleColor(red: 0.25, green: 0.25, blue: 0.25)
        ]
        return config
    }
}
