// ParticleEmitter.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - ParticleEmitter

/// Responsible for spawning new particles based on configuration.
/// The emitter handles timing, positioning, and initial property randomization.
public final class ParticleEmitter: @unchecked Sendable {

    // MARK: - Properties

    /// The configuration driving this emitter's behavior.
    public var configuration: ParticleConfiguration

    /// Position of the emitter in the parent coordinate space.
    public var position: Vector2D

    /// Whether this emitter is currently active and producing particles.
    public var isActive: Bool

    /// Total time this emitter has been running.
    private var elapsedTime: Double

    /// Time accumulator for emission rate timing.
    private var emissionAccumulator: Double

    /// Time accumulator for burst timing.
    private var burstAccumulator: Double

    /// Number of particles spawned so far.
    private var totalSpawned: Int

    /// Random number generator for deterministic sequences.
    private var rng: RandomNumberGenerator

    /// Callback invoked when the emitter finishes its duration.
    public var onComplete: (() -> Void)?

    /// Whether the emitter has completed its run.
    public private(set) var isCompleted: Bool

    // MARK: - Initialization

    /// Creates a new particle emitter.
    /// - Parameters:
    ///   - configuration: The particle configuration to use.
    ///   - position: Initial position of the emitter.
    public init(
        configuration: ParticleConfiguration = ParticleConfiguration(),
        position: Vector2D = .zero
    ) {
        self.configuration = configuration
        self.position = position
        self.isActive = false
        self.elapsedTime = 0
        self.emissionAccumulator = 0
        self.burstAccumulator = 0
        self.totalSpawned = 0
        self.rng = SystemRandomNumberGenerator()
        self.onComplete = nil
        self.isCompleted = false
    }

    // MARK: - Control

    /// Starts the emitter.
    public func start() {
        isActive = true
        isCompleted = false
        elapsedTime = 0
        emissionAccumulator = 0
        burstAccumulator = 0
    }

    /// Stops the emitter. Already spawned particles continue their lifetime.
    public func stop() {
        isActive = false
    }

    /// Resets the emitter to its initial state.
    public func reset() {
        stop()
        elapsedTime = 0
        emissionAccumulator = 0
        burstAccumulator = 0
        totalSpawned = 0
        isCompleted = false
    }

    /// Triggers a single burst of particles.
    /// - Parameter count: Number of particles to spawn. Uses config burstCount if nil.
    /// - Returns: Array of newly created particles.
    public func burst(count: Int? = nil) -> [Particle] {
        let spawnCount = count ?? configuration.burstCount
        guard spawnCount > 0 else { return [] }
        return (0..<spawnCount).map { _ in createParticle() }
    }

    // MARK: - Update

    /// Advances the emitter and returns any newly spawned particles.
    /// - Parameters:
    ///   - deltaTime: Time step in seconds.
    ///   - currentCount: Current number of active particles.
    /// - Returns: Array of newly spawned particles.
    public func update(deltaTime: Double, currentCount: Int) -> [Particle] {
        guard isActive else { return [] }

        // Check if we're still in the delay period
        if elapsedTime < configuration.startDelay {
            elapsedTime += deltaTime
            return []
        }

        let activeTime = elapsedTime - configuration.startDelay
        elapsedTime += deltaTime

        // Check if duration is exceeded
        if activeTime >= configuration.duration && configuration.duration != .infinity {
            if configuration.loops {
                reset()
                start()
            } else {
                isActive = false
                isCompleted = true
                onComplete?()
                return []
            }
        }

        var newParticles: [Particle] = []
        let headroom = configuration.maxParticles - currentCount

        guard headroom > 0 else { return [] }

        // Burst mode
        if configuration.burstCount > 0 {
            burstAccumulator += deltaTime
            if burstAccumulator >= configuration.burstInterval {
                burstAccumulator -= configuration.burstInterval
                let count = min(configuration.burstCount, headroom)
                for _ in 0..<count {
                    newParticles.append(createParticle())
                }
            }
        } else {
            // Continuous emission
            emissionAccumulator += deltaTime
            let interval = 1.0 / configuration.emissionRate
            while emissionAccumulator >= interval && newParticles.count < headroom {
                emissionAccumulator -= interval
                newParticles.append(createParticle())
            }
        }

        totalSpawned += newParticles.count
        return newParticles
    }

