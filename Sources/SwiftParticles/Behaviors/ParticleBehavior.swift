// ParticleBehavior.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ParticleBehavior Protocol

/// A protocol that defines a behavior that modifies particle properties over time.
///
/// Behaviors differ from forces in that they directly modify particle properties
/// (like opacity, scale, color) rather than applying physical forces. They're
/// typically driven by particle age or other state.
///
/// ## Creating Custom Behaviors
/// ```swift
/// struct PulseBehavior: ParticleBehavior {
///     var isEnabled: Bool = true
///     var frequency: Double = 2.0
///
///     func apply(to particle: inout Particle, deltaTime: Double) {
///         let pulse = sin(particle.age * frequency * .pi * 2)
///         particle.scale = 1.0 + pulse * 0.2
///     }
/// }
/// ```
public protocol ParticleBehavior: AnyObject, Sendable {
    
    /// Whether this behavior is currently active.
    var isEnabled: Bool { get set }
    
    /// Applies the behavior to a particle.
    /// - Parameters:
    ///   - particle: The particle to modify (inout).
    ///   - deltaTime: Time step in seconds.
    func apply(to particle: inout Particle, deltaTime: Double)
    
    /// Called when the behavior is added to a particle system.
    func onAttach()
    
    /// Called when the behavior is removed from a particle system.
    func onDetach()
    
    /// Resets any internal state of the behavior.
    func reset()
}

// MARK: - Default Implementations

extension ParticleBehavior {
    
    /// Default implementation - no action needed.
    public func onAttach() {}
    
    /// Default implementation - no action needed.
    public func onDetach() {}
    
    /// Default implementation - no action needed.
    public func reset() {}
}

// MARK: - BaseBehavior

/// Base class for common behavior functionality.
open class BaseBehavior: ParticleBehavior, @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Whether this behavior is active.
    public var isEnabled: Bool = true
    
    /// Easing function for the behavior.
    public var easing: EasingFunction = .linear
    
    /// Start time in normalized age (0-1) when behavior begins.
    public var startAge: Double = 0
    
    /// End time in normalized age (0-1) when behavior ends.
    public var endAge: Double = 1
    
    /// Whether to apply behavior in reverse after midpoint.
    public var pingPong: Bool = false
    
    /// Filter to only apply to certain particle shapes.
    public var shapeFilter: Set<ParticleShape>?
    
    // MARK: - Initialization
    
    /// Creates a base behavior.
    public init() {}
    
    // MARK: - Behavior Protocol
    
    /// Override in subclasses to apply behavior.
    /// - Parameters:
    ///   - particle: The particle to modify.
    ///   - deltaTime: Time step in seconds.
    open func apply(to particle: inout Particle, deltaTime: Double) {
        // Override in subclasses
    }
    
    // MARK: - Helpers
    
    /// Checks if the behavior should apply to the given particle.
    /// - Parameter particle: The particle to check.
    /// - Returns: Whether the behavior applies.
    public func shouldApply(to particle: Particle) -> Bool {
        guard isEnabled else { return false }
        
        // Age range filter
        let age = particle.normalizedAge
        guard age >= startAge && age <= endAge else { return false }
        
        // Shape filter
        if let filter = shapeFilter, !filter.contains(particle.shape) {
            return false
        }
        
        return true
    }
    
    /// Calculates the progress value for the behavior.
    /// - Parameter particle: The particle.
    /// - Returns: Progress value (0-1) with easing applied.
    public func calculateProgress(for particle: Particle) -> Double {
        let age = particle.normalizedAge
        let range = endAge - startAge
        guard range > 0 else { return 1 }
        
        var progress = (age - startAge) / range
        progress = min(max(progress, 0), 1)
        
        if pingPong {
            if progress > 0.5 {
                progress = 1 - progress
            }
            progress *= 2
        }
        
        return easing.apply(progress)
    }
}

// MARK: - EasingFunction

