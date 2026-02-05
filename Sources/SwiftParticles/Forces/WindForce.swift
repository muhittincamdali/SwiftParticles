// WindForce.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - WindForce

/// A force that applies directional wind with optional gusting and variability.
///
/// `WindForce` simulates wind by applying a directional force with optional
/// randomness and gusting patterns. This creates more realistic environmental
/// effects than constant forces.
///
/// ## Usage Example
/// ```swift
/// // Simple rightward wind
/// let wind = WindForce(direction: Vector2D(x: 1, y: 0), strength: 50)
///
/// // Gusty wind
/// let gusty = WindForce.gusty(
///     direction: Vector2D(x: 1, y: 0.2),
///     baseStrength: 30,
///     gustStrength: 80
/// )
/// ```
public final class WindForce: BaseForce {
    
    // MARK: - Properties
    
    /// Direction of the wind (normalized).
    public var direction: Vector2D {
        didSet { direction = direction.normalized }
    }
    
    /// Amount of random variation in direction (radians).
    public var directionVariation: Double = 0
    
    /// Amount of random variation in strength (0-1).
    public var strengthVariation: Double = 0
    
    /// Whether gusting is enabled.
    public var gustingEnabled: Bool = false
    
    /// Maximum gust strength multiplier.
    public var gustStrength: Double = 2.0
    
    /// How often gusts occur (gusts per second).
    public var gustFrequency: Double = 0.3
    
    /// Duration of each gust in seconds.
    public var gustDuration: Double = 0.5
    
    /// Current gust multiplier (internal).
    private var currentGust: Double = 1.0
    
    /// Time until next gust (internal).
    private var gustTimer: Double = 0
    
    /// Time remaining in current gust (internal).
    private var gustRemaining: Double = 0
    
    /// Whether wind affects particles based on their size.
    public var affectedBySize: Bool = true
    
    /// Reference size for size-based wind resistance.
    public var referenceSize: Double = 8
    
    /// Drag coefficient for velocity-dependent wind.
    public var dragCoefficient: Double = 0
    
    // MARK: - Computed Properties
    
    /// The base wind vector (direction * strength).
    public var windVector: Vector2D {
        direction * strength
    }
    
    // MARK: - Initialization
    
    /// Creates a wind force with the specified direction and strength.
    /// - Parameters:
    ///   - direction: Wind direction.
    ///   - strength: Wind strength in points/sec².
    public init(direction: Vector2D, strength: Double = 50) {
        self.direction = direction.normalized
        super.init(strength: strength)
    }
    
    /// Creates a horizontal wind force.
    /// - Parameters:
    ///   - rightward: Whether wind blows right (true) or left (false).
    ///   - strength: Wind strength.
    public convenience init(rightward: Bool = true, strength: Double = 50) {
        let dir = Vector2D(x: rightward ? 1 : -1, y: 0)
        self.init(direction: dir, strength: strength)
    }
    
    /// Creates a wind force at a specific angle.
    /// - Parameters:
    ///   - angle: Wind direction in radians.
    ///   - strength: Wind strength.
    public convenience init(angle: Double, strength: Double = 50) {
        let dir = Vector2D(x: cos(angle), y: sin(angle))
        self.init(direction: dir, strength: strength)
    }
    
    // MARK: - Force Calculation
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard shouldApply(to: particle) else { return .zero }
        
        // Update gusting
        updateGusting(deltaTime: deltaTime)
        
        // Calculate base wind
        var windDir = direction
        
        // Apply direction variation
        if directionVariation > 0 {
            let variation = Double.random(in: -directionVariation...directionVariation)
            windDir = windDir.rotated(by: variation)
        }
        
        // Calculate strength with variation
        var effectiveStrength = strength
        if strengthVariation > 0 {
            let variation = 1.0 + Double.random(in: -strengthVariation...strengthVariation)
            effectiveStrength *= variation
        }
        
        // Apply gust multiplier
        effectiveStrength *= currentGust
        
        var force = windDir * effectiveStrength
        
