// CustomShapeEmitter.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - CustomShapeEmitter

/// An emitter that spawns particles based on a custom shape defined by points or paths.
///
/// `CustomShapeEmitter` allows you to define arbitrary shapes for particle emission.
/// You can provide vertices for polygons, paths for curved shapes, or even use
/// SwiftUI paths for complex geometries.
///
/// ## Usage Example
/// ```swift
/// // Triangle shape
/// let triangle = CustomShapeEmitter(vertices: [
///     Vector2D(x: 200, y: 100),
///     Vector2D(x: 100, y: 300),
///     Vector2D(x: 300, y: 300)
/// ])
///
/// // Star shape
/// let star = CustomShapeEmitter.star(
///     center: Vector2D(x: 200, y: 200),
///     points: 5,
///     outerRadius: 100,
///     innerRadius: 40
/// )
/// ```
public final class CustomShapeEmitter: BaseEmitter {
    
    // MARK: - Properties
    
    /// Vertices defining the custom shape.
    public var vertices: [Vector2D] {
        didSet {
            updateShapeProperties()
        }
    }
    
    /// How particles are distributed within the shape.
    public var emissionMode: CustomShapeEmissionMode = .vertices
    
    /// Whether the shape is closed (last point connects to first).
    public var isClosed: Bool = true
    
    /// Interpolation points between vertices for smoother edges.
    public var edgeSubdivisions: Int = 1
    
    /// Whether to emit normal to the edge direction.
    public var emitNormal: Bool = false
    
    /// Direction of normal emission (1 = outward, -1 = inward).
    public var normalDirection: Double = 1
    
    /// Cached center of the shape.
    private var shapeCenter: Vector2D = .zero
    
    /// Cached edge lengths for weighted random selection.
    private var edgeLengths: [Double] = []
    
    /// Total perimeter of the shape.
    private var totalPerimeter: Double = 0
    
    /// Precomputed points for filled emission.
    private var filledPoints: [Vector2D] = []
    
    /// Grid resolution for filled point generation.
    public var fillResolution: Int = 20
    
    // MARK: - Computed Properties
    
    /// Number of vertices in the shape.
    public var vertexCount: Int {
        vertices.count
    }
    
    /// Number of edges in the shape.
    public var edgeCount: Int {
        guard vertices.count >= 2 else { return 0 }
        return isClosed ? vertices.count : vertices.count - 1
    }
    
    // MARK: - Initialization
    
    /// Creates a custom shape emitter with the specified vertices.
    /// - Parameters:
    ///   - vertices: Array of points defining the shape.
    ///   - configuration: The particle configuration.
    public init(
        vertices: [Vector2D],
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) {
        self.vertices = vertices
        
        // Calculate initial center
        let centerX = vertices.isEmpty ? 0 : vertices.reduce(0.0) { $0 + $1.x } / Double(vertices.count)
        let centerY = vertices.isEmpty ? 0 : vertices.reduce(0.0) { $0 + $1.y } / Double(vertices.count)
        
        super.init(configuration: configuration, position: Vector2D(x: centerX, y: centerY))
        updateShapeProperties()
    }
    
    // MARK: - Factory Methods
    
