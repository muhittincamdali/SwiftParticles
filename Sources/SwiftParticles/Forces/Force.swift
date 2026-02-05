// Force.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - Force Protocol

/// A protocol that defines a force that can be applied to particles.
///
/// Forces modify particle acceleration based on various factors like
/// position, velocity, time, or particle properties. Implement this
/// protocol to create custom force behaviors.
///
/// ## Creating Custom Forces
/// ```swift
/// struct CustomForce: Force {
///     var isEnabled: Bool = true
///     var strength: Double = 100
///
///     func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
///         // Your force calculation
///         return Vector2D(x: 0, y: -strength)
///     }
/// }
/// ```
public protocol Force: AnyObject, Sendable {
    
    /// Whether this force is currently active.
    var isEnabled: Bool { get set }
    
    /// The strength multiplier for this force.
    var strength: Double { get set }
    
    /// Calculates the force vector to apply to a particle.
    /// - Parameters:
    ///   - particle: The particle to calculate force for.
    ///   - deltaTime: Time step in seconds.
    /// - Returns: The force vector to apply.
    func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D
    
    /// Called when the force is added to a particle system.
    func onAttach()
    
    /// Called when the force is removed from a particle system.
    func onDetach()
    
    /// Resets any internal state of the force.
    func reset()
}

// MARK: - Default Implementations

extension Force {
    
    /// Default implementation - no action needed.
    public func onAttach() {}
    
    /// Default implementation - no action needed.
    public func onDetach() {}
    
    /// Default implementation - no action needed.
    public func reset() {}
}

// MARK: - BaseForce

/// Base class for common force functionality.
///
/// Extend this class to create custom forces with shared behaviors.
open class BaseForce: Force, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Whether this force is active.
    public var isEnabled: Bool = true
    
    /// Strength multiplier for this force.
    public var strength: Double
    
    /// Optional bounds to limit where the force applies.
    public var bounds: CGRect?
    
    /// Whether the force fades at the edges of bounds.
    public var fadeAtBounds: Bool = false
    
    /// Fade distance from bounds edges.
    public var fadeDistance: Double = 50
    
    /// Minimum particle age for force to apply.
    public var minAge: Double = 0
    
    /// Maximum particle age for force to apply.
    public var maxAge: Double = .infinity
    
    /// Filter to only apply to certain particle shapes.
    public var shapeFilter: Set<ParticleShape>?
    
    // MARK: - Initialization
    
    /// Creates a base force with the specified strength.
    /// - Parameter strength: The force strength.
    public init(strength: Double = 100) {
        self.strength = strength
    }
    
    // MARK: - Force Protocol
    
    /// Override in subclasses to provide force calculation.
    /// - Parameters:
    ///   - particle: The particle.
    ///   - deltaTime: Time step.
    /// - Returns: The force vector.
    open func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        return .zero
    }
    
    // MARK: - Helpers
    
    /// Checks if the force should apply to the given particle.
    /// - Parameter particle: The particle to check.
    /// - Returns: Whether the force applies.
    public func shouldApply(to particle: Particle) -> Bool {
        guard isEnabled else { return false }
        
        // Age filter
        guard particle.age >= minAge && particle.age <= maxAge else {
            return false
        }
        
        // Shape filter
        if let filter = shapeFilter, !filter.contains(particle.shape) {
            return false
        }
        
        // Bounds check
        if let bounds = bounds {
            guard bounds.contains(CGPoint(x: particle.position.x, y: particle.position.y)) else {
                return false
            }
        }
        
        return true
    }
    
    /// Calculates a fade multiplier based on distance from bounds.
    /// - Parameter particle: The particle.
    /// - Returns: Multiplier from 0 to 1.
    public func boundsFadeMultiplier(for particle: Particle) -> Double {
        guard let bounds = bounds, fadeAtBounds, fadeDistance > 0 else {
            return 1.0
        }
        
        let pos = particle.position
        
        // Calculate distance to nearest edge
        let distLeft = pos.x - bounds.minX
        let distRight = bounds.maxX - pos.x
        let distTop = pos.y - bounds.minY
        let distBottom = bounds.maxY - pos.y
        
        let minDist = min(distLeft, distRight, distTop, distBottom)
        
        if minDist >= fadeDistance {
            return 1.0
        } else if minDist <= 0 {
            return 0.0
        } else {
            return minDist / fadeDistance
        }
    }
}

