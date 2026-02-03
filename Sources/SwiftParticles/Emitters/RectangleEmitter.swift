// RectangleEmitter.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - RectangleEmitter

/// An emitter that spawns particles within or on a rectangular area.
///
/// `RectangleEmitter` can emit particles from within a filled rectangle,
/// along its edges, or from its corners. This is useful for effects like
/// screen-wide snow, edge-based flames, or corner-burst effects.
///
/// ## Usage Example
/// ```swift
/// let emitter = RectangleEmitter(
///     rect: CGRect(x: 0, y: 0, width: 400, height: 600)
/// )
/// emitter.emissionMode = .topEdge
/// emitter.start()
/// ```
public final class RectangleEmitter: BaseEmitter {
    
    // MARK: - Properties
    
    /// The rectangle defining the emission area.
    public var rect: CGRect {
        didSet { updateCenterPosition() }
    }
    
    /// How particles are distributed within the rectangle.
    public var emissionMode: RectangleEmissionMode = .filled
    
    /// Whether to emit perpendicular to edges when using edge modes.
    public var emitPerpendicular: Bool = false
    
    /// Whether perpendicular emission goes inward (true) or outward (false).
    public var emitInward: Bool = true
    
    /// Inset from edges for edge emission (creates a margin).
    public var edgeInset: Double = 0
    
    /// Corner radius for rounded rectangle emission.
    public var cornerRadius: Double = 0
    
    /// Grid columns for grid emission mode.
    public var gridColumns: Int = 4
    
    /// Grid rows for grid emission mode.
    public var gridRows: Int = 4
    
    /// Noise applied to grid positions.
    public var gridNoise: Double = 0
    
    // MARK: - Computed Properties
    
    /// Width of the rectangle.
    public var width: Double { rect.width }
    
    /// Height of the rectangle.
    public var height: Double { rect.height }
    
    /// Top-left corner position.
    public var topLeft: Vector2D {
        Vector2D(x: rect.minX, y: rect.minY)
    }
    
    /// Top-right corner position.
    public var topRight: Vector2D {
        Vector2D(x: rect.maxX, y: rect.minY)
    }
    
    /// Bottom-left corner position.
    public var bottomLeft: Vector2D {
        Vector2D(x: rect.minX, y: rect.maxY)
    }
    
    /// Bottom-right corner position.
    public var bottomRight: Vector2D {
        Vector2D(x: rect.maxX, y: rect.maxY)
    }
    
    // MARK: - Initialization
    
    /// Creates a rectangle emitter with the specified rectangle.
    /// - Parameters:
    ///   - rect: The emission rectangle.
    ///   - configuration: The particle configuration.
    public init(
        rect: CGRect,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.rect = rect
        let center = Vector2D(
            x: rect.midX,
            y: rect.midY
        )
        super.init(configuration: configuration, position: center)
    }
    
    /// Creates a rectangle emitter with explicit bounds.
    /// - Parameters:
    ///   - x: X origin.
    ///   - y: Y origin.
    ///   - width: Rectangle width.
    ///   - height: Rectangle height.
    ///   - configuration: The particle configuration.
    public convenience init(
        x: Double,
        y: Double,
        width: Double,
        height: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.init(
            rect: CGRect(x: x, y: y, width: width, height: height),
            configuration: configuration
        )
    }
    
    /// Creates a rectangle emitter centered at a point.
    /// - Parameters:
    ///   - center: Center point.
    ///   - size: Size of the rectangle.
    ///   - configuration: The particle configuration.
    public convenience init(
        center: Vector2D,
        size: CGSize,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        let rect = CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
        self.init(rect: rect, configuration: configuration)
    }
    
    // MARK: - Private Methods
    
    /// Updates the center position based on rect.
    private func updateCenterPosition() {
        position = Vector2D(x: rect.midX, y: rect.midY)
    }
    
    // MARK: - Override Methods
    
    /// Calculates the spawn position within or on the rectangle.
    /// - Returns: The spawn position.
    public override func calculateSpawnPosition() -> Vector2D {
        let insetRect = rect.insetBy(dx: edgeInset, dy: edgeInset)
        
        switch emissionMode {
        case .filled:
            return Vector2D(
                x: Double.random(in: insetRect.minX...insetRect.maxX),
                y: Double.random(in: insetRect.minY...insetRect.maxY)
            )
            
        case .edges:
            return randomPointOnEdges(insetRect)
            
        case .topEdge:
            return Vector2D(
                x: Double.random(in: insetRect.minX...insetRect.maxX),
                y: insetRect.minY
            )
            
        case .bottomEdge:
            return Vector2D(
                x: Double.random(in: insetRect.minX...insetRect.maxX),
                y: insetRect.maxY
            )
            
        case .leftEdge:
            return Vector2D(
                x: insetRect.minX,
                y: Double.random(in: insetRect.minY...insetRect.maxY)
            )
            
        case .rightEdge:
            return Vector2D(
                x: insetRect.maxX,
                y: Double.random(in: insetRect.minY...insetRect.maxY)
            )
            
        case .corners:
            let corners = [topLeft, topRight, bottomLeft, bottomRight]
            return corners[Int.random(in: 0..<4)]
            
        case .grid:
            return randomGridPoint(in: insetRect)
            
        case .border(let thickness):
            return randomPointInBorder(insetRect, thickness: thickness)
        }
    }
    
