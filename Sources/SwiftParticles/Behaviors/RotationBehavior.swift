// RotationBehavior.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - RotationBehavior

/// A behavior that controls particle rotation over its lifetime.
///
/// `RotationBehavior` can apply constant rotation, rotation based on velocity
/// direction, or complex rotation patterns. Useful for leaves, debris, or
/// any particles that should spin.
///
/// ## Usage Example
/// ```swift
/// // Constant spin
/// let spin = RotationBehavior(angularVelocity: 2.0)
///
/// // Align to velocity
/// let aligned = RotationBehavior.alignedToVelocity()
///
/// // Wobbling rotation
/// let wobble = RotationBehavior.wobbling(frequency: 3.0, amplitude: 0.5)
/// ```
public final class RotationBehavior: BaseBehavior {
    
    // MARK: - Properties
    
    /// Rotation mode to use.
    public var mode: RotationMode
    
    /// Base angular velocity in radians per second.
    public var angularVelocity: Double
    
    /// Whether angular velocity changes over lifetime.
    public var velocityOverLifetime: Bool = false
    
    /// Start angular velocity (if velocityOverLifetime is true).
    public var startAngularVelocity: Double = 0
    
    /// End angular velocity (if velocityOverLifetime is true).
    public var endAngularVelocity: Double = 0
    
    /// Whether rotation is affected by particle velocity.
    public var velocityInfluence: Double = 0
    
    /// Wobble frequency (oscillations per second).
    public var wobbleFrequency: Double = 0
    
    /// Wobble amplitude in radians.
    public var wobbleAmplitude: Double = 0
    
    /// Whether wobble dampens over lifetime.
    public var wobbleDamping: Bool = true
    
    /// Random variation in angular velocity (radians/sec).
    public var angularVariation: Double = 0
    
    /// Alignment smoothing for velocity alignment (0 = instant, 1 = very smooth).
    public var alignmentSmoothing: Double = 0.1
    
    /// Rotation offset for velocity alignment.
    public var alignmentOffset: Double = 0
    
    // MARK: - Initialization
    
    /// Creates a rotation behavior with the specified mode and velocity.
    /// - Parameters:
    ///   - mode: Rotation mode to use.
    ///   - angularVelocity: Base angular velocity in radians/sec.
    public init(
        mode: RotationMode = .constant,
        angularVelocity: Double = 0
    ) {
        self.mode = mode
        self.angularVelocity = angularVelocity
        super.init()
    }
    
    /// Creates a rotation behavior with constant angular velocity.
    /// - Parameter angularVelocity: Angular velocity in radians/sec.
    public convenience init(angularVelocity: Double) {
        self.init(mode: .constant, angularVelocity: angularVelocity)
    }
    
    // MARK: - Behavior Application
    
    public override func apply(to particle: inout Particle, deltaTime: Double) {
        guard shouldApply(to: particle) else { return }
        
        let progress = calculateProgress(for: particle)
        
        switch mode {
        case .constant:
            applyConstantRotation(to: &particle, deltaTime: deltaTime, progress: progress)
            
        case .alignToVelocity:
            applyVelocityAlignment(to: &particle, deltaTime: deltaTime)
            
        case .randomSpin:
            applyRandomSpin(to: &particle, deltaTime: deltaTime)
            
        case .oscillate:
            applyOscillation(to: &particle, progress: progress)
            
        case .custom(let rotation):
            particle.rotation = rotation(particle.normalizedAge)
        }
        
        // Apply wobble on top of any mode
        if wobbleAmplitude > 0 && wobbleFrequency > 0 {
            applyWobble(to: &particle, progress: progress)
        }
    }
    
    // MARK: - Private Methods
    
    /// Applies constant rotation.
    private func applyConstantRotation(to particle: inout Particle, deltaTime: Double, progress: Double) {
        var velocity = angularVelocity
        
        // Apply velocity over lifetime
        if velocityOverLifetime {
            velocity = startAngularVelocity + (endAngularVelocity - startAngularVelocity) * progress
        }
        
        // Apply random variation
        if angularVariation > 0 {
            velocity += Double.random(in: -angularVariation...angularVariation) * deltaTime
        }
        
        // Apply velocity influence
        if velocityInfluence > 0 {
            velocity += particle.speed * velocityInfluence * 0.01
        }
        
        particle.angularVelocity = velocity
    }
    
    /// Aligns particle rotation to its velocity direction.
    private func applyVelocityAlignment(to particle: inout Particle, deltaTime: Double) {
        guard particle.speed > 0.1 else { return }
        
        let targetAngle = atan2(particle.velocity.y, particle.velocity.x) + alignmentOffset
        
        if alignmentSmoothing > 0 {
            // Smooth interpolation to target angle
            var angleDiff = targetAngle - particle.rotation
            
            // Normalize to -π to π
            while angleDiff > .pi { angleDiff -= .pi * 2 }
            while angleDiff < -.pi { angleDiff += .pi * 2 }
            
            let smoothing = 1.0 - pow(alignmentSmoothing, deltaTime * 60)
            particle.rotation += angleDiff * smoothing
        } else {
            particle.rotation = targetAngle
        }
    }
    
