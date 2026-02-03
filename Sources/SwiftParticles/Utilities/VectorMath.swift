// VectorMath.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import CoreGraphics

// MARK: - Vector2D

/// A 2D vector for particle physics calculations.
///
/// `Vector2D` provides essential vector math operations needed for
/// particle physics simulation, including addition, scaling, rotation,
/// and normalization.
///
/// ## Usage Example
/// ```swift
/// let velocity = Vector2D(x: 10, y: -5)
/// let acceleration = Vector2D(x: 0, y: 9.8)
/// let newVelocity = velocity + acceleration * deltaTime
/// ```
public struct Vector2D: Sendable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// X component.
    public var x: Double
    
    /// Y component.
    public var y: Double
    
    // MARK: - Static Properties
    
    /// Zero vector (0, 0).
    public static let zero = Vector2D(x: 0, y: 0)
    
    /// Unit vector pointing right (1, 0).
    public static let right = Vector2D(x: 1, y: 0)
    
    /// Unit vector pointing left (-1, 0).
    public static let left = Vector2D(x: -1, y: 0)
    
    /// Unit vector pointing up (0, -1) in screen coordinates.
    public static let up = Vector2D(x: 0, y: -1)
    
    /// Unit vector pointing down (0, 1) in screen coordinates.
    public static let down = Vector2D(x: 0, y: 1)
    
    /// Unit vector (1, 1).
    public static let one = Vector2D(x: 1, y: 1)
    
    // MARK: - Computed Properties
    
    /// Magnitude (length) of the vector.
    public var magnitude: Double {
        sqrt(x * x + y * y)
    }
    
    /// Squared magnitude (faster than magnitude when comparing).
    public var squaredMagnitude: Double {
        x * x + y * y
    }
    
    /// Returns a normalized (unit length) version of this vector.
    public var normalized: Vector2D {
        let mag = magnitude
        guard mag > 0 else { return .zero }
        return Vector2D(x: x / mag, y: y / mag)
    }
    
    /// Returns the perpendicular vector (rotated 90 degrees counter-clockwise).
    public var perpendicular: Vector2D {
        Vector2D(x: -y, y: x)
    }
    
    /// Returns the angle in radians (0 = right, counter-clockwise positive).
    public var angle: Double {
        atan2(y, x)
    }
    
    /// Returns the vector as a CGPoint.
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    /// Returns the vector as a CGSize.
    public var cgSize: CGSize {
        CGSize(width: x, height: y)
    }
    
    // MARK: - Initialization
    
    /// Creates a vector with the specified components.
    /// - Parameters:
    ///   - x: X component.
    ///   - y: Y component.
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    /// Creates a vector from a CGPoint.
    /// - Parameter point: The point to convert.
    public init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
    
    /// Creates a vector from a CGSize.
    /// - Parameter size: The size to convert.
    public init(_ size: CGSize) {
        self.x = size.width
        self.y = size.height
    }
    
    /// Creates a vector from an angle and magnitude.
    /// - Parameters:
    ///   - angle: Direction in radians.
    ///   - magnitude: Length of the vector.
    public init(angle: Double, magnitude: Double) {
        self.x = cos(angle) * magnitude
        self.y = sin(angle) * magnitude
    }
    
    /// Creates a random vector within the specified range.
    /// - Parameters:
    ///   - xRange: Range for X component.
    ///   - yRange: Range for Y component.
    public static func random(
        x xRange: ClosedRange<Double>,
        y yRange: ClosedRange<Double>
    ) -> Vector2D {
        Vector2D(
            x: Double.random(in: xRange),
            y: Double.random(in: yRange)
        )
    }
    
    /// Creates a random unit vector.
    public static func randomDirection() -> Vector2D {
        let angle = Double.random(in: 0..<(.pi * 2))
        return Vector2D(angle: angle, magnitude: 1)
    }
    
    /// Creates a random vector within a circle.
    /// - Parameter radius: Maximum radius.
    public static func randomInCircle(radius: Double) -> Vector2D {
        let r = sqrt(Double.random(in: 0...1)) * radius
        let angle = Double.random(in: 0..<(.pi * 2))
        return Vector2D(angle: angle, magnitude: r)
    }
    
    // MARK: - Operations
    
    /// Returns the dot product with another vector.
    /// - Parameter other: The other vector.
    /// - Returns: Dot product value.
    public func dot(_ other: Vector2D) -> Double {
        x * other.x + y * other.y
    }
    
    /// Returns the cross product with another vector.
    /// - Parameter other: The other vector.
    /// - Returns: Cross product (z component of 3D cross product).
    public func cross(_ other: Vector2D) -> Double {
        x * other.y - y * other.x
    }
    
    /// Returns the distance to another vector.
    /// - Parameter other: The other vector.
    /// - Returns: Distance value.
    public func distance(to other: Vector2D) -> Double {
        (self - other).magnitude
    }
    
    /// Returns the squared distance to another vector.
    /// - Parameter other: The other vector.
    /// - Returns: Squared distance value.
    public func squaredDistance(to other: Vector2D) -> Double {
        (self - other).squaredMagnitude
    }
    
    /// Returns the angle to another vector.
    /// - Parameter other: The other vector.
    /// - Returns: Angle in radians.
    public func angle(to other: Vector2D) -> Double {
        atan2(other.y - y, other.x - x)
    }
    
    /// Returns this vector rotated by the specified angle.
    /// - Parameter angle: Rotation angle in radians.
    /// - Returns: Rotated vector.
    public func rotated(by angle: Double) -> Vector2D {
        let cos = Foundation.cos(angle)
        let sin = Foundation.sin(angle)
        return Vector2D(
            x: x * cos - y * sin,
            y: x * sin + y * cos
        )
    }
    
    /// Returns the projection of this vector onto another.
    /// - Parameter onto: The vector to project onto.
    /// - Returns: Projected vector.
    public func projected(onto other: Vector2D) -> Vector2D {
        let dotProduct = dot(other)
        let otherSquaredMag = other.squaredMagnitude
        guard otherSquaredMag > 0 else { return .zero }
        return other * (dotProduct / otherSquaredMag)
    }
    
    /// Returns the reflection of this vector off a surface.
    /// - Parameter normal: Surface normal.
    /// - Returns: Reflected vector.
    public func reflected(off normal: Vector2D) -> Vector2D {
        self - normal * (2 * dot(normal))
    }
    
    /// Linearly interpolates to another vector.
    /// - Parameters:
    ///   - other: Target vector.
    ///   - t: Interpolation factor (0-1).
    /// - Returns: Interpolated vector.
    public func lerp(to other: Vector2D, t: Double) -> Vector2D {
        Vector2D(
            x: x + (other.x - x) * t,
            y: y + (other.y - y) * t
        )
    }
    
    /// Returns a vector with components clamped to the specified range.
    /// - Parameters:
    ///   - min: Minimum values.
    ///   - max: Maximum values.
    /// - Returns: Clamped vector.
    public func clamped(min: Vector2D, max: Vector2D) -> Vector2D {
        Vector2D(
            x: Swift.min(Swift.max(x, min.x), max.x),
            y: Swift.min(Swift.max(y, min.y), max.y)
        )
    }
    
    /// Returns a vector with magnitude clamped to maximum.
    /// - Parameter maxMagnitude: Maximum magnitude.
    /// - Returns: Clamped vector.
    public func clampedMagnitude(_ maxMagnitude: Double) -> Vector2D {
        let mag = magnitude
        if mag > maxMagnitude && mag > 0 {
            return normalized * maxMagnitude
        }
        return self
    }
    
    /// Returns vector with each component made absolute.
    public var abs: Vector2D {
        Vector2D(x: Swift.abs(x), y: Swift.abs(y))
    }
    
    /// Returns vector with components floored.
    public var floor: Vector2D {
        Vector2D(x: Foundation.floor(x), y: Foundation.floor(y))
    }
    
    /// Returns vector with components ceiled.
    public var ceil: Vector2D {
        Vector2D(x: Foundation.ceil(x), y: Foundation.ceil(y))
    }
    
    /// Returns vector with components rounded.
    public var rounded: Vector2D {
        Vector2D(x: Foundation.round(x), y: Foundation.round(y))
    }
}

