// NaturePreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - NaturePreset

/// Natural environment particle effects.
///
/// Creates realistic natural phenomena like leaves falling, bubbles,
/// fireflies, dust motes, and pollen floating in the air.
///
/// ## Usage Examples
/// ```swift
/// // Autumn leaves
/// let leaves = NaturePreset.autumnLeaves()
///
/// // Underwater bubbles
/// let bubbles = NaturePreset.bubbles()
///
/// // Floating dust motes
/// let dust = NaturePreset.dustMotes()
/// ```
public enum NaturePreset {
    
    // MARK: - Leaves
    
    /// Creates autumn falling leaves effect.
    public static func autumnLeaves() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 8
        config.maxParticles = 100
        config.duration = .infinity
        config.lifetimeRange = 5.0...10.0
        
        config.emissionShape = .line(length: 400)
        config.emissionAngle = .pi / 2
        config.spreadAngle = .pi / 6
        
        config.speedRange = 30...80
        config.velocityRandomness = 0.4
        
        config.sizeRange = 15...30
        config.shape = .leaf
        
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.4, blue: 0.1),   // Orange
            ParticleColor(red: 0.8, green: 0.2, blue: 0.1),   // Red
            ParticleColor(red: 0.9, green: 0.7, blue: 0.2),   // Yellow
            ParticleColor(red: 0.6, green: 0.3, blue: 0.1)    // Brown
        ]
        
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -3...3
        
        config.gravity = Vector2D(x: 0, y: 40)
        config.wind = Vector2D(x: 30, y: 0)
        config.drag = 0.05
        config.turbulence = 60
        config.turbulenceFrequency = 0.3
        
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates spring cherry blossom petals.
    public static func cherryBlossoms() -> ParticleConfiguration {
        var config = autumnLeaves()
        config.emissionRate = 12
        config.sizeRange = 8...18
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.85, blue: 0.9),
            ParticleColor(red: 1.0, green: 0.75, blue: 0.85),
            ParticleColor(red: 1.0, green: 0.9, blue: 0.95),
            ParticleColor(red: 0.95, green: 0.7, blue: 0.8)
        ]
        config.lifetimeRange = 4.0...8.0
        return config
    }
    
    /// Creates dandelion seeds floating.
    public static func dandelion() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 5
        config.maxParticles = 50
        config.lifetimeRange = 8.0...15.0
        
        config.emissionShape = .circle(radius: 20)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 10...30
        config.velocityRandomness = 0.6
        
        config.sizeRange = 8...15
        config.shape = .star
        
        config.colorPalette = [.white, ParticleColor(red: 0.95, green: 0.95, blue: 0.9)]
        
        config.gravity = Vector2D(x: 0, y: -5)
        config.wind = Vector2D(x: 20, y: 0)
        config.turbulence = 40
        
        return config
    }
    
    // MARK: - Water
    
    /// Creates underwater bubbles effect.
    public static func bubbles() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 15
        config.maxParticles = 150
        config.duration = .infinity
        config.lifetimeRange = 3.0...6.0
        
        config.emissionShape = .line(length: 300)
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 8
        
        config.speedRange = 40...100
        config.velocityRandomness = 0.3
        
        config.sizeRange = 5...20
        config.sizeOverLifetime = [0: 0.8, 0.5: 1.0, 0.9: 1.1, 1.0: 0.0]
        config.opacityRange = 0.3...0.7
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.5),
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.4)
        ]
        
        config.gravity = Vector2D(x: 0, y: -80)
        config.drag = 0.02
        config.turbulence = 30
        
        config.blendMode = .normal
        
        return config
    }
    
    /// Creates water splash effect.
    public static func splash() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 60
        config.maxParticles = 100
        config.lifetimeRange = 0.5...1.5
        
        config.emissionShape = .point
        config.emissionAngle = -.pi / 2
        config.spreadAngle = .pi / 2
        
        config.speedRange = 150...300
        config.velocityRandomness = 0.3
        
        config.sizeRange = 3...10
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.8),
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.6)
        ]
        
        config.gravity = Vector2D(x: 0, y: 400)
        config.drag = 0.02
        
        return config
    }
    
    /// Creates ripple waves effect.
    public static func ripples() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 2
        config.maxParticles = 20
        config.lifetimeRange = 2.0...3.0
        
        config.emissionShape = .point
        config.spreadAngle = 0
        
        config.speedRange = 50...100
        config.shape = .ring
        
        config.sizeRange = 5...10
        config.sizeOverLifetime = [0: 0.1, 0.5: 0.8, 1.0: 1.5]
        config.opacityOverLifetime = [0: 0.8, 0.7: 0.4, 1.0: 0.0]
        
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.6)
        ]
        
        return config
    }
    
    // MARK: - Air
    
    /// Creates dust motes floating in sunlight.
    public static func dustMotes() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 20
        config.maxParticles = 200
        config.lifetimeRange = 4.0...8.0
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 5...20
        config.velocityRandomness = 0.8
        
        config.sizeRange = 1...4
        config.opacityRange = 0.2...0.6
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 0.5),
            ParticleColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 0.4)
        ]
        
        config.gravity = Vector2D(x: 0, y: -2)
        config.turbulence = 20
        config.turbulenceFrequency = 0.2
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates pollen floating effect.
    public static func pollen() -> ParticleConfiguration {
        var config = dustMotes()
        config.sizeRange = 2...5
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.95, blue: 0.5, alpha: 0.6),
            ParticleColor(red: 0.95, green: 0.9, blue: 0.4, alpha: 0.5)
        ]
        return config
    }
    
    /// Creates fireflies/glowing insects effect.
    public static func fireflies() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 3
        config.maxParticles = 30
        config.lifetimeRange = 4.0...8.0
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 10...40
        config.velocityRandomness = 0.7
        
        config.sizeRange = 4...10
        config.opacityOverLifetime = [
            0: 0.0,
            0.1: 0.8,
            0.2: 0.3,
            0.3: 0.9,
            0.5: 0.2,
            0.6: 1.0,
            0.8: 0.4,
            1.0: 0.0
        ]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 1.0, blue: 0.4),
            ParticleColor(red: 0.7, green: 0.95, blue: 0.3)
        ]
        
        config.turbulence = 50
        config.turbulenceFrequency = 0.4
        
        config.blendMode = .additive
        
        return config
    }
    
}
