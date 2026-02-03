// VortexForce.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - VortexForce

/// A force that creates a swirling vortex effect around a point.
///
/// `VortexForce` applies tangential force to particles, making them orbit
/// around a center point. This creates whirlpool, tornado, and spiral effects.
/// Can be combined with radial forces for complex behaviors.
///
/// ## Usage Example
/// ```swift
/// // Simple vortex
/// let vortex = VortexForce(
///     center: Vector2D(x: 200, y: 200),
///     strength: 200
/// )
///
/// // Tornado with inward pull
/// let tornado = VortexForce.tornado(
///     center: Vector2D(x: 200, y: 400),
///     strength: 300
/// )
/// ```
public final class VortexForce: BaseForce {
    
    // MARK: - Properties
    
    /// Center of the vortex.
    public var center: Vector2D
    
    /// Radius of influence.
    public var radius: Double
    
    /// Inner radius where force is at maximum (eye of the storm).
    public var innerRadius: Double = 0
    
    /// Direction of rotation (positive = counter-clockwise, negative = clockwise).
    public var rotationDirection: Double = 1
    
    /// How force varies with distance from center.
    public var falloff: VortexFalloff
    
    /// Radial force component (positive = outward, negative = inward).
    public var radialStrength: Double = 0
    
    /// Vertical force component (for 3D-like effects).
    public var verticalStrength: Double = 0
    
    /// How tangential speed varies with radius.
    public var tangentialProfile: TangentialProfile = .constant
    
    /// Angular velocity of the vortex itself (rotating force field).
    public var angularVelocity: Double = 0
    
    /// Current rotation angle.
    private var currentAngle: Double = 0
    
    /// Turbulence added to the vortex.
    public var turbulence: Double = 0
    
    /// Turbulence frequency.
    public var turbulenceFrequency: Double = 1.0
    
    // MARK: - Initialization
    
    /// Creates a vortex force at the specified center.
    /// - Parameters:
    ///   - center: Center of the vortex.
    ///   - strength: Tangential force strength.
    ///   - radius: Maximum radius of influence.
    ///   - falloff: How force diminishes with distance.
    public init(
        center: Vector2D,
        strength: Double = 200,
        radius: Double = 200,
        falloff: VortexFalloff = .linear
    ) {
        self.center = center
        self.radius = radius
        self.falloff = falloff
        super.init(strength: strength)
    }
    
    // MARK: - Force Calculation
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard shouldApply(to: particle) else { return .zero }
        
        // Update vortex rotation
        if angularVelocity != 0 {
            currentAngle += angularVelocity * deltaTime
        }
        
        // Calculate relative position
        let relativePos = particle.position - center
        let distance = relativePos.magnitude
        
        // Check if within radius
        guard distance > 0 && distance <= radius else { return .zero }
        
        // Check inner radius (eye of the storm)
        guard distance >= innerRadius else { return .zero }
        
        // Calculate effective distance for falloff
        let effectiveRadius = radius - innerRadius
        let effectiveDistance = distance - innerRadius
        let normalizedDistance = effectiveDistance / effectiveRadius
        
        // Calculate falloff multiplier
        let falloffMultiplier: Double
        
        switch falloff {
        case .none:
            falloffMultiplier = 1.0
            
        case .linear:
            falloffMultiplier = 1.0 - normalizedDistance
            
        case .quadratic:
            falloffMultiplier = (1.0 - normalizedDistance) * (1.0 - normalizedDistance)
            
        case .inverse:
            falloffMultiplier = innerRadius > 0 ? innerRadius / distance : 1.0 / max(distance, 1)
            
        case .realistic:
            // Rankine vortex model: constant inside core, 1/r outside
            let coreRadius = innerRadius + effectiveRadius * 0.3
            if distance < coreRadius {
                falloffMultiplier = distance / coreRadius
            } else {
                falloffMultiplier = coreRadius / distance
            }
        }
        
        // Calculate tangential profile
        let tangentialMultiplier: Double
        
        switch tangentialProfile {
        case .constant:
            tangentialMultiplier = 1.0
            
        case .increasingOutward:
            tangentialMultiplier = normalizedDistance
            
        case .decreasingOutward:
            tangentialMultiplier = 1.0 - normalizedDistance
            
        case .peakAtMiddle:
            tangentialMultiplier = sin(normalizedDistance * .pi)
        }
        
        // Calculate tangential direction (perpendicular to radius)
        let angle = atan2(relativePos.y, relativePos.x)
        let tangentAngle = angle + (.pi / 2) * rotationDirection + currentAngle
        let tangentDir = Vector2D(x: cos(tangentAngle), y: sin(tangentAngle))
        
        // Calculate tangential force
        var force = tangentDir * strength * falloffMultiplier * tangentialMultiplier
        
        // Add radial component
        if radialStrength != 0 {
            let radialDir = relativePos.normalized
            let radialForce = radialDir * radialStrength * falloffMultiplier
            force = force + radialForce
        }
        
        // Add vertical component (simulates 3D funnel)
        if verticalStrength != 0 {
            let verticalForce = Vector2D(x: 0, y: verticalStrength * falloffMultiplier)
            force = force + verticalForce
        }
        