/// Easing functions for smooth transitions.
public enum EasingFunction: String, CaseIterable, Sendable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc
    case easeInBack
    case easeOutBack
    case easeInOutBack
    case easeInElastic
    case easeOutElastic
    case easeInBounce
    case easeOutBounce
    
    /// Applies the easing function to a value.
    /// - Parameter t: Input value (0-1).
    /// - Returns: Eased output value.
    public func apply(_ t: Double) -> Double {
        switch self {
        case .linear:
            return t
            
        case .easeIn:
            return t * t
            
        case .easeOut:
            return t * (2 - t)
            
        case .easeInOut:
            return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
            
        case .easeInQuad:
            return t * t
            
        case .easeOutQuad:
            return t * (2 - t)
            
        case .easeInOutQuad:
            return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
            
        case .easeInCubic:
            return t * t * t
            
        case .easeOutCubic:
            let t1 = t - 1
            return t1 * t1 * t1 + 1
            
        case .easeInOutCubic:
            return t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1
            
        case .easeInExpo:
            return t == 0 ? 0 : pow(2, 10 * (t - 1))
            
        case .easeOutExpo:
            return t == 1 ? 1 : 1 - pow(2, -10 * t)
            
        case .easeInOutExpo:
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return t < 0.5 ? pow(2, 20 * t - 10) / 2 : (2 - pow(2, -20 * t + 10)) / 2
            
        case .easeInCirc:
            return 1 - sqrt(1 - t * t)
            
        case .easeOutCirc:
            let t1 = t - 1
            return sqrt(1 - t1 * t1)
            
        case .easeInOutCirc:
            if t < 0.5 {
                return (1 - sqrt(1 - 4 * t * t)) / 2
            } else {
                return (sqrt(1 - pow(-2 * t + 2, 2)) + 1) / 2
            }
            
        case .easeInBack:
            let c1 = 1.70158
            return (c1 + 1) * t * t * t - c1 * t * t
            
        case .easeOutBack:
            let c1 = 1.70158
            let t1 = t - 1
            return 1 + (c1 + 1) * t1 * t1 * t1 + c1 * t1 * t1
            
        case .easeInOutBack:
            let c1 = 1.70158
            let c2 = c1 * 1.525
            if t < 0.5 {
                return (4 * t * t * ((c2 + 1) * 2 * t - c2)) / 2
            } else {
                return ((2 * t - 2) * (2 * t - 2) * ((c2 + 1) * (2 * t - 2) + c2) + 2) / 2
            }
            
        case .easeInElastic:
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * (2 * .pi / 3))
            
        case .easeOutElastic:
            if t == 0 { return 0 }
            if t == 1 { return 1 }
            return pow(2, -10 * t) * sin((t * 10 - 0.75) * (2 * .pi / 3)) + 1
            
        case .easeInBounce:
            return 1 - EasingFunction.easeOutBounce.apply(1 - t)
            
        case .easeOutBounce:
            if t < 1 / 2.75 {
                return 7.5625 * t * t
            } else if t < 2 / 2.75 {
                let t1 = t - 1.5 / 2.75
                return 7.5625 * t1 * t1 + 0.75
            } else if t < 2.5 / 2.75 {
                let t1 = t - 2.25 / 2.75
                return 7.5625 * t1 * t1 + 0.9375
            } else {
                let t1 = t - 2.625 / 2.75
                return 7.5625 * t1 * t1 + 0.984375
            }
        }
    }
}

// MARK: - CompositeBehavior

/// A behavior that combines multiple behaviors.
public final class CompositeBehavior: BaseBehavior {
    
    /// The behaviors to combine.
    public var behaviors: [any ParticleBehavior] = []
    
    /// Creates a composite behavior from multiple behaviors.
    /// - Parameter behaviors: The behaviors to combine.
    public init(behaviors: [any ParticleBehavior] = []) {
        self.behaviors = behaviors
        super.init()
    }
    
    /// Adds a behavior to the composite.
    /// - Parameter behavior: The behavior to add.
    public func add(_ behavior: any ParticleBehavior) {
        behaviors.append(behavior)
    }
    
    /// Removes all behaviors.
    public func removeAll() {
        behaviors.removeAll()
    }
    
    public override func apply(to particle: inout Particle, deltaTime: Double) {
        for behavior in behaviors where behavior.isEnabled {
            behavior.apply(to: &particle, deltaTime: deltaTime)
        }
    }
    
    public override func reset() {
        for behavior in behaviors {
            behavior.reset()
        }
    }
}
