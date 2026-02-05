// AttractorForce.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - AttractorForce

/// A force that attracts or repels particles toward/from a point.
///
/// `AttractorForce` creates gravitational-like attraction or repulsion from
/// a specific point. This is useful for black holes, magnets, cursor following,
/// or any point-based force field effects.
///
/// ## Usage Example
/// ```swift
/// // Attractor at center
/// let attractor = AttractorForce(
///     position: Vector2D(x: 200, y: 200),
///     strength: 500
/// )
///
/// // Repeller
/// let repeller = AttractorForce(
///     position: Vector2D(x: 200, y: 200),
///     strength: -500
/// )
/// ```
public final class AttractorForce: BaseForce {
    
    // MARK: - Properties
    
    /// Position of the attractor point.
    public var position: Vector2D
    
    /// Maximum radius of influence. Particles beyond this are unaffected.
    public var radius: Double
    
    /// How force diminishes with distance.
    public var falloff: AttractorFalloff
    
    /// Minimum distance to prevent infinite force at the center.
    public var minDistance: Double = 5
    
    /// Maximum force magnitude (prevents extreme values).
    public var maxForce: Double = 1000
    
    /// Whether to kill particles that reach the center.
    public var killOnReach: Bool = false
    
    /// Distance threshold for killing particles.
    public var killDistance: Double = 5
    
    /// Whether the attractor position follows a path.
    public var followsPath: Bool = false
    
    /// Path points for moving attractor.
    public var pathPoints: [Vector2D] = []
    
    /// Current index in path.
    private var pathIndex: Int = 0
    
    /// Speed of path movement.
    public var pathSpeed: Double = 100
    
    /// Whether path loops.
    public var pathLoops: Bool = true
    
    // MARK: - Initialization
    
    /// Creates an attractor force at the specified position.
    /// - Parameters:
    ///   - position: Center of the attractor.
    ///   - strength: Force strength (positive = attract, negative = repel).
    ///   - radius: Maximum radius of influence.
    ///   - falloff: How force diminishes with distance.
    public init(
        position: Vector2D,
        strength: Double = 500,
        radius: Double = 200,
        falloff: AttractorFalloff = .inverseSquare
    ) {
        self.position = position
        self.radius = radius
        self.falloff = falloff
        super.init(strength: strength)
    }
    
    // MARK: - Force Calculation
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard shouldApply(to: particle) else { return .zero }
        
        // Update path position if enabled
        if followsPath && !pathPoints.isEmpty {
            updatePathPosition(deltaTime: deltaTime)
        }
        
        // Calculate direction and distance
        let direction = position - particle.position
        var distance = direction.magnitude
        
        // Check if within radius
        guard distance <= radius else { return .zero }
        
        // Check for kill condition
        if killOnReach && distance <= killDistance {
            // Mark particle for death by returning zero (caller handles kill)
            return .zero
        }
        
        // Enforce minimum distance
        distance = max(distance, minDistance)
        
        // Calculate force magnitude based on falloff
        var forceMagnitude: Double
        
        switch falloff {
        case .none:
            forceMagnitude = strength
            
        case .linear:
            let t = 1.0 - (distance / radius)
            forceMagnitude = strength * t
            
        case .quadratic:
            let t = 1.0 - (distance / radius)
            forceMagnitude = strength * t * t
            
        case .inverseSquare:
            forceMagnitude = strength / (distance * distance)
            
        case .inverse:
            forceMagnitude = strength / distance
            
        case .exponential(let rate):
            forceMagnitude = strength * exp(-rate * distance)
            
        case .custom(let curve):
            let normalizedDistance = distance / radius
            forceMagnitude = strength * curve(normalizedDistance)
        }
        
        // Clamp to max force
        forceMagnitude = min(abs(forceMagnitude), maxForce)
        if strength < 0 {
            forceMagnitude = -forceMagnitude
        }
        
        // Calculate force vector
        let normalizedDir = direction.normalized
        var force = normalizedDir * forceMagnitude
        
        // Apply bounds fade
        let fadeMult = boundsFadeMultiplier(for: particle)
        force = force * fadeMult
        