    /// Applies random spinning.
    private func applyRandomSpin(to particle: inout Particle, deltaTime: Double) {
        // Use particle's existing angular velocity with some randomness
        let variation = Double.random(in: -angularVariation...angularVariation) * deltaTime
        particle.angularVelocity = angularVelocity + variation
    }
    
    /// Applies oscillating rotation.
    private func applyOscillation(to particle: inout Particle, progress: Double) {
        let baseRotation = particle.birthPosition.x * 0.01  // Unique per particle
        let oscillation = sin(progress * .pi * 2 * wobbleFrequency + baseRotation) * wobbleAmplitude
        particle.rotation = oscillation
    }
    
    /// Applies wobble effect.
    private func applyWobble(to particle: inout Particle, progress: Double) {
        var amplitude = wobbleAmplitude
        
        if wobbleDamping {
            amplitude *= (1.0 - progress)
        }
        
        let wobble = sin(particle.age * wobbleFrequency * .pi * 2) * amplitude
        particle.rotation += wobble
    }
}

// MARK: - RotationMode

/// Mode for particle rotation behavior.
public enum RotationMode: Sendable {
    /// Constant angular velocity.
    case constant
    /// Align rotation to velocity direction.
    case alignToVelocity
    /// Random spinning.
    case randomSpin
    /// Oscillating rotation.
    case oscillate
    /// Custom rotation function.
    case custom(rotation: @Sendable (Double) -> Double)
}

// MARK: - Factory Methods

extension RotationBehavior {
    
    /// Creates a behavior that aligns particles to their velocity.
    /// - Parameter offset: Rotation offset in radians.
    public static func alignedToVelocity(offset: Double = 0) -> RotationBehavior {
        let behavior = RotationBehavior(mode: .alignToVelocity)
        behavior.alignmentOffset = offset
        return behavior
    }
    
    /// Creates a constant spinning behavior.
    /// - Parameter speed: Rotations per second.
    public static func spinning(speed: Double = 1.0) -> RotationBehavior {
        RotationBehavior(angularVelocity: speed * .pi * 2)
    }
    
    /// Creates a wobbling rotation behavior.
    /// - Parameters:
    ///   - frequency: Wobble frequency.
    ///   - amplitude: Wobble amplitude in radians.
    public static func wobbling(
        frequency: Double = 3.0,
        amplitude: Double = 0.5
    ) -> RotationBehavior {
        let behavior = RotationBehavior(mode: .constant, angularVelocity: 0)
        behavior.wobbleFrequency = frequency
        behavior.wobbleAmplitude = amplitude
        return behavior
    }
    
    /// Creates a random spin behavior.
    /// - Parameter maxVelocity: Maximum angular velocity.
    public static func randomSpin(maxVelocity: Double = 5.0) -> RotationBehavior {
        let behavior = RotationBehavior(mode: .randomSpin, angularVelocity: maxVelocity)
        behavior.angularVariation = maxVelocity * 0.5
        return behavior
    }
    
    /// Creates a slowing down spin (like a coin settling).
    /// - Parameters:
    ///   - startVelocity: Initial angular velocity.
    ///   - endVelocity: Final angular velocity.
    public static func settlingDown(
        startVelocity: Double = 10.0,
        endVelocity: Double = 0.0
    ) -> RotationBehavior {
        let behavior = RotationBehavior(mode: .constant)
        behavior.velocityOverLifetime = true
        behavior.startAngularVelocity = startVelocity
        behavior.endAngularVelocity = endVelocity
        behavior.easing = .easeOut
        return behavior
    }
    
    /// Creates a pendulum-like swinging behavior.
    /// - Parameters:
    ///   - frequency: Swing frequency.
    ///   - amplitude: Maximum swing angle.
    public static func swinging(
        frequency: Double = 2.0,
        amplitude: Double = 0.8
    ) -> RotationBehavior {
        let behavior = RotationBehavior(mode: .oscillate)
        behavior.wobbleFrequency = frequency
        behavior.wobbleAmplitude = amplitude
        return behavior
    }
}

// MARK: - Builder Methods

extension RotationBehavior {
    
    /// Adds wobble to the rotation.
    /// - Parameters:
    ///   - frequency: Wobble frequency.
    ///   - amplitude: Wobble amplitude.
    ///   - damping: Whether to dampen over time.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withWobble(
        frequency: Double = 3.0,
        amplitude: Double = 0.3,
        damping: Bool = true
    ) -> Self {
        wobbleFrequency = frequency
        wobbleAmplitude = amplitude
        wobbleDamping = damping
        return self
    }
    
    /// Sets velocity influence on rotation.
    /// - Parameter influence: Influence amount.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withVelocityInfluence(_ influence: Double) -> Self {
        velocityInfluence = influence
        return self
    }
    
    /// Sets angular velocity to change over lifetime.
    /// - Parameters:
    ///   - start: Starting velocity.
    ///   - end: Ending velocity.
    /// - Returns: Self for chaining.
    @discardableResult
    public func velocityOverLifetime(start: Double, end: Double) -> Self {
        velocityOverLifetime = true
        startAngularVelocity = start
        endAngularVelocity = end
        return self
    }
}
