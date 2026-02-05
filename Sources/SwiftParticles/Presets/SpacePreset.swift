// SpacePreset.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - SpacePreset

/// Cosmic and space-themed particle effects.
///
/// Creates stunning space visuals including stars, galaxies, nebulas,
/// meteor showers, warp speed, and cosmic dust.
///
/// ## Usage Examples
/// ```swift
/// // Starfield background
/// let stars = SpacePreset.starfield()
///
/// // Shooting stars
/// let meteors = SpacePreset.meteorShower()
///
/// // Warp speed effect
/// let warp = SpacePreset.warpSpeed()
/// ```
public enum SpacePreset {
    
    // MARK: - Stars
    
    /// Creates twinkling starfield background.
    public static func starfield() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 10
        config.maxParticles = 200
        config.lifetimeRange = 3.0...8.0
        
        config.emissionShape = .point
        config.spreadAngle = 0
        
        config.speedRange = 0...5
        config.velocityRandomness = 0.5
        
        config.sizeRange = 1...5
        config.opacityOverLifetime = [
            0: 0.0,
            0.1: 0.8,
            0.2: 0.4,
            0.4: 1.0,
            0.6: 0.5,
            0.8: 0.9,
            1.0: 0.0
        ]
        config.shape = .star
        
        config.colorPalette = [
            .white,
            ParticleColor(red: 0.9, green: 0.95, blue: 1.0),
            ParticleColor(red: 1.0, green: 0.95, blue: 0.8),
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0)
        ]
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates distant galaxy stars.
    public static func galaxyStars() -> ParticleConfiguration {
        var config = starfield()
        config.emissionRate = 30
        config.maxParticles = 500
        config.sizeRange = 1...3
        config.emissionShape = .circle(radius: 150)
        config.rotationRange = 0...0.02  // Slight rotation
        return config
    }
    
    /// Creates bright supernova explosion.
    public static func supernova() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 0
        config.burstCount = 300
        config.maxParticles = 500
        config.lifetimeRange = 1.0...3.0
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 100...400
        config.velocityRandomness = 0.4
        
        config.sizeRange = 3...15
        config.sizeOverLifetime = [0: 1.0, 0.3: 1.5, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 1.0),
            ParticleColor(red: 1.0, green: 0.9, blue: 0.6),
            ParticleColor(red: 1.0, green: 0.5, blue: 0.2),
            ParticleColor(red: 0.8, green: 0.2, blue: 0.1)
        ]
        config.colorOverLifetime = [
            0.0: ParticleColor(red: 1.0, green: 1.0, blue: 1.0),
            0.3: ParticleColor(red: 1.0, green: 0.8, blue: 0.4),
            0.6: ParticleColor(red: 1.0, green: 0.4, blue: 0.2),
            1.0: ParticleColor(red: 0.5, green: 0.1, blue: 0.1, alpha: 0)
        ]
        
        config.drag = 0.02
        
        config.blendMode = .additive
        config.trailEnabled = true
        config.trailLength = 10
        
        return config
    }
    
    // MARK: - Meteors
    
    /// Creates meteor shower effect.
    public static func meteorShower() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 3
        config.maxParticles = 20
        config.lifetimeRange = 0.5...1.5
        
        config.emissionShape = .line(length: 500)
        config.emissionAngle = .pi * 0.75
        config.spreadAngle = .pi / 10
        
        config.speedRange = 300...600
        
        config.sizeRange = 2...6
        config.opacityOverLifetime = [0: 0.0, 0.1: 1.0, 0.9: 0.8, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            .white,
            ParticleColor(red: 1.0, green: 0.9, blue: 0.7)
        ]
        
        config.blendMode = .additive
        config.trailEnabled = true
        config.trailLength = 30
        config.trailFadeRate = 0.15
        
        return config
    }
    
    /// Creates asteroid belt particles.
    public static func asteroidBelt() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 15
        config.maxParticles = 150
        config.lifetimeRange = 5.0...10.0
        
        config.emissionShape = .ring(radius: 100)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 20...50
        
        config.sizeRange = 3...12
        config.shape = .diamond
        
        config.colorPalette = [
            ParticleColor(red: 0.5, green: 0.4, blue: 0.35),
            ParticleColor(red: 0.6, green: 0.5, blue: 0.45),
            ParticleColor(red: 0.4, green: 0.35, blue: 0.3)
        ]
        
        config.rotationRange = 0...(.pi * 2)
        config.angularVelocityRange = -1...1
        
        config.orbitalMotion = true
        config.orbitalCenter = CGPoint(x: 200, y: 200)
        config.orbitalSpeed = 0.5
        
        return config
    }
    
    // MARK: - Space Travel
    
    /// Creates warp speed/hyperspace effect.
    public static func warpSpeed() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 100
        config.maxParticles = 300
        config.lifetimeRange = 0.5...1.5
        
        config.emissionShape = .circle(radius: 20)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 200...600
        config.speedOverLifetime = [0: 0.2, 0.3: 1.0, 1.0: 2.0]
        
        config.sizeRange = 1...4
        config.sizeOverLifetime = [0: 0.5, 0.5: 1.0, 1.0: 2.0]
        config.shape = .circle
        
        config.colorPalette = [
            .white,
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0)
        ]
        
        config.blendMode = .additive
        config.stretchFactor = 8.0
        
        return config
    }
    
    /// Creates engine thrust/exhaust effect.
    public static func engineThrust() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 80
        config.maxParticles = 200
        config.lifetimeRange = 0.3...0.8
        
        config.emissionShape = .circle(radius: 10)
        config.emissionAngle = .pi / 2
        config.spreadAngle = .pi / 6
        
        config.speedRange = 150...300
        
        config.sizeRange = 5...15
        config.sizeOverLifetime = [0: 1.0, 0.5: 0.8, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.8, green: 0.9, blue: 1.0),
            ParticleColor(red: 0.5, green: 0.7, blue: 1.0),
            ParticleColor(red: 0.3, green: 0.5, blue: 1.0)
        ]
        config.colorOverLifetime = [
            0.0: ParticleColor(red: 0.9, green: 0.95, blue: 1.0),
            0.3: ParticleColor(red: 0.5, green: 0.7, blue: 1.0),
            0.6: ParticleColor(red: 0.3, green: 0.4, blue: 0.8),
            1.0: ParticleColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 0)
        ]
        
        config.blendMode = .additive
        
        return config
    }
    
    // MARK: - Nebula
    
    /// Creates colorful nebula/cosmic cloud.
    public static func nebula() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 3
        config.maxParticles = 30
        config.lifetimeRange = 10.0...20.0
        
        config.emissionShape = .circle(radius: 200)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 2...10
        config.velocityRandomness = 0.8
        
        config.sizeRange = 80...200
        config.opacityRange = 0.1...0.3
        config.opacityOverLifetime = [0: 0.0, 0.2: 0.2, 0.8: 0.2, 1.0: 0.0]
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 0.3),
            ParticleColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.25),
            ParticleColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 0.3),
            ParticleColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 0.25)
        ]
        
        config.turbulence = 10
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates cosmic dust/interstellar medium.
    public static func cosmicDust() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 20
        config.maxParticles = 300
        config.lifetimeRange = 5.0...10.0
        
        config.emissionShape = .point
        config.spreadAngle = .pi * 2
        
        config.speedRange = 5...20
        
        config.sizeRange = 1...4
        config.opacityRange = 0.2...0.5
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 0.4),
            ParticleColor(red: 0.8, green: 0.75, blue: 0.9, alpha: 0.3)
        ]
        
        config.turbulence = 15
        
        config.blendMode = .additive
        
        return config
    }
    
    /// Creates black hole accretion disk effect.
    public static func blackHole() -> ParticleConfiguration {
        var config = ParticleConfiguration()
        
        config.emissionRate = 50
        config.maxParticles = 400
        config.lifetimeRange = 2.0...5.0
        
        config.emissionShape = .ring(radius: 125)
        config.spreadAngle = .pi * 2
        
        config.speedRange = 50...150
        
        config.sizeRange = 2...8
        config.shape = .circle
        
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.6, blue: 0.2),
            ParticleColor(red: 1.0, green: 0.4, blue: 0.1),
            ParticleColor(red: 0.8, green: 0.2, blue: 0.1)
        ]
        
        config.orbitalMotion = true
        config.orbitalCenter = CGPoint(x: 200, y: 200)
        config.orbitalSpeed = 2.0
        config.spiralInward = true
        config.spiralRate = 0.05
        
        config.blendMode = .additive
        
        return config
    }
    
}