    // MARK: - Particle Creation

    /// Creates a single particle with randomized properties based on configuration.
    /// - Returns: A new Particle instance.
    private func createParticle() -> Particle {
        let config = configuration

        // Determine spawn position
        let spawnOffset = randomPositionInShape(config.emissionShape, size: config.emissionSize)
        let spawnPosition = position + spawnOffset

        // Determine initial velocity
        let speed = Double.random(in: config.speedRange)
        let angleVariation = Double.random(in: -config.spreadAngle...config.spreadAngle)
        let angle = config.emissionAngle + angleVariation
        let baseVelocity = Vector2D(
            x: cos(angle) * speed,
            y: sin(angle) * speed
        )
        let randomComponent = Vector2D(
            x: Double.random(in: -1...1) * config.velocityRandomness * speed,
            y: Double.random(in: -1...1) * config.velocityRandomness * speed
        )
        let velocity = baseVelocity + randomComponent

        // Determine visual properties
        let size = Double.random(in: config.sizeRange)
        let opacity = Double.random(in: config.opacityRange)
        let rotation = Double.random(in: config.rotationRange)
        let angularVelocity = Double.random(in: config.angularVelocityRange)
        let lifetime = Double.random(in: config.lifetimeRange)
        let mass = Double.random(in: config.massRange)

        // Pick a random color from palette
        let color: ParticleColor
        if config.colorPalette.isEmpty {
            color = .white
        } else {
            color = config.colorPalette[Int.random(in: 0..<config.colorPalette.count)]
        }

        return Particle(
            position: spawnPosition,
            velocity: velocity,
            acceleration: .zero,
            rotation: rotation,
            angularVelocity: angularVelocity,
            scale: 1.0,
            opacity: opacity,
            color: color,
            lifetime: lifetime,
            mass: mass,
            size: CGSize(width: size, height: size),
            shape: config.shape
        )
    }

    // MARK: - Helpers

    /// Returns a random offset within the given emission shape.
    private func randomPositionInShape(_ shape: EmissionShape, size: CGSize) -> Vector2D {
        switch shape {
        case .point:
            return .zero

        case .circle(let radius):
            let r = sqrt(Double.random(in: 0...1)) * radius
            let theta = Double.random(in: 0...(.pi * 2))
            return Vector2D(x: cos(theta) * r, y: sin(theta) * r)

        case .rectangle:
            return Vector2D(
                x: Double.random(in: -size.width / 2...size.width / 2),
                y: Double.random(in: -size.height / 2...size.height / 2)
            )

        case .line(let length):
            let t = Double.random(in: -0.5...0.5)
            return Vector2D(x: t * length, y: 0)

        case .ring(let radius):
            let theta = Double.random(in: 0...(.pi * 2))
            return Vector2D(x: cos(theta) * radius, y: sin(theta) * radius)

        case .custom(let points):
            guard !points.isEmpty else { return .zero }
            return points[Int.random(in: 0..<points.count)]
        }
    }
}

// MARK: - Preset Emitter Factory

extension ParticleEmitter {

    /// Creates an emitter configured for the given preset.
    /// - Parameters:
    ///   - preset: The particle preset to use.
    ///   - position: Emitter position.
    /// - Returns: A configured ParticleEmitter.
    public static func withPreset(
        _ preset: ParticlePreset,
        position: Vector2D = .zero
    ) -> ParticleEmitter {
        let config = preset.configuration
        let emitter = ParticleEmitter(configuration: config, position: position)
        return emitter
    }
}
