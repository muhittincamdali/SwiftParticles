// LineEmitter.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - LineEmitter

/// An emitter that spawns particles along a line segment.
///
/// `LineEmitter` distributes particle spawn points along a line between two points.
/// This is useful for effects like rain, waterfalls, laser beams, or edge emissions.
///
/// ## Usage Example
/// ```swift
/// let emitter = LineEmitter(
///     startPoint: Vector2D(x: 0, y: 0),
///     endPoint: Vector2D(x: 400, y: 0)
/// )
/// emitter.emissionAngle = .pi / 2  // Downward
/// emitter.start()
/// ```
public final class LineEmitter: BaseEmitter {
    
    // MARK: - Properties
    
    /// Starting point of the emission line.
    public var startPoint: Vector2D {
        didSet { updateLineProperties() }
    }
    
    /// Ending point of the emission line.
    public var endPoint: Vector2D {
        didSet { updateLineProperties() }
    }
    
    /// Distribution mode for particles along the line.
    public var distribution: LineDistribution = .uniform
    
    /// Whether particles emit perpendicular to the line.
    public var emitPerpendicular: Bool = false
    
    /// If perpendicular, emit from which side (true = both, false = one side).
    public var emitBothSides: Bool = true
    
    /// Offset distance from the line for emission.
    public var lineOffset: Double = 0
    
    /// Cached length of the line.
    private var lineLength: Double = 0
    
    /// Cached direction vector of the line.
    private var lineDirection: Vector2D = .zero
    
    /// Cached perpendicular direction.
    private var perpendicular: Vector2D = .zero
    
    // MARK: - Initialization
    
    /// Creates a line emitter between two points.
    /// - Parameters:
    ///   - startPoint: Starting point of the line.
    ///   - endPoint: Ending point of the line.
    ///   - configuration: The particle configuration.
    public init(
        startPoint: Vector2D,
        endPoint: Vector2D,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        let midPoint = (startPoint + endPoint) * 0.5
        super.init(configuration: configuration, position: midPoint)
        
        updateLineProperties()
    }
    
    /// Creates a horizontal line emitter.
    /// - Parameters:
    ///   - y: Y position of the line.
    ///   - startX: Starting X position.
    ///   - endX: Ending X position.
    ///   - configuration: The particle configuration.
    public convenience init(
        horizontalAt y: Double,
        from startX: Double,
        to endX: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.init(
            startPoint: Vector2D(x: startX, y: y),
            endPoint: Vector2D(x: endX, y: y),
            configuration: configuration
        )
    }
    
    /// Creates a vertical line emitter.
    /// - Parameters:
    ///   - x: X position of the line.
    ///   - startY: Starting Y position.
    ///   - endY: Ending Y position.
    ///   - configuration: The particle configuration.
    public convenience init(
        verticalAt x: Double,
        from startY: Double,
        to endY: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.init(
            startPoint: Vector2D(x: x, y: startY),
            endPoint: Vector2D(x: x, y: endY),
            configuration: configuration
        )
    }
    
    // MARK: - Private Methods
    
    /// Updates cached line properties.
    private func updateLineProperties() {
        let delta = endPoint - startPoint
        lineLength = delta.magnitude
        
        if lineLength > 0 {
            lineDirection = delta.normalized
            perpendicular = Vector2D(x: -lineDirection.y, y: lineDirection.x)
        } else {
            lineDirection = Vector2D(x: 1, y: 0)
            perpendicular = Vector2D(x: 0, y: 1)
        }
        
        position = (startPoint + endPoint) * 0.5
    }
    
    // MARK: - Override Methods
    