        // Size-based resistance
        if affectedBySize && referenceSize > 0 {
            let sizeFactor = particle.size.width / referenceSize
            force = force * sizeFactor
        }
        
        // Velocity-dependent drag component
        if dragCoefficient > 0 {
            let relativeVelocity = windDir * strength - particle.velocity
            let dragForce = relativeVelocity * dragCoefficient
            force = force + dragForce
        }
        
        // Apply bounds fade
        let fadeMult = boundsFadeMultiplier(for: particle)
        
        return force * fadeMult
    }
    
    // MARK: - Private Methods
    
    /// Updates the gusting state.
    private func updateGusting(deltaTime: Double) {
        guard gustingEnabled else {
            currentGust = 1.0
            return
        }
        
        // Update gust timer
        gustTimer -= deltaTime
        
        if gustRemaining > 0 {
            // Currently in a gust
            gustRemaining -= deltaTime
            
            // Gust curve (ease in/out)
            let progress = 1.0 - (gustRemaining / gustDuration)
            let curve = sin(progress * .pi)  // Bell curve
            currentGust = 1.0 + (gustStrength - 1.0) * curve
            
            if gustRemaining <= 0 {
                currentGust = 1.0
            }
        } else if gustTimer <= 0 {
            // Start a new gust
            gustRemaining = gustDuration
            gustTimer = 1.0 / gustFrequency + Double.random(in: -0.5...0.5) / gustFrequency
        } else {
            currentGust = 1.0
        }
    }
    
    // MARK: - Convenience Methods
    
    /// Enables gusting with the specified parameters.
    /// - Parameters:
    ///   - strength: Maximum gust strength multiplier.
    ///   - frequency: Gusts per second.
    ///   - duration: Duration of each gust.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withGusting(
        strength: Double = 2.0,
        frequency: Double = 0.3,
        duration: Double = 0.5
    ) -> Self {
        gustingEnabled = true
        gustStrength = strength
        gustFrequency = frequency
        gustDuration = duration
        return self
    }
    
    /// Adds random variation to the wind.
    /// - Parameters:
    ///   - direction: Direction variation in radians.
    ///   - strength: Strength variation (0-1).
    /// - Returns: Self for chaining.
    @discardableResult
    public func withVariation(direction: Double = 0.2, strength: Double = 0.3) -> Self {
        directionVariation = direction
        strengthVariation = strength
        return self
    }
    
    /// Enables velocity-dependent drag.
    /// - Parameter coefficient: Drag coefficient.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withDrag(_ coefficient: Double) -> Self {
        dragCoefficient = coefficient
        return self
    }
    
    public func reset() {
        currentGust = 1.0
        gustTimer = 0
        gustRemaining = 0
    }
}

// MARK: - Factory Methods

extension WindForce {
    
    /// Creates a gentle breeze.
    public static var breeze: WindForce {
        let wind = WindForce(rightward: true, strength: 20)
        wind.directionVariation = 0.1
        wind.strengthVariation = 0.2
        return wind
    }
    
    /// Creates moderate wind with gusting.
    public static var gusty: WindForce {
        let wind = WindForce(rightward: true, strength: 50)
        return wind.withGusting().withVariation()
    }
    
    /// Creates strong storm wind.
    public static var storm: WindForce {
        let wind = WindForce(rightward: true, strength: 150)
        wind.gustingEnabled = true
        wind.gustStrength = 3.0
        wind.gustFrequency = 0.5
        wind.directionVariation = 0.5
        wind.strengthVariation = 0.5
        return wind
    }
    
    /// Creates a custom gusty wind.
    /// - Parameters:
    ///   - direction: Wind direction.
    ///   - baseStrength: Base wind strength.
    ///   - gustStrength: Maximum gust strength.
    /// - Returns: A configured wind force.
    public static func gusty(
        direction: Vector2D,
        baseStrength: Double,
        gustStrength: Double
    ) -> WindForce {
        let wind = WindForce(direction: direction, strength: baseStrength)
        wind.gustingEnabled = true
        wind.gustStrength = gustStrength / baseStrength
        return wind
    }
}