// MARK: - CompositeForce

/// A force that combines multiple forces into one.
public final class CompositeForce: BaseForce {
    
    /// The forces to combine.
    public var forces: [any Force] = []
    
    /// How forces are combined.
    public var combinationMode: ForceCombinationMode = .add
    
    /// Creates a composite force from multiple forces.
    /// - Parameter forces: The forces to combine.
    public init(forces: [any Force] = []) {
        self.forces = forces
        super.init(strength: 1.0)
    }
    
    /// Adds a force to the composite.
    /// - Parameter force: The force to add.
    public func add(_ force: any Force) {
        forces.append(force)
    }
    
    /// Removes a force from the composite.
    /// - Parameter index: Index of force to remove.
    public func remove(at index: Int) {
        guard index >= 0 && index < forces.count else { return }
        forces.remove(at: index)
    }
    
    /// Removes all forces.
    public func removeAll() {
        forces.removeAll()
    }
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard shouldApply(to: particle) else { return .zero }
        
        var result: Vector2D = .zero
        var count = 0
        
        for force in forces where force.isEnabled {
            let forceVector = force.calculateForce(for: particle, deltaTime: deltaTime)
            
            switch combinationMode {
            case .add:
                result = result + forceVector
            case .average:
                result = result + forceVector
                count += 1
            case .max:
                if forceVector.magnitude > result.magnitude {
                    result = forceVector
                }
            case .min:
                if count == 0 || forceVector.magnitude < result.magnitude {
                    result = forceVector
                }
                count += 1
            case .multiply:
                if count == 0 {
                    result = forceVector
                } else {
                    result = Vector2D(
                        x: result.x * forceVector.x,
                        y: result.y * forceVector.y
                    )
                }
                count += 1
            }
        }
        
        if case .average = combinationMode, count > 0 {
            result = result / Double(count)
        }
        
        return result * strength
    }
    
    public func reset() {
        for force in forces {
            force.reset()
        }
    }
}

// MARK: - ForceCombinationMode

/// How multiple forces are combined in a CompositeForce.
public enum ForceCombinationMode: String, CaseIterable, Sendable {
    /// Forces are added together.
    case add
    /// Forces are averaged.
    case average
    /// The strongest force is used.
    case max
    /// The weakest force is used.
    case min
    /// Forces are multiplied component-wise.
    case multiply
}

// MARK: - TimedForce

/// A force that only applies during a specific time window.
public final class TimedForce: BaseForce {
    
    /// The underlying force to apply.
    public var wrappedForce: any Force
    
    /// Start time in seconds.
    public var startTime: Double
    
    /// End time in seconds.
    public var endTime: Double
    
    /// Current elapsed time.
    private var currentTime: Double = 0
    
    /// Creates a timed force.
    /// - Parameters:
    ///   - force: The force to wrap.
    ///   - startTime: When to start applying.
    ///   - endTime: When to stop applying.
    public init(force: any Force, startTime: Double, endTime: Double) {
        self.wrappedForce = force
        self.startTime = startTime
        self.endTime = endTime
        super.init(strength: 1.0)
    }
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        currentTime += deltaTime
        
        guard currentTime >= startTime && currentTime <= endTime else {
            return .zero
        }
        
        return wrappedForce.calculateForce(for: particle, deltaTime: deltaTime) * strength
    }
    
    public func reset() {
        currentTime = 0
        wrappedForce.reset()
    }
}

// MARK: - ConditionalForce

/// A force that applies based on a condition.
public final class ConditionalForce: BaseForce {
    
    /// The underlying force to apply.
    public var wrappedForce: any Force
    
    /// Condition that determines if force applies.
    public var condition: @Sendable (Particle) -> Bool
    
    /// Creates a conditional force.
    /// - Parameters:
    ///   - force: The force to wrap.
    ///   - condition: The condition to check.
    public init(
        force: any Force,
        condition: @escaping @Sendable (Particle) -> Bool
    ) {
        self.wrappedForce = force
        self.condition = condition
        super.init(strength: 1.0)
    }
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard condition(particle) else { return .zero }
        return wrappedForce.calculateForce(for: particle, deltaTime: deltaTime) * strength
    }
    
    public func reset() {
        wrappedForce.reset()
    }
}
