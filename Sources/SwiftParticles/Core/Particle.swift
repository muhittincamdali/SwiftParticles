// Particle.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - Particle

/// Represents a single particle in the system with position, velocity, and visual properties.
public struct Particle: Identifiable, Sendable {

    // MARK: - Properties

    /// Unique identifier for this particle instance.
    public let id: UUID

    /// Current position in 2D space.
    public var position: Vector2D

    /// Current velocity vector.
    public var velocity: Vector2D

    /// Current acceleration vector.
    public var acceleration: Vector2D

    /// Rotation angle in radians.
    public var rotation: Double

    /// Angular velocity in radians per second.
    public var angularVelocity: Double

    /// Current scale factor (1.0 = original size).
    public var scale: Double

    /// Current opacity (0.0 = invisible, 1.0 = fully visible).
    public var opacity: Double

    /// Particle color.
    public var color: ParticleColor

    /// Time this particle has been alive, in seconds.
    public var age: Double

    /// Maximum lifetime in seconds. Particle is removed when age >= lifetime.
    public var lifetime: Double

    /// Mass of the particle, affects physics calculations.
    public var mass: Double

    /// Size of the particle in points.
    public var size: CGSize

    /// Shape to render for this particle.
    public var shape: ParticleShape

    /// Whether this particle is still active.
    public var isAlive: Bool {
        age < lifetime && opacity > 0.001
    }

    /// Normalized age from 0 (born) to 1 (end of life).
    public var normalizedAge: Double {
        min(age / lifetime, 1.0)
    }

    /// Custom user data dictionary for extensions.
    public var userData: [String: Double]

    // MARK: - Initialization

    /// Creates a new particle with the specified properties.
    /// - Parameters:
    ///   - position: Initial position in 2D space.
    ///   - velocity: Initial velocity vector.
    ///   - acceleration: Initial acceleration vector.
    ///   - rotation: Initial rotation angle in radians.
    ///   - angularVelocity: Angular velocity in radians/sec.
    ///   - scale: Initial scale factor.
    ///   - opacity: Initial opacity value.
    ///   - color: Particle color.
    ///   - lifetime: Maximum lifetime in seconds.
    ///   - mass: Particle mass for physics.
    ///   - size: Visual size in points.
    ///   - shape: Render shape.
    public init(
        position: Vector2D = .zero,
        velocity: Vector2D = .zero,
        acceleration: Vector2D = .zero,
        rotation: Double = 0,
        angularVelocity: Double = 0,
        scale: Double = 1.0,
        opacity: Double = 1.0,
        color: ParticleColor = .white,
        lifetime: Double = 2.0,
        mass: Double = 1.0,
        size: CGSize = CGSize(width: 8, height: 8),
        shape: ParticleShape = .circle
    ) {
        self.id = UUID()
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.rotation = rotation
        self.angularVelocity = angularVelocity
        self.scale = scale
        self.opacity = opacity
        self.color = color
        self.age = 0
        self.lifetime = lifetime
        self.mass = mass
        self.size = size
        self.shape = shape
        self.userData = [:]
    }

    // MARK: - Update

    /// Advances the particle by the given time step.
    /// - Parameter deltaTime: Time elapsed in seconds.
    public mutating func update(deltaTime: Double) {
        velocity = velocity + acceleration * deltaTime
        position = position + velocity * deltaTime
        rotation += angularVelocity * deltaTime
        age += deltaTime
    }

    /// Applies a force to this particle based on its mass.
    /// - Parameter force: The force vector to apply.
    public mutating func applyForce(_ force: Vector2D) {
        let accel = force / mass
        acceleration = acceleration + accel
    }

    /// Resets acceleration to zero. Call at the start of each physics step.
    public mutating func resetForces() {
        acceleration = .zero
    }
}

// MARK: - ParticleShape

/// Defines the visual shape of a particle.
public enum ParticleShape: String, CaseIterable, Sendable {
    case circle
    case square
    case triangle
    case star
    case diamond
    case heart
    case spark
    case ring
    case line
    case custom
}

// MARK: - ParticleColor

/// Represents a color for particles with convenient presets.
public struct ParticleColor: Sendable, Equatable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public static let white = ParticleColor(red: 1, green: 1, blue: 1)
    public static let red = ParticleColor(red: 1, green: 0.2, blue: 0.15)
    public static let orange = ParticleColor(red: 1, green: 0.6, blue: 0.1)
    public static let yellow = ParticleColor(red: 1, green: 0.95, blue: 0.2)
    public static let green = ParticleColor(red: 0.2, green: 0.9, blue: 0.3)
    public static let blue = ParticleColor(red: 0.2, green: 0.5, blue: 1.0)
    public static let purple = ParticleColor(red: 0.7, green: 0.3, blue: 0.95)
    public static let pink = ParticleColor(red: 1.0, green: 0.4, blue: 0.7)
    public static let cyan = ParticleColor(red: 0.2, green: 0.9, blue: 0.95)
    public static let gold = ParticleColor(red: 1.0, green: 0.84, blue: 0.0)

    /// Generates a random color with full alpha.
    public static func random() -> ParticleColor {
        ParticleColor(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }

    /// Linearly interpolates between two colors.
    /// - Parameters:
    ///   - other: Target color.
    ///   - t: Interpolation factor (0 = self, 1 = other).
    /// - Returns: The interpolated color.
    public func lerp(to other: ParticleColor, t: Double) -> ParticleColor {
        let clamped = min(max(t, 0), 1)
        return ParticleColor(
            red: red + (other.red - red) * clamped,
            green: green + (other.green - green) * clamped,
            blue: blue + (other.blue - blue) * clamped,
            alpha: alpha + (other.alpha - alpha) * clamped
        )
    }

    /// Converts to SwiftUI Color.
    public var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
