// ParticleConfiguration.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - ParticleConfiguration

/// Holds all configuration options for a particle emitter and its particles.
public struct ParticleConfiguration: Sendable {

    // MARK: - Emission Properties

    /// Number of particles emitted per second.
    public var emissionRate: Double

    /// Maximum number of active particles at any time.
    public var maxParticles: Int

    /// Total duration the emitter runs. Use `.infinity` for continuous emission.
    public var duration: Double

    /// Whether the emitter restarts after finishing its duration.
    public var loops: Bool

    /// Delay in seconds before the emitter starts.
    public var startDelay: Double

    /// Number of particles to spawn in a single burst. Set to 0 for continuous.
    public var burstCount: Int

    /// Interval between bursts in seconds.
    public var burstInterval: Double

    // MARK: - Particle Lifetime

    /// Range of particle lifetimes in seconds.
    public var lifetimeRange: ClosedRange<Double>

    // MARK: - Position & Spread

    /// Emission area shape.
    public var emissionShape: EmissionShape

    /// Size of the emission area.
    public var emissionSize: CGSize

    /// Angle spread in radians for directional emission.
    public var spreadAngle: Double

    /// Base emission direction in radians (0 = right, π/2 = up).
    public var emissionAngle: Double

    // MARK: - Velocity

    /// Range of initial speed values.
    public var speedRange: ClosedRange<Double>

    /// Additional random velocity component.
    public var velocityRandomness: Double

    // MARK: - Visual Properties

    /// Range of initial particle sizes.
    public var sizeRange: ClosedRange<Double>

    /// Size multiplier over particle lifetime. Keys are normalized age (0-1).
    public var sizeOverLifetime: [Double: Double]

    /// Initial opacity range.
    public var opacityRange: ClosedRange<Double>

    /// Opacity curve over lifetime. Keys are normalized age (0-1).
    public var opacityOverLifetime: [Double: Double]

    /// Particle shape to render.
    public var shape: ParticleShape

    /// Array of possible colors. Particles pick randomly from this palette.
    public var colorPalette: [ParticleColor]

    /// Color gradient over lifetime. Keys are normalized age (0-1).
    public var colorOverLifetime: [Double: ParticleColor]

    /// Blend mode for rendering.
    public var blendMode: ParticleBlendMode

    // MARK: - Rotation

    /// Initial rotation range in radians.
    public var rotationRange: ClosedRange<Double>

    /// Angular velocity range in radians per second.
    public var angularVelocityRange: ClosedRange<Double>

    // MARK: - Physics

    /// Gravity vector applied to all particles.
    public var gravity: Vector2D

    /// Wind vector applied to all particles.
    public var wind: Vector2D

    /// Drag coefficient (0 = no drag, 1 = full stop).
    public var drag: Double

    /// Turbulence intensity.
    public var turbulence: Double

    /// Turbulence frequency.
    public var turbulenceFrequency: Double

    /// Mass range for particles.
    public var massRange: ClosedRange<Double>

    /// Bounce factor when colliding with boundaries (0 = no bounce, 1 = perfect).
    public var bounciness: Double

    /// Whether particles collide with the view bounds.
    public var collidesWithBounds: Bool

    /// Force fields affecting particles.
    public var forceFields: [ForceFieldConfiguration]

    // MARK: - Rendering

    /// Whether to use Metal for GPU-accelerated rendering.
    public var useMetalRenderer: Bool

    /// Whether to enable particle trails.
    public var trailEnabled: Bool

    /// Length of particle trails (number of positions to remember).
    public var trailLength: Int

    /// Trail opacity at the tail end (0-1).
    public var trailOpacity: Double

    /// Trail fade rate.
    public var trailFadeRate: Double

    /// Whether particles bounce on ground collision.
    public var bounceOnGround: Bool

    /// Bounce factor for ground collision.
    public var bounceFactor: Double

    /// Whether particles have orbital motion.
    public var orbitalMotion: Bool

    /// Center point for orbital motion.
    public var orbitalCenter: CGPoint

    /// Orbital motion speed.
    public var orbitalSpeed: Double

    /// Whether particles spiral inward.
    public var spiralInward: Bool

    /// Spiral rate.
    public var spiralRate: Double

    /// Stretch factor based on velocity.
    public var stretchFactor: Double

    /// Speed change over lifetime.
    public var speedOverLifetime: [Double: Double]

    /// Whether to enable particle shadows.
    public var shadowEnabled: Bool

    /// Shadow offset from the particle.
    public var shadowOffset: CGSize

    /// Shadow blur radius.
    public var shadowRadius: Double

    /// Shadow opacity.
    public var shadowOpacity: Double

    // MARK: - Initialization

