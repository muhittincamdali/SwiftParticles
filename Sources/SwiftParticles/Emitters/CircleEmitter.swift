// CircleEmitter.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - CircleEmitter

/// An emitter that spawns particles within or on a circular area.
///
/// `CircleEmitter` can spawn particles from within a filled circle (disc),
/// on the edge of a circle (ring), or in various arc patterns. This is ideal
/// for effects like radial bursts, circular waves, or orbital patterns.
///
/// ## Usage Example
/// ```swift
/// let emitter = CircleEmitter(
///     center: Vector2D(x: 200, y: 200),
///     radius: 50
/// )
/// emitter.emissionMode = .edge
/// emitter.emitOutward = true
/// emitter.start()
/// ```
public final class CircleEmitter: BaseEmitter {
    
    // MARK: - Properties
    
    /// Center point of the emission circle.
    public var center: Vector2D {
        get { position }
        set { position = newValue }
    }
    
    /// Radius of the emission circle.
    public var radius: Double {
        didSet { radius = max(0, radius) }
    }
    
    /// Inner radius for ring/donut emission. Set to 0 for full disc.
    public var innerRadius: Double = 0 {
        didSet { innerRadius = max(0, min(innerRadius, radius)) }
    }
    
    /// How particles are distributed within the circle.
    public var emissionMode: CircleEmissionMode = .filled
    
    /// Whether particles emit radially outward from center.
    public var emitOutward: Bool = false
    
    /// Whether particles emit radially inward toward center.
    public var emitInward: Bool = false
    
    /// Arc start angle in radians (0 = right, counter-clockwise).
    public var arcStartAngle: Double = 0
    
    /// Arc end angle in radians.
    public var arcEndAngle: Double = .pi * 2
    
    /// Whether to use tangential emission direction.
    public var emitTangential: Bool = false
    
    /// Direction of tangential emission (1 = counter-clockwise, -1 = clockwise).
    public var tangentialDirection: Double = 1
    
    /// Angular velocity for rotating emission point.
    public var angularVelocity: Double = 0
    
    /// Current rotation angle for animated emission.
    private var currentAngle: Double = 0
    
    // MARK: - Computed Properties
    
    /// The arc angle span.
    public var arcSpan: Double {
        var span = arcEndAngle - arcStartAngle
        while span < 0 { span += .pi * 2 }
        while span > .pi * 2 { span -= .pi * 2 }
        return span
    }
    
    /// Whether this is a full circle (360 degrees).
    public var isFullCircle: Bool {
        abs(arcSpan - .pi * 2) < 0.001
    }
    
    // MARK: - Initialization
    
    /// Creates a circle emitter with the specified properties.
    /// - Parameters:
    ///   - center: Center point of the circle.
    ///   - radius: Radius of the circle.
    ///   - configuration: The particle configuration.
    public init(
        center: Vector2D,
        radius: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.radius = max(0, radius)
        super.init(configuration: configuration, position: center)
    }
    