        return force
    }
    
    // MARK: - Path Movement
    
    /// Updates the attractor position along the path.
    private func updatePathPosition(deltaTime: Double) {
        guard pathPoints.count >= 2 else { return }
        
        let currentTarget = pathPoints[(pathIndex + 1) % pathPoints.count]
        let direction = currentTarget - position
        let distance = direction.magnitude
        
        if distance < pathSpeed * deltaTime {
            // Reached target, move to next
            position = currentTarget
            pathIndex = (pathIndex + 1) % pathPoints.count
            
            if !pathLoops && pathIndex == 0 {
                followsPath = false
            }
        } else {
            // Move toward target
            position = position + direction.normalized * pathSpeed * deltaTime
        }
    }
    
    // MARK: - Configuration
    
    /// Sets the attractor to follow a path.
    /// - Parameters:
    ///   - points: Path waypoints.
    ///   - speed: Movement speed.
    ///   - loops: Whether to loop the path.
    /// - Returns: Self for chaining.
    @discardableResult
    public func following(path points: [Vector2D], speed: Double = 100, loops: Bool = true) -> Self {
        pathPoints = points
        pathSpeed = speed
        pathLoops = loops
        followsPath = true
        if !points.isEmpty {
            position = points[0]
        }
        return self
    }
    
    /// Configures particle killing at center.
    /// - Parameter distance: Distance threshold for killing.
    /// - Returns: Self for chaining.
    @discardableResult
    public func killingAtCenter(distance: Double = 5) -> Self {
        killOnReach = true
        killDistance = distance
        return self
    }
    
    public func reset() {
        pathIndex = 0
        if !pathPoints.isEmpty {
            position = pathPoints[0]
        }
    }
}

// MARK: - AttractorFalloff

/// How an attractor's force diminishes with distance.
public enum AttractorFalloff: Sendable {
    /// Constant force regardless of distance.
    case none
    /// Force decreases linearly with distance.
    case linear
    /// Force decreases quadratically with distance.
    case quadratic
    /// Realistic gravity: force = strength / distance².
    case inverseSquare
    /// Force = strength / distance.
    case inverse
    /// Exponential decay with the given rate.
    case exponential(rate: Double)
    /// Custom falloff curve (input: 0-1 normalized distance, output: multiplier).
    case custom(curve: @Sendable (Double) -> Double)
}

// MARK: - Factory Methods

extension AttractorForce {
    
    /// Creates a black hole attractor that kills particles at center.
    /// - Parameters:
    ///   - position: Black hole position.
    ///   - strength: Attraction strength.
    /// - Returns: A configured attractor.
    public static func blackHole(
        position: Vector2D,
        strength: Double = 1000
    ) -> AttractorForce {
        let attractor = AttractorForce(
            position: position,
            strength: strength,
            radius: 300,
            falloff: .inverseSquare
        )
        attractor.killOnReach = true
        attractor.killDistance = 10
        return attractor
    }
    
    /// Creates a gentle magnet attractor.
    /// - Parameters:
    ///   - position: Magnet position.
    ///   - strength: Attraction strength.
    /// - Returns: A configured attractor.
    public static func magnet(
        position: Vector2D,
        strength: Double = 200
    ) -> AttractorForce {
        AttractorForce(
            position: position,
            strength: strength,
            radius: 150,
            falloff: .quadratic
        )
    }
    
    /// Creates a force field that repels particles.
    /// - Parameters:
    ///   - position: Repeller position.
    ///   - strength: Repulsion strength.
    /// - Returns: A configured attractor.
    public static func repeller(
        position: Vector2D,
        strength: Double = 500
    ) -> AttractorForce {
        AttractorForce(
            position: position,
            strength: -strength,
            radius: 100,
            falloff: .inverseSquare
        )
    }
    
    /// Creates an attractor that follows the user's touch.
    /// - Parameter strength: Attraction strength.
    /// - Returns: A configured attractor.
    public static func touchFollower(strength: Double = 300) -> AttractorForce {
        AttractorForce(
            position: .zero,
            strength: strength,
            radius: 250,
            falloff: .linear
        )
    }
}