    /// Creates a default particle configuration.
    public init() {
        self.emissionRate = 50
        self.maxParticles = 1000
        self.duration = .infinity
        self.loops = true
        self.startDelay = 0
        self.burstCount = 0
        self.burstInterval = 0.5
        self.lifetimeRange = 1.0...3.0
        self.emissionShape = .point
        self.emissionSize = CGSize(width: 10, height: 10)
        self.spreadAngle = .pi / 4
        self.emissionAngle = -.pi / 2
        self.speedRange = 50...150
        self.velocityRandomness = 0.2
        self.sizeRange = 4...12
        self.sizeOverLifetime = [0: 1.0, 0.7: 1.0, 1.0: 0.0]
        self.opacityRange = 0.8...1.0
        self.opacityOverLifetime = [0: 0.0, 0.1: 1.0, 0.8: 1.0, 1.0: 0.0]
        self.shape = .circle
        self.colorPalette = [.white]
        self.colorOverLifetime = [:]
        self.blendMode = .additive
        self.rotationRange = 0...(.pi * 2)
        self.angularVelocityRange = -2...2
        self.gravity = Vector2D(x: 0, y: 98)
        self.wind = .zero
        self.drag = 0.02
        self.turbulence = 0
        self.turbulenceFrequency = 1.0
        self.massRange = 0.8...1.2
        self.bounciness = 0.5
        self.collidesWithBounds = false
        self.forceFields = []
        self.useMetalRenderer = true
        self.trailEnabled = false
        self.trailLength = 10
        self.trailOpacity = 0.3
        self.trailFadeRate = 0.15
        self.bounceOnGround = false
        self.bounceFactor = 0.5
        self.orbitalMotion = false
        self.orbitalCenter = .zero
        self.orbitalSpeed = 1.0
        self.spiralInward = false
        self.spiralRate = 0.1
        self.stretchFactor = 1.0
        self.speedOverLifetime = [:]
        self.shadowEnabled = false
        self.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowRadius = 4
        self.shadowOpacity = 0.3
    }
}

// MARK: - EmissionShape

/// Defines the area from which particles are emitted.
public enum EmissionShape: Sendable {
    /// Particles emit from a single point.
    case point
    /// Particles emit from within a circle of the given radius.
    case circle(radius: Double)
    /// Particles emit from within a rectangle.
    case rectangle
    /// Particles emit from along a line of the given length.
    case line(length: Double)
    /// Particles emit from the edge of a circle.
    case ring(radius: Double)
    /// Particles emit from a custom set of points.
    case custom(points: [Vector2D])
}

// MARK: - ParticleBlendMode

/// Blend mode options for particle rendering.
public enum ParticleBlendMode: String, CaseIterable, Sendable {
    case normal
    case additive
    case multiply
    case screen
    case softLight
}

// MARK: - ForceFieldConfiguration

/// Configuration for a force field that affects particles.
public struct ForceFieldConfiguration: Sendable {
    /// Position of the force field center.
    public var position: Vector2D

    /// Strength of the force (positive = attract, negative = repel).
    public var strength: Double

    /// Radius of influence.
    public var radius: Double

    /// Type of force field.
    public var type: ForceFieldType

    /// Falloff behavior of the force.
    public var falloff: ForceFalloff

    public init(
        position: Vector2D = .zero,
        strength: Double = 100,
        radius: Double = 200,
        type: ForceFieldType = .attract,
        falloff: ForceFalloff = .linear
    ) {
        self.position = position
        self.strength = strength
        self.radius = radius
        self.type = type
        self.falloff = falloff
    }
}

// MARK: - ForceFieldType

/// Types of force fields available.
public enum ForceFieldType: String, CaseIterable, Sendable {
    case attract
    case repel
    case vortex
    case turbulence
    case directional
}

// MARK: - ForceFalloff

/// How force diminishes with distance.
public enum ForceFalloff: String, CaseIterable, Sendable {
    case none
    case linear
    case quadratic
    case exponential
}

// MARK: - Configuration Builder

extension ParticleConfiguration {

    /// Returns a copy with the emission rate set.
    public func withEmissionRate(_ rate: Double) -> ParticleConfiguration {
        var config = self
        config.emissionRate = rate
        return config
    }

    /// Returns a copy with the gravity set.
    public func withGravity(_ gravity: Vector2D) -> ParticleConfiguration {
        var config = self
        config.gravity = gravity
        return config
    }

    /// Returns a copy with the color palette set.
    public func withColors(_ colors: [ParticleColor]) -> ParticleConfiguration {
        var config = self
        config.colorPalette = colors
        return config
    }

    /// Returns a copy with the particle shape set.
    public func withShape(_ shape: ParticleShape) -> ParticleConfiguration {
        var config = self
        config.shape = shape
        return config
    }

    /// Returns a copy with the speed range set.
    public func withSpeed(_ range: ClosedRange<Double>) -> ParticleConfiguration {
        var config = self
        config.speedRange = range
        return config
    }

    /// Returns a copy with the lifetime range set.
    public func withLifetime(_ range: ClosedRange<Double>) -> ParticleConfiguration {
        var config = self
        config.lifetimeRange = range
        return config
    }

    /// Returns a copy with the emission shape set.
    public func withEmissionShape(_ shape: EmissionShape) -> ParticleConfiguration {
        var config = self
        config.emissionShape = shape
        return config
    }

    /// Returns a copy with turbulence configured.
    public func withTurbulence(_ intensity: Double, frequency: Double = 1.0) -> ParticleConfiguration {
        var config = self
        config.turbulence = intensity
        config.turbulenceFrequency = frequency
        return config
    }

    /// Returns a copy with trails enabled.
    public func withTrails(length: Int = 10, opacity: Double = 0.3) -> ParticleConfiguration {
        var config = self
        config.trailEnabled = true
        config.trailLength = length
        config.trailOpacity = opacity
        return config
    }

    /// Returns a copy with shadows enabled.
    public func withShadow(radius: Double = 4, opacity: Double = 0.3) -> ParticleConfiguration {
        var config = self
        config.shadowEnabled = true
        config.shadowRadius = radius
        config.shadowOpacity = opacity
        return config
    }
}
