// PointEmitter.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - PointEmitter

/// An emitter that spawns particles from a single point in space.
///
/// `PointEmitter` is the simplest emitter type, spawning all particles from
/// the same position. This is useful for effects like sparks from a point,
/// explosions, or fountain-like effects.
///
/// ## Usage Example
/// ```swift
/// let emitter = PointEmitter()
/// emitter.position = Vector2D(x: 200, y: 300)
/// emitter.spreadAngle = .pi / 4  // 45 degree spread
/// emitter.emissionAngle = -.pi / 2  // Upward
/// emitter.start()
/// ```
public final class PointEmitter: BaseEmitter {
    
    // MARK: - Properties
    
    /// The single point from which particles are emitted.
    public var emissionPoint: Vector2D {
        get { position }
        set { position = newValue }
    }
    
    /// Whether to add slight position variation for more natural look.
    public var positionJitter: Double = 0
    
    /// Whether particles should inherit velocity from emitter movement.
    public var inheritVelocity: Bool = false
    
    /// Velocity inheritance multiplier.
    public var velocityInheritance: Double = 0.5
    
    /// Previous position for velocity inheritance calculation.
    private var previousPosition: Vector2D = .zero
    
    // MARK: - Initialization
    
    /// Creates a new point emitter.
    /// - Parameters:
    ///   - position: The emission point.
    ///   - configuration: The particle configuration.
    public override init(
        configuration: ParticleConfiguration = ParticleConfiguration(),
        position: Vector2D = .zero
    ) {
        super.init(configuration: configuration, position: position)
        self.previousPosition = position
        self.configuration.emissionShape = .point
    }
    
    /// Creates a point emitter with specific settings.
    /// - Parameters:
    ///   - position: The emission point.
    ///   - emissionAngle: Direction of emission in radians.
    ///   - spreadAngle: Angular spread in radians.
    ///   - emissionRate: Particles per second.
    public convenience init(
        position: Vector2D,
        emissionAngle: Double,
        spreadAngle: Double,
        emissionRate: Double = 50
    ) {
        var config = ParticleConfiguration()
        config.emissionAngle = emissionAngle
        config.spreadAngle = spreadAngle
        config.emissionRate = emissionRate
        config.emissionShape = .point
        self.init(configuration: config, position: position)
    }
    
    // MARK: - Override Methods
    
    /// Calculates the spawn position for a new particle.
    /// - Returns: The spawn position with optional jitter.
    public override func calculateSpawnPosition() -> Vector2D {
        var spawnPos = position
        
        if positionJitter > 0 {
            spawnPos.x += Double.random(in: -positionJitter...positionJitter)
            spawnPos.y += Double.random(in: -positionJitter...positionJitter)
        }
        
        return spawnPos
    }
    
    /// Calculates the initial velocity for a new particle.
    /// - Returns: The initial velocity vector.
    public override func calculateInitialVelocity() -> Vector2D {
        var velocity = super.calculateInitialVelocity()
        
        if inheritVelocity {
            let emitterVelocity = position - previousPosition
            velocity = velocity + emitterVelocity * velocityInheritance * 60  // Assuming 60fps
        }
        
        return velocity
    }
    
    /// Updates the emitter state.
    /// - Parameters:
    ///   - deltaTime: Time elapsed.
    ///   - currentCount: Current active particle count.
    /// - Returns: Array of newly spawned particles.
    public override func update(deltaTime: Double, currentCount: Int) -> [Particle] {
        let particles = super.update(deltaTime: deltaTime, currentCount: currentCount)
        previousPosition = position
        return particles
    }
}

// MARK: - PointEmitter Builder

extension PointEmitter {
    
    /// Sets the position jitter amount.
    /// - Parameter jitter: Maximum position offset in points.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withPositionJitter(_ jitter: Double) -> Self {
        positionJitter = jitter
        return self
    }
    
    /// Enables velocity inheritance from emitter movement.
    /// - Parameter inheritance: The inheritance multiplier.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withVelocityInheritance(_ inheritance: Double = 0.5) -> Self {
        inheritVelocity = true
        velocityInheritance = inheritance
        return self
    }
    
    /// Sets the emission angle.
    /// - Parameter angle: Angle in radians.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withEmissionAngle(_ angle: Double) -> Self {
        configuration.emissionAngle = angle
        return self
    }
    
    /// Sets the spread angle.
    /// - Parameter angle: Spread in radians.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withSpreadAngle(_ angle: Double) -> Self {
        configuration.spreadAngle = angle
        return self
    }
}

// MARK: - BaseEmitter

/// Base class for all emitter types providing common functionality.
public class BaseEmitter: ParticleEmitter {
    
    // MARK: - Template Methods
    
    /// Override to customize spawn position calculation.
    /// - Returns: The position where the particle should spawn.
    public func calculateSpawnPosition() -> Vector2D {
        return position
    }
    
    /// Override to customize initial velocity calculation.
    /// - Returns: The initial velocity for the particle.
    public func calculateInitialVelocity() -> Vector2D {
        let speed = Double.random(in: configuration.speedRange)
        let angleVariation = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
        let angle = configuration.emissionAngle + angleVariation
        
        return Vector2D(
            x: cos(angle) * speed,
            y: sin(angle) * speed
        )
    }
    
    /// Override to customize particle creation.
    /// - Returns: A new particle configured for this emitter.
    public func createConfiguredParticle() -> Particle {
        let spawnPosition = calculateSpawnPosition()
        let velocity = calculateInitialVelocity()
        
        let size = Double.random(in: configuration.sizeRange)
        let opacity = Double.random(in: configuration.opacityRange)
        let rotation = Double.random(in: configuration.rotationRange)
        let angularVelocity = Double.random(in: configuration.angularVelocityRange)
        let lifetime = Double.random(in: configuration.lifetimeRange)
        let mass = Double.random(in: configuration.massRange)
        
        let color: ParticleColor
        if configuration.colorPalette.isEmpty {
            color = .white
        } else {
            color = configuration.colorPalette[Int.random(in: 0..<configuration.colorPalette.count)]
        }
        
        return Particle(
            position: spawnPosition,
            velocity: velocity,
            acceleration: .zero,
            rotation: rotation,
            angularVelocity: angularVelocity,
            scale: 1.0,
            opacity: opacity,
            color: color,
            lifetime: lifetime,
            mass: mass,
            size: CGSize(width: size, height: size),
            shape: configuration.shape
        )
    }
}