        // Add turbulence
        if turbulence > 0 {
            let noiseX = sin(particle.position.x * turbulenceFrequency + particle.age * 2) * turbulence
            let noiseY = cos(particle.position.y * turbulenceFrequency + particle.age * 2) * turbulence
            force = force + Vector2D(x: noiseX, y: noiseY)
        }
        
        // Apply bounds fade
        let fadeMult = boundsFadeMultiplier(for: particle)
        
        return force * fadeMult
    }
    
    // MARK: - Configuration
    
    /// Sets the vortex to rotate clockwise.
    /// - Returns: Self for chaining.
    @discardableResult
    public func clockwise() -> Self {
        rotationDirection = -1
        return self
    }
    
    /// Sets the vortex to rotate counter-clockwise.
    /// - Returns: Self for chaining.
    @discardableResult
    public func counterClockwise() -> Self {
        rotationDirection = 1
        return self
    }
    
    /// Adds a radial force component.
    /// - Parameter strength: Radial force (positive = outward, negative = inward).
    /// - Returns: Self for chaining.
    @discardableResult
    public func withRadialForce(_ strength: Double) -> Self {
        radialStrength = strength
        return self
    }
    
    /// Adds a vertical force component.
    /// - Parameter strength: Vertical force strength.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withVerticalForce(_ strength: Double) -> Self {
        verticalStrength = strength
        return self
    }
    
    /// Sets the inner radius (eye of the storm).
    /// - Parameter radius: Inner radius.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withInnerRadius(_ radius: Double) -> Self {
        innerRadius = max(0, radius)
        return self
    }
    
    /// Adds turbulence to the vortex.
    /// - Parameters:
    ///   - amount: Turbulence strength.
    ///   - frequency: Turbulence frequency.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withTurbulence(_ amount: Double, frequency: Double = 1.0) -> Self {
        turbulence = amount
        turbulenceFrequency = frequency
        return self
    }
    
    /// Makes the vortex rotate over time.
    /// - Parameter velocity: Angular velocity in radians/sec.
    /// - Returns: Self for chaining.
    @discardableResult
    public func rotating(velocity: Double) -> Self {
        angularVelocity = velocity
        return self
    }
    
    public override func reset() {
        currentAngle = 0
    }
}

// MARK: - VortexFalloff

/// How a vortex's force varies with distance from center.
public enum VortexFalloff: Sendable {
    /// Constant force throughout.
    case none
    /// Force decreases linearly toward the edge.
    case linear
    /// Force decreases quadratically toward the edge.
    case quadratic
    /// Force is proportional to 1/distance.
    case inverse
    /// Realistic Rankine vortex model.
    case realistic
}

// MARK: - TangentialProfile

/// How tangential velocity varies with radius.
public enum TangentialProfile: Sendable {
    /// Constant tangential speed.
    case constant
    /// Speed increases toward the edge.
    case increasingOutward
    /// Speed decreases toward the edge.
    case decreasingOutward
    /// Speed peaks in the middle.
    case peakAtMiddle
}

// MARK: - Factory Methods

extension VortexForce {
    
    /// Creates a whirlpool vortex with inward pull.
    /// - Parameters:
    ///   - center: Whirlpool center.
    ///   - strength: Rotation strength.
    /// - Returns: A configured vortex.
    public static func whirlpool(
        center: Vector2D,
        strength: Double = 200
    ) -> VortexForce {
        let vortex = VortexForce(center: center, strength: strength, radius: 200, falloff: .realistic)
        vortex.radialStrength = -50
        vortex.innerRadius = 10
        return vortex
    }
    
    /// Creates a tornado vortex with upward pull.
    /// - Parameters:
    ///   - center: Tornado center.
    ///   - strength: Rotation strength.
    /// - Returns: A configured vortex.
    public static func tornado(
        center: Vector2D,
        strength: Double = 300
    ) -> VortexForce {
        let vortex = VortexForce(center: center, strength: strength, radius: 150, falloff: .realistic)
        vortex.radialStrength = -30
        vortex.verticalStrength = -100
        vortex.turbulence = 20
        return vortex
    }
    
    /// Creates a gentle spiral vortex.
    /// - Parameters:
    ///   - center: Spiral center.
    ///   - strength: Rotation strength.
    /// - Returns: A configured vortex.
    public static func spiral(
        center: Vector2D,
        strength: Double = 100
    ) -> VortexForce {
        let vortex = VortexForce(center: center, strength: strength, radius: 300, falloff: .linear)
        vortex.tangentialProfile = .increasingOutward
        return vortex
    }
    
    /// Creates an outward spinning vortex.
    /// - Parameters:
    ///   - center: Vortex center.
    ///   - strength: Rotation strength.
    /// - Returns: A configured vortex.
    public static func centrifuge(
        center: Vector2D,
        strength: Double = 200
    ) -> VortexForce {
        let vortex = VortexForce(center: center, strength: strength, radius: 250, falloff: .quadratic)
        vortex.radialStrength = 100
        return vortex
    }
}