    /// Calculates initial velocity with optional perpendicular emission.
    /// - Returns: The initial velocity vector.
    public override func calculateInitialVelocity() -> Vector2D {
        guard emitPerpendicular else {
            return super.calculateInitialVelocity()
        }
        
        let speed = Double.random(in: configuration.speedRange)
        let direction: Vector2D
        
        switch emissionMode {
        case .topEdge:
            direction = emitInward ? Vector2D(x: 0, y: 1) : Vector2D(x: 0, y: -1)
        case .bottomEdge:
            direction = emitInward ? Vector2D(x: 0, y: -1) : Vector2D(x: 0, y: 1)
        case .leftEdge:
            direction = emitInward ? Vector2D(x: 1, y: 0) : Vector2D(x: -1, y: 0)
        case .rightEdge:
            direction = emitInward ? Vector2D(x: -1, y: 0) : Vector2D(x: 1, y: 0)
        default:
            return super.calculateInitialVelocity()
        }
        
        let spread = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
        return direction.rotated(by: spread) * speed
    }
    
    // MARK: - Private Helpers
    
    /// Generates a random point on the rectangle edges.
    private func randomPointOnEdges(_ rect: CGRect) -> Vector2D {
        let perimeter = 2 * rect.width + 2 * rect.height
        var distance = Double.random(in: 0..<perimeter)
        
        // Top edge
        if distance < rect.width {
            return Vector2D(x: rect.minX + distance, y: rect.minY)
        }
        distance -= rect.width
        
        // Right edge
        if distance < rect.height {
            return Vector2D(x: rect.maxX, y: rect.minY + distance)
        }
        distance -= rect.height
        
        // Bottom edge
        if distance < rect.width {
            return Vector2D(x: rect.maxX - distance, y: rect.maxY)
        }
        distance -= rect.width
        
        // Left edge
        return Vector2D(x: rect.minX, y: rect.maxY - distance)
    }
    
    /// Generates a random grid point.
    private func randomGridPoint(in rect: CGRect) -> Vector2D {
        let col = Int.random(in: 0..<gridColumns)
        let row = Int.random(in: 0..<gridRows)
        
        let cellWidth = rect.width / Double(gridColumns)
        let cellHeight = rect.height / Double(gridRows)
        
        var x = rect.minX + (Double(col) + 0.5) * cellWidth
        var y = rect.minY + (Double(row) + 0.5) * cellHeight
        
        if gridNoise > 0 {
            x += Double.random(in: -gridNoise...gridNoise)
            y += Double.random(in: -gridNoise...gridNoise)
        }
        
        return Vector2D(x: x, y: y)
    }
    
    /// Generates a random point within the border area.
    private func randomPointInBorder(_ rect: CGRect, thickness: Double) -> Vector2D {
        let innerRect = rect.insetBy(dx: thickness, dy: thickness)
        
        // Generate point in outer rect, retry if in inner rect
        var point: Vector2D
        repeat {
            point = Vector2D(
                x: Double.random(in: rect.minX...rect.maxX),
                y: Double.random(in: rect.minY...rect.maxY)
            )
        } while innerRect.contains(CGPoint(x: point.x, y: point.y))
        
        return point
    }
}

// MARK: - RectangleEmissionMode

/// How particles are distributed within a rectangle emitter.
public enum RectangleEmissionMode: Sendable {
    /// Particles uniformly fill the rectangle.
    case filled
    /// Particles appear on all edges.
    case edges
    /// Particles appear on the top edge only.
    case topEdge
    /// Particles appear on the bottom edge only.
    case bottomEdge
    /// Particles appear on the left edge only.
    case leftEdge
    /// Particles appear on the right edge only.
    case rightEdge
    /// Particles appear at corners only.
    case corners
    /// Particles appear at grid intersections.
    case grid
    /// Particles appear within a border thickness.
    case border(thickness: Double)
}

// MARK: - RectangleEmitter Builder

extension RectangleEmitter {
    
    /// Sets the emission mode.
    /// - Parameter mode: The emission mode.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withEmissionMode(_ mode: RectangleEmissionMode) -> Self {
        emissionMode = mode
        return self
    }
    
    /// Enables perpendicular emission from edges.
    /// - Parameter inward: Whether to emit inward.
    /// - Returns: Self for chaining.
    @discardableResult
    public func emittingPerpendicular(inward: Bool = true) -> Self {
        emitPerpendicular = true
        emitInward = inward
        return self
    }
    
    /// Sets the edge inset.
    /// - Parameter inset: Inset distance from edges.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withEdgeInset(_ inset: Double) -> Self {
        edgeInset = inset
        return self
    }
    
    /// Configures grid emission.
    /// - Parameters:
    ///   - columns: Number of columns.
    ///   - rows: Number of rows.
    ///   - noise: Position noise amount.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withGrid(columns: Int, rows: Int, noise: Double = 0) -> Self {
        emissionMode = .grid
        gridColumns = max(1, columns)
        gridRows = max(1, rows)
        gridNoise = noise
        return self
    }
}