    /// Calculates the spawn position along the line.
    /// - Returns: A position on or near the line.
    public override func calculateSpawnPosition() -> Vector2D {
        let t: Double
        
        switch distribution {
        case .uniform:
            t = Double.random(in: 0...1)
        case .center:
            // Bias toward center using triangular distribution
            let u = Double.random(in: 0...1)
            let v = Double.random(in: 0...1)
            t = (u + v) / 2
        case .ends:
            // Bias toward ends
            let u = Double.random(in: 0...1)
            t = u < 0.5 ? u * u * 2 : 1 - (1 - u) * (1 - u) * 2
        case .start:
            // Bias toward start
            let u = Double.random(in: 0...1)
            t = u * u
        case .end:
            // Bias toward end
            let u = Double.random(in: 0...1)
            t = 1 - (1 - u) * (1 - u)
        case .sequential(let segments):
            // Emit sequentially through segments
            t = Double(Int.random(in: 0..<segments)) / Double(max(segments - 1, 1))
        }
        
        var spawnPos = startPoint + lineDirection * (t * lineLength)
        
        // Apply offset
        if lineOffset != 0 {
            let offsetDir = emitBothSides && Bool.random() ? -perpendicular : perpendicular
            spawnPos = spawnPos + offsetDir * lineOffset
        }
        
        return spawnPos
    }
    
    /// Calculates the initial velocity, optionally perpendicular to the line.
    /// - Returns: The initial velocity vector.
    public override func calculateInitialVelocity() -> Vector2D {
        if emitPerpendicular {
            let speed = Double.random(in: configuration.speedRange)
            let baseDir: Vector2D
            
            if emitBothSides {
                baseDir = Bool.random() ? perpendicular : -perpendicular
            } else {
                baseDir = perpendicular
            }
            
            // Add spread variation
            let spreadAngle = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
            let rotatedDir = baseDir.rotated(by: spreadAngle)
            
            return rotatedDir * speed
        } else {
            return super.calculateInitialVelocity()
        }
    }
    
    // MARK: - Line Manipulation
    
    /// Moves the entire line by an offset.
    /// - Parameter offset: The offset to apply.
    public func moveBy(_ offset: Vector2D) {
        startPoint = startPoint + offset
        endPoint = endPoint + offset
    }
    
    /// Sets the line length while keeping the center position.
    /// - Parameter newLength: The new line length.
    public func setLength(_ newLength: Double) {
        let center = (startPoint + endPoint) * 0.5
        let halfLength = newLength / 2
        startPoint = center - lineDirection * halfLength
        endPoint = center + lineDirection * halfLength
        updateLineProperties()
    }
    
    /// Rotates the line around its center.
    /// - Parameter angle: Rotation angle in radians.
    public func rotate(by angle: Double) {
        let center = (startPoint + endPoint) * 0.5
        let halfDelta = (endPoint - startPoint) * 0.5
        let rotatedHalf = halfDelta.rotated(by: angle)
        startPoint = center - rotatedHalf
        endPoint = center + rotatedHalf
        updateLineProperties()
    }
}

// MARK: - LineDistribution

/// Distribution patterns for particle emission along a line.
public enum LineDistribution: Sendable {
    /// Particles are evenly distributed along the line.
    case uniform
    /// Particles are biased toward the center.
    case center
    /// Particles are biased toward both ends.
    case ends
    /// Particles are biased toward the start point.
    case start
    /// Particles are biased toward the end point.
    case end
    /// Particles emit from discrete segments.
    case sequential(segments: Int)
}

// MARK: - LineEmitter Builder

extension LineEmitter {
    
    /// Sets the distribution mode.
    /// - Parameter distribution: The distribution pattern.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withDistribution(_ distribution: LineDistribution) -> Self {
        self.distribution = distribution
        return self
    }
    
    /// Enables perpendicular emission.
    /// - Parameter bothSides: Whether to emit from both sides.
    /// - Returns: Self for chaining.
    @discardableResult
    public func emittingPerpendicular(bothSides: Bool = true) -> Self {
        emitPerpendicular = true
        emitBothSides = bothSides
        return self
    }
    
    /// Sets the line offset.
    /// - Parameter offset: Distance from the line.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withLineOffset(_ offset: Double) -> Self {
        lineOffset = offset
        return self
    }
}
