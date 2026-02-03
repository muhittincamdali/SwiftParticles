// GravityForce.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - GravityForce

/// A force that applies constant gravitational acceleration to particles.
///
/// `GravityForce` simulates gravity by applying a constant downward (or any direction)
/// acceleration to all particles. The force is independent of particle mass when
/// using `ignoresMass`, or proportional to mass for realistic physics.
///
/// ## Usage Example
/// ```swift
/// // Standard downward gravity
/// let gravity = GravityForce()
///
/// // Upward anti-gravity
/// let antiGravity = GravityForce(direction: Vector2D(x: 0, y: -1), strength: 150)
///
/// // Diagonal gravity
/// let diagonal = GravityForce(angle: .pi / 4, strength: 100)
/// ```
public final class GravityForce: BaseForce {
    
    // MARK: - Properties
    
    /// Direction of gravity (normalized).
    public var direction: Vector2D {
        didSet { direction = direction.normalized }
    }
    
    /// Whether gravity ignores particle mass (true = uniform acceleration).
    public var ignoresMass: Bool
    
    /// Multiplier applied based on particle age (for gradual effects).
    public var ageMultiplier: Double = 1.0
    
    /// Whether to scale gravity based on particle size.
    public var scaleWithSize: Bool = false
    
    /// Reference size for size scaling (default: 8x8).
    public var referenceSize: Double = 8
    
    // MARK: - Computed Properties
    
    /// The gravity vector (direction * strength).
    public var gravityVector: Vector2D {
        direction * strength
    }
    
    // MARK: - Initialization
    
    /// Creates a gravity force with default downward direction.
    /// - Parameters:
    ///   - strength: Gravitational acceleration in points/sec². Default is 98 (~1g).
    ///   - ignoresMass: Whether to apply uniform acceleration regardless of mass.
    public init(strength: Double = 98, ignoresMass: Bool = true) {
        self.direction = Vector2D(x: 0, y: 1)  // Downward
        self.ignoresMass = ignoresMass
        super.init(strength: strength)
    }
    
    /// Creates a gravity force with a specific direction.
    /// - Parameters:
    ///   - direction: The direction of gravity.
    ///   - strength: Gravitational acceleration.
    ///   - ignoresMass: Whether to apply uniform acceleration.
    public convenience init(
        direction: Vector2D,
        strength: Double = 98,
        ignoresMass: Bool = true
    ) {
        self.init(strength: strength, ignoresMass: ignoresMass)
        self.direction = direction.normalized
    }
    
    /// Creates a gravity force at a specific angle.
    /// - Parameters:
    ///   - angle: Angle in radians (0 = right, π/2 = down, π = left, -π/2 = up).
    ///   - strength: Gravitational acceleration.
    ///   - ignoresMass: Whether to apply uniform acceleration.
    public convenience init(
        angle: Double,
        strength: Double = 98,
        ignoresMass: Bool = true
    ) {
        let dir = Vector2D(x: cos(angle), y: sin(angle))
        self.init(direction: dir, strength: strength, ignoresMass: ignoresMass)
    }
    
    // MARK: - Force Calculation
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard shouldApply(to: particle) else { return .zero }
        
        var force = gravityVector
        
        // Apply mass if not ignoring
        if !ignoresMass {
            force = force * particle.mass
        }
        
        // Apply age multiplier
        if ageMultiplier != 1.0 {
            let ageFactor = pow(particle.normalizedAge, ageMultiplier)
            force = force * ageFactor
        }
        
        // Apply size scaling
        if scaleWithSize && referenceSize > 0 {
            let sizeFactor = particle.size.width / referenceSize
            force = force * sizeFactor
        }
        
        // Apply bounds fade
        let fadeMult = boundsFadeMultiplier(for: particle)
        
        return force * fadeMult
    }
    
    // MARK: - Convenience Methods
    
    /// Sets the gravity to point downward.
    /// - Returns: Self for chaining.
    @discardableResult
    public func pointingDown() -> Self {
        direction = Vector2D(x: 0, y: 1)
        return self
    }
    
    /// Sets the gravity to point upward.
    /// - Returns: Self for chaining.
    @discardableResult
    public func pointingUp() -> Self {
        direction = Vector2D(x: 0, y: -1)
        return self
    }
    
    /// Sets the gravity to point left.
    /// - Returns: Self for chaining.
    @discardableResult
    public func pointingLeft() -> Self {
        direction = Vector2D(x: -1, y: 0)
        return self
    }
    
    /// Sets the gravity to point right.
    /// - Returns: Self for chaining.
    @discardableResult
    public func pointingRight() -> Self {
        direction = Vector2D(x: 1, y: 0)
        return self
    }
    
    /// Sets the gravity direction by angle.
    /// - Parameter angle: Angle in radians.
    /// - Returns: Self for chaining.
    @discardableResult
    public func pointing(angle: Double) -> Self {
        direction = Vector2D(x: cos(angle), y: sin(angle))
        return self
    }
    
    /// Enables size-based gravity scaling.
    /// - Parameter reference: Reference size for 1x gravity.
    /// - Returns: Self for chaining.
    @discardableResult
    public func scalingWithSize(reference: Double = 8) -> Self {
        scaleWithSize = true
        referenceSize = reference
        return self
    }
}

// MARK: - Factory Methods

extension GravityForce {
    
    /// Creates Earth-like gravity (9.8 m/s² scaled to points).
    public static var earth: GravityForce {
        GravityForce(strength: 98)
    }
    
    /// Creates Moon-like gravity (1.62 m/s²).
    public static var moon: GravityForce {
        GravityForce(strength: 16.2)
    }
    
    /// Creates Mars-like gravity (3.71 m/s²).
    public static var mars: GravityForce {
        GravityForce(strength: 37.1)
    }
    
    /// Creates Jupiter-like gravity (24.79 m/s²).
    public static var jupiter: GravityForce {
        GravityForce(strength: 247.9)
    }
    
    /// Creates zero gravity (useful as a base for modification).
    public static var zero: GravityForce {
        GravityForce(strength: 0)
    }
    
    /// Creates gentle floating gravity (like underwater).
    public static var floating: GravityForce {
        GravityForce(strength: 20)
    }
    
    /// Creates upward anti-gravity.
    public static var antiGravity: GravityForce {
        GravityForce(direction: Vector2D(x: 0, y: -1), strength: 98)
    }
}