    /// Creates a regular polygon emitter.
    /// - Parameters:
    ///   - center: Center of the polygon.
    ///   - sides: Number of sides.
    ///   - radius: Distance from center to vertices.
    ///   - rotation: Initial rotation offset in radians.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured custom shape emitter.
    public static func regularPolygon(
        center: Vector2D,
        sides: Int,
        radius: Double,
        rotation: Double = 0,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CustomShapeEmitter {
        let n = max(3, sides)
        var vertices: [Vector2D] = []
        
        for i in 0..<n {
            let angle = rotation + Double(i) * (.pi * 2 / Double(n)) - .pi / 2
            vertices.append(Vector2D(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            ))
        }
        
        let emitter = CustomShapeEmitter(vertices: vertices, configuration: configuration)
        emitter.position = center
        return emitter
    }
    
    /// Creates a star-shaped emitter.
    /// - Parameters:
    ///   - center: Center of the star.
    ///   - points: Number of points on the star.
    ///   - outerRadius: Distance to star points.
    ///   - innerRadius: Distance to inner vertices.
    ///   - rotation: Initial rotation offset.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured custom shape emitter.
    public static func star(
        center: Vector2D,
        points: Int,
        outerRadius: Double,
        innerRadius: Double,
        rotation: Double = 0,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CustomShapeEmitter {
        let n = max(3, points)
        var vertices: [Vector2D] = []
        let angleStep = .pi / Double(n)
        
        for i in 0..<(n * 2) {
            let angle = rotation + Double(i) * angleStep - .pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            vertices.append(Vector2D(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            ))
        }
        
        let emitter = CustomShapeEmitter(vertices: vertices, configuration: configuration)
        emitter.position = center
        return emitter
    }
    
    /// Creates a heart-shaped emitter.
    /// - Parameters:
    ///   - center: Center of the heart.
    ///   - size: Approximate size of the heart.
    ///   - resolution: Number of vertices (higher = smoother).
    ///   - configuration: The particle configuration.
    /// - Returns: A configured custom shape emitter.
    public static func heart(
        center: Vector2D,
        size: Double,
        resolution: Int = 32,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CustomShapeEmitter {
        var vertices: [Vector2D] = []
        let scale = size / 2
        
        for i in 0..<resolution {
            let t = Double(i) / Double(resolution) * .pi * 2
            // Heart curve parametric equation
            let x = 16 * pow(sin(t), 3)
            let y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t)
            vertices.append(Vector2D(
                x: center.x + x * scale / 16,
                y: center.y - y * scale / 16  // Flip Y for correct orientation
            ))
        }
        
        let emitter = CustomShapeEmitter(vertices: vertices, configuration: configuration)
        emitter.position = center
        return emitter
    }
    
    /// Creates a spiral emitter.
    /// - Parameters:
    ///   - center: Center of the spiral.
    ///   - startRadius: Starting radius.
    ///   - endRadius: Ending radius.
    ///   - turns: Number of spiral turns.
    ///   - resolution: Points per turn.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured custom shape emitter.
    public static func spiral(
        center: Vector2D,
        startRadius: Double,
        endRadius: Double,
        turns: Double,
        resolution: Int = 20,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CustomShapeEmitter {
        var vertices: [Vector2D] = []
        let totalPoints = Int(turns * Double(resolution))
        
        for i in 0...totalPoints {
            let t = Double(i) / Double(totalPoints)
            let angle = t * turns * .pi * 2
            let radius = startRadius + t * (endRadius - startRadius)
            vertices.append(Vector2D(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            ))
        }
        
        let emitter = CustomShapeEmitter(vertices: vertices, configuration: configuration)
        emitter.isClosed = false
        emitter.position = center
        return emitter
    }
    
    /// Creates an emitter from text (approximates letter shapes).
    /// - Parameters:
    ///   - character: The character to create.
    ///   - position: Center position.
    ///   - size: Approximate size.
    ///   - configuration: The particle configuration.
    /// - Returns: A configured custom shape emitter.
    public static func fromCharacter(
        _ character: Character,
        position: Vector2D,
        size: Double,
        configuration: ParticleConfiguration = ParticleConfiguration()
    ) -> CustomShapeEmitter {
        // Simple approximation for common letters
        // In a full implementation, you'd use CoreText to get actual glyph paths
        let vertices = characterToVertices(character, size: size, position: position)
        let emitter = CustomShapeEmitter(vertices: vertices, configuration: configuration)
        emitter.position = position
        return emitter
    }
    
    /// Converts a character to approximate vertices.
    private static func characterToVertices(
        _ char: Character,
        size: Double,
        position: Vector2D
    ) -> [Vector2D] {
        let halfSize = size / 2
        let quarterSize = size / 4
        
        switch char.uppercased() {
        case "O", "0":
            // Approximate circle
            return (0..<16).map { i in
                let angle = Double(i) / 16.0 * .pi * 2
                return Vector2D(
                    x: position.x + cos(angle) * halfSize,
                    y: position.y + sin(angle) * halfSize
                )
            }
        case "A":
            return [
                Vector2D(x: position.x, y: position.y - halfSize),
                Vector2D(x: position.x - halfSize, y: position.y + halfSize),
                Vector2D(x: position.x - quarterSize, y: position.y),
                Vector2D(x: position.x + quarterSize, y: position.y),
                Vector2D(x: position.x + halfSize, y: position.y + halfSize)
            ]
        default:
            // Default to a square
            return [
                Vector2D(x: position.x - halfSize, y: position.y - halfSize),
                Vector2D(x: position.x + halfSize, y: position.y - halfSize),
                Vector2D(x: position.x + halfSize, y: position.y + halfSize),
                Vector2D(x: position.x - halfSize, y: position.y + halfSize)
            ]
        }
    }
    
    // MARK: - Private Methods
    
    /// Updates cached shape properties.
    private func updateShapeProperties() {
        guard vertices.count >= 2 else {
            shapeCenter = position
            edgeLengths = []
            totalPerimeter = 0
            filledPoints = []
            return
        }
        
        // Calculate center
        let sumX = vertices.reduce(0.0) { $0 + $1.x }
        let sumY = vertices.reduce(0.0) { $0 + $1.y }
        shapeCenter = Vector2D(x: sumX / Double(vertices.count), y: sumY / Double(vertices.count))
        
        // Calculate edge lengths
        edgeLengths = []
        totalPerimeter = 0
        
        let edges = isClosed ? vertices.count : vertices.count - 1
        for i in 0..<edges {
            let nextIndex = (i + 1) % vertices.count
            let length = (vertices[nextIndex] - vertices[i]).magnitude
            edgeLengths.append(length)
            totalPerimeter += length
        }
        
        // Generate filled points if needed
        if case .filled = emissionMode {
            generateFilledPoints()
        }
    }
    
    /// Generates points for filled emission using point-in-polygon test.
    private func generateFilledPoints() {
        guard vertices.count >= 3 else {
            filledPoints = vertices
            return
        }
        
        filledPoints = []
        
        // Find bounding box
        let minX = vertices.min { $0.x < $1.x }?.x ?? 0
        let maxX = vertices.max { $0.x < $1.x }?.x ?? 0
        let minY = vertices.min { $0.y < $1.y }?.y ?? 0
        let maxY = vertices.max { $0.y < $1.y }?.y ?? 0
        
        let stepX = (maxX - minX) / Double(fillResolution)
        let stepY = (maxY - minY) / Double(fillResolution)
        
        for xi in 0...fillResolution {
            for yi in 0...fillResolution {
                let point = Vector2D(
                    x: minX + Double(xi) * stepX,
                    y: minY + Double(yi) * stepY
                )
                
                if isPointInPolygon(point) {
                    filledPoints.append(point)
                }
            }
        }
        
        // Always include vertices
        filledPoints.append(contentsOf: vertices)
    }
    
    /// Checks if a point is inside the polygon using ray casting.
    private func isPointInPolygon(_ point: Vector2D) -> Bool {
        guard vertices.count >= 3 else { return false }
        
        var inside = false
        var j = vertices.count - 1
        
        for i in 0..<vertices.count {
            let vi = vertices[i]
            let vj = vertices[j]
            
            if ((vi.y > point.y) != (vj.y > point.y)) &&
                (point.x < (vj.x - vi.x) * (point.y - vi.y) / (vj.y - vi.y) + vi.x) {
                inside = !inside
            }
            j = i
        }
        
        return inside
    }
    
    // MARK: - Override Methods
    
    /// Calculates the spawn position based on the shape and emission mode.
    /// - Returns: The spawn position.
    public override func calculateSpawnPosition() -> Vector2D {
        guard !vertices.isEmpty else { return position }
        
        switch emissionMode {
        case .vertices:
            return vertices[Int.random(in: 0..<vertices.count)]
            
        case .edges:
            return randomPointOnEdges()
            
        case .filled:
            if filledPoints.isEmpty {
                generateFilledPoints()
            }
            return filledPoints.isEmpty ? position : filledPoints[Int.random(in: 0..<filledPoints.count)]
            
        case .center:
            return shapeCenter
        }
    }
    
    /// Generates a random point along the edges.
    private func randomPointOnEdges() -> Vector2D {
        guard edgeLengths.count > 0, totalPerimeter > 0 else {
            return vertices.first ?? position
        }
        
        // Weighted random edge selection
        var target = Double.random(in: 0..<totalPerimeter)
        
        for (i, length) in edgeLengths.enumerated() {
            if target <= length {
                let t = target / length
                let nextIndex = (i + 1) % vertices.count
                return vertices[i].lerp(to: vertices[nextIndex], t: t)
            }
            target -= length
        }
        
        return vertices.last ?? position
    }
    
    /// Calculates initial velocity with optional normal emission.
    /// - Returns: The initial velocity vector.
    public override func calculateInitialVelocity() -> Vector2D {
        guard emitNormal, emissionMode == .edges, edgeLengths.count > 0 else {
            return super.calculateInitialVelocity()
        }
        
        let speed = Double.random(in: configuration.speedRange)
        
        // Find the closest edge to determine normal
        // For simplicity, using average normal
        let edgeIndex = Int.random(in: 0..<edgeLengths.count)
        let nextIndex = (edgeIndex + 1) % vertices.count
        let edge = vertices[nextIndex] - vertices[edgeIndex]
        let normal = Vector2D(x: -edge.y, y: edge.x).normalized * normalDirection
        
        let spread = Double.random(in: -configuration.spreadAngle...configuration.spreadAngle)
        return normal.rotated(by: spread) * speed
    }
}

// MARK: - CustomShapeEmissionMode

/// How particles are distributed within a custom shape.
public enum CustomShapeEmissionMode: Sendable {
    /// Particles appear at vertices only.
    case vertices
    /// Particles appear along edges.
    case edges
    /// Particles fill the shape interior.
    case filled
    /// Particles appear at the shape center.
    case center
}

// MARK: - CustomShapeEmitter Builder

extension CustomShapeEmitter {
    
    /// Sets the emission mode.
    /// - Parameter mode: The emission mode.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withEmissionMode(_ mode: CustomShapeEmissionMode) -> Self {
        emissionMode = mode
        if case .filled = mode {
            generateFilledPoints()
        }
        return self
    }
    
    /// Enables normal emission from edges.
    /// - Parameter outward: Whether to emit outward.
    /// - Returns: Self for chaining.
    @discardableResult
    public func emittingNormal(outward: Bool = true) -> Self {
        emitNormal = true
        normalDirection = outward ? 1 : -1
        return self
    }
    
    /// Sets the fill resolution for filled emission.
    /// - Parameter resolution: Grid resolution.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withFillResolution(_ resolution: Int) -> Self {
        fillResolution = max(1, resolution)
        if case .filled = emissionMode {
            generateFilledPoints()
        }
        return self
    }
}