    /// Creates a ring emitter (particles on edge only).
    /// - Parameters:
    ///   - center: Center point.
    ///   - radius: Radius of the ring.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured circle emitter.
    public static func ring(
        center: Vector2D,
        radius: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CircleEmitter {
        let emitter = CircleEmitter(center: center, radius: radius, configuration: configuration)
        emitter.emissionMode = .edge
        return emitter
    }
    
    /// Creates a disc emitter (particles fill the area).
    /// - Parameters:
    ///   - center: Center point.
    ///   - radius: Radius of the disc.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured circle emitter.
    public static func disc(
        center: Vector2D,
        radius: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CircleEmitter {
        let emitter = CircleEmitter(center: center, radius: radius, configuration: configuration)
        emitter.emissionMode = .filled
        return emitter
    }
    
    /// Creates an arc emitter.
    /// - Parameters:
    ///   - center: Center point.
    ///   - radius: Radius.
    ///   - startAngle: Arc start angle in radians.
    ///   - endAngle: Arc end angle in radians.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured circle emitter.
    public static func arc(
        center: Vector2D,
        radius: Double,
        startAngle: Double,
        endAngle: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CircleEmitter {
        let emitter = CircleEmitter(center: center, radius: radius, configuration: configuration)
        emitter.emissionMode = .edge
        emitter.arcStartAngle = startAngle
        emitter.arcEndAngle = endAngle
        return emitter
    }
    
    // MARK: - Override Methods
    
    /// Calculates the spawn position within or on the circle.
    /// - Returns: The spawn position.
    public override func calculateSpawnPosition() -> Vector2D {
        let angle = randomAngleInArc()
        let distance: Double
        
        switch emissionMode {
        case .filled:
            // Uniform distribution within disc
            let r = sqrt(Double.random(in: 0...1))
            distance = innerRadius + r * (radius - innerRadius)
        case .edge:
            distance = radius
        case .ring:
            distance = Double.random(in: innerRadius...radius)
        case .center:
            // Bias toward center
            let r = Double.random(in: 0...1)
            distance = innerRadius + (1 - r * r) * (radius - innerRadius) * 0.5
        case .weighted(let exponent):
            // Custom distribution
            let r = pow(Double.random(in: 0...1), exponent)
            distance = innerRadius + r * (radius - innerRadius)
        }
        
        return center + Vector2D(
            x: cos(angle) * distance,
            y: sin(angle) * distance
        )
    }
    
    /// Calculates the initial velocity with optional radial/tangential components.
    /// - Returns: The initial velocity vector.
    public override func calculateInitialVelocity() -> Vector2D {
        let angle = randomAngleInArc()
        let speed = Double.random(in: configuration.speedRange)
        
        if emitOutward {
            // Radial outward
            let radialDir = Vector2D(x: cos(angle), y: sin(angle))
            let spread = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
            return radialDir.rotated(by: spread) * speed
            
        } else if emitInward {
            // Radial inward
            let radialDir = Vector2D(x: -cos(angle), y: -sin(angle))
            let spread = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
            return radialDir.rotated(by: spread) * speed
            
        } else if emitTangential {
            // Tangential to circle
            let tangentDir = Vector2D(
                x: -sin(angle) * tangentialDirection,
                y: cos(angle) * tangentialDirection
            )
            let spread = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
            return tangentDir.rotated(by: spread) * speed
            
        } else {
            return super.calculateInitialVelocity()
        }
    }
    
    /// Updates the emitter, including rotation animation.
    /// - Parameters:
    ///   - deltaTime: Time elapsed.
    ///   - currentCount: Current particle count.
    /// - Returns: Newly spawned particles.
    public override func update(deltaTime: Double, currentCount: Int) -> [Particle] {
        if angularVelocity != 0 {
            currentAngle += angularVelocity * deltaTime
            while currentAngle > .pi * 2 { currentAngle -= .pi * 2 }
            while currentAngle < 0 { currentAngle += .pi * 2 }
        }
        
        return super.update(deltaTime: deltaTime, currentCount: currentCount)
    }
    
    // MARK: - Private Methods
    
    /// Generates a random angle within the arc.
    /// - Returns: An angle in radians.
    private func randomAngleInArc() -> Double {
        if angularVelocity != 0 {
            return currentAngle
        }
        
        let span = arcEndAngle - arcStartAngle
        return arcStartAngle + Double.random(in: 0...1) * span
    }
}

// MARK: - CircleEmissionMode

/// How particles are distributed within a circle emitter.
public enum CircleEmissionMode: Sendable {
    /// Particles uniformly fill the circle.
    case filled
    /// Particles only appear on the edge.
    case edge
    /// Particles appear between inner and outer radius.
    case ring
    /// Particles are biased toward the center.
    case center
    /// Custom weighted distribution (exponent controls bias).
    case weighted(exponent: Double)
}

// MARK: - CircleEmitter Builder

extension CircleEmitter {
    
    /// Sets the inner radius for donut/ring emission.
    /// - Parameter radius: Inner radius.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withInnerRadius(_ radius: Double) -> Self {
        innerRadius = radius
        return self
    }
    
    /// Sets the emission mode.
    /// - Parameter mode: The emission mode.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withEmissionMode(_ mode: CircleEmissionMode) -> Self {
        emissionMode = mode
        return self
    }
    
    /// Enables outward radial emission.
    /// - Returns: Self for chaining.
    @discardableResult
    public func emittingOutward() -> Self {
        emitOutward = true
        emitInward = false
        emitTangential = false
        return self
    }
    
    /// Enables inward radial emission.
    /// - Returns: Self for chaining.
    @discardableResult
    public func emittingInward() -> Self {
        emitInward = true
        emitOutward = false
        emitTangential = false
        return self
    }
    
    /// Enables tangential emission.
    /// - Parameter clockwise: Whether to emit clockwise.
    /// - Returns: Self for chaining.
    @discardableResult
    public func emittingTangential(clockwise: Bool = false) -> Self {
        emitTangential = true
        emitOutward = false
        emitInward = false
        tangentialDirection = clockwise ? -1 : 1
        return self
    }
    
    /// Sets the arc range.
    /// - Parameters:
    ///   - start: Start angle in radians.
    ///   - end: End angle in radians.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withArc(from start: Double, to end: Double) -> Self {
        arcStartAngle = start
        arcEndAngle = end
        return self
    }
    
    /// Sets angular velocity for rotating emission.
    /// - Parameter velocity: Angular velocity in radians per second.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withAngularVelocity(_ velocity: Double) -> Self {
        angularVelocity = velocity
        return self
    }
}