// MARK: - Operators

extension Vector2D {
    
    /// Adds two vectors.
    public static func + (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    /// Subtracts two vectors.
    public static func - (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    /// Multiplies vector by scalar.
    public static func * (lhs: Vector2D, rhs: Double) -> Vector2D {
        Vector2D(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    /// Multiplies scalar by vector.
    public static func * (lhs: Double, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    /// Multiplies two vectors component-wise.
    public static func * (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs.x * rhs.x, y: lhs.y * rhs.y)
    }
    
    /// Divides vector by scalar.
    public static func / (lhs: Vector2D, rhs: Double) -> Vector2D {
        Vector2D(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    /// Divides two vectors component-wise.
    public static func / (lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs.x / rhs.x, y: lhs.y / rhs.y)
    }
    
    /// Negates a vector.
    public static prefix func - (vector: Vector2D) -> Vector2D {
        Vector2D(x: -vector.x, y: -vector.y)
    }
    
    /// Adds and assigns.
    public static func += (lhs: inout Vector2D, rhs: Vector2D) {
        lhs = lhs + rhs
    }
    
    /// Subtracts and assigns.
    public static func -= (lhs: inout Vector2D, rhs: Vector2D) {
        lhs = lhs - rhs
    }
    
    /// Multiplies and assigns.
    public static func *= (lhs: inout Vector2D, rhs: Double) {
        lhs = lhs * rhs
    }
    
    /// Divides and assigns.
    public static func /= (lhs: inout Vector2D, rhs: Double) {
        lhs = lhs / rhs
    }
}

// MARK: - CustomStringConvertible

extension Vector2D: CustomStringConvertible {
    public var description: String {
        "Vector2D(x: \(x), y: \(y))"
    }
}

// MARK: - Codable

extension Vector2D: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }
}

// MARK: - CGPoint Extension

extension CGPoint {
    /// Converts to Vector2D.
    public var vector2D: Vector2D {
        Vector2D(x: x, y: y)
    }
}

// MARK: - CGSize Extension

extension CGSize {
    /// Converts to Vector2D.
    public var vector2D: Vector2D {
        Vector2D(x: width, y: height)
    }
}
