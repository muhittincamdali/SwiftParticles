// ParticleState.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ParticleState

/// Represents the complete state of a particle at a point in time.
///
/// `ParticleState` is useful for recording particle history, implementing
/// undo/redo functionality, or creating particle trails.
public struct ParticleState: Sendable, Equatable {
    
    // MARK: - Properties
    
    /// Position in 2D space.
    public var position: Vector2D
    
    /// Velocity vector.
    public var velocity: Vector2D
    
    /// Acceleration vector.
    public var acceleration: Vector2D
    
    /// Rotation angle in radians.
    public var rotation: Double
    
    /// Angular velocity in radians per second.
    public var angularVelocity: Double
    
    /// Scale factor.
    public var scale: Double
    
    /// Opacity value.
    public var opacity: Double
    
    /// Color value.
    public var color: ParticleColor
    
    /// Current age in seconds.
    public var age: Double
    
    /// Timestamp when this state was captured.
    public var timestamp: Double
    
    // MARK: - Initialization
    
    /// Creates a particle state from an existing particle.
    /// - Parameters:
    ///   - particle: The particle to capture state from.
    ///   - timestamp: The time this state was captured.
    public init(from particle: Particle, timestamp: Double = 0) {
        self.position = particle.position
        self.velocity = particle.velocity
        self.acceleration = particle.acceleration
        self.rotation = particle.rotation
        self.angularVelocity = particle.angularVelocity
        self.scale = particle.scale
        self.opacity = particle.opacity
        self.color = particle.color
        self.age = particle.age
        self.timestamp = timestamp
    }
    
    /// Creates a particle state with explicit values.
    public init(
        position: Vector2D = .zero,
        velocity: Vector2D = .zero,
        acceleration: Vector2D = .zero,
        rotation: Double = 0,
        angularVelocity: Double = 0,
        scale: Double = 1.0,
        opacity: Double = 1.0,
        color: ParticleColor = .white,
        age: Double = 0,
        timestamp: Double = 0
    ) {
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.rotation = rotation
        self.angularVelocity = angularVelocity
        self.scale = scale
        self.opacity = opacity
        self.color = color
        self.age = age
        self.timestamp = timestamp
    }
    
    // MARK: - Interpolation
    
    /// Linearly interpolates between two states.
    /// - Parameters:
    ///   - other: The target state.
    ///   - t: Interpolation factor (0 = self, 1 = other).
    /// - Returns: The interpolated state.
    public func lerp(to other: ParticleState, t: Double) -> ParticleState {
        let clamped = min(max(t, 0), 1)
        return ParticleState(
            position: position.lerp(to: other.position, t: clamped),
            velocity: velocity.lerp(to: other.velocity, t: clamped),
            acceleration: acceleration.lerp(to: other.acceleration, t: clamped),
            rotation: rotation + (other.rotation - rotation) * clamped,
            angularVelocity: angularVelocity + (other.angularVelocity - angularVelocity) * clamped,
            scale: scale + (other.scale - scale) * clamped,
            opacity: opacity + (other.opacity - opacity) * clamped,
            color: color.lerp(to: other.color, t: clamped),
            age: age + (other.age - age) * clamped,
            timestamp: timestamp + (other.timestamp - timestamp) * clamped
        )
    }
}

// MARK: - ParticleStateHistory

/// Maintains a history of particle states for trails or replay.
public final class ParticleStateHistory: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Maximum number of states to store.
    public let maxStates: Int
    
    /// Array of stored states, newest first.
    private var states: [ParticleState]
    
    /// Lock for thread-safe access.
    private let lock = NSLock()
    
    // MARK: - Computed Properties
    
    /// Number of stored states.
    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return states.count
    }
    
    /// Whether the history is empty.
    public var isEmpty: Bool {
        count == 0
    }
    
    /// The most recent state, if any.
    public var latest: ParticleState? {
        lock.lock()
        defer { lock.unlock() }
        return states.first
    }
    
    /// The oldest state, if any.
    public var oldest: ParticleState? {
        lock.lock()
        defer { lock.unlock() }
        return states.last
    }
    
    /// All stored states (newest first).
    public var allStates: [ParticleState] {
        lock.lock()
        defer { lock.unlock() }
        return states
    }
    
    // MARK: - Initialization
    
    /// Creates a state history with the specified capacity.
    /// - Parameter maxStates: Maximum number of states to store.
    public init(maxStates: Int = 60) {
        self.maxStates = max(1, maxStates)
        self.states = []
        self.states.reserveCapacity(maxStates)
    }
    
    // MARK: - Recording
    
    /// Records a new state.
    /// - Parameter state: The state to record.
    public func record(_ state: ParticleState) {
        lock.lock()
        defer { lock.unlock() }
        
        states.insert(state, at: 0)
        
        while states.count > maxStates {
            states.removeLast()
        }
    }
    
    /// Records a state from a particle.
    /// - Parameters:
    ///   - particle: The particle to capture state from.
    ///   - timestamp: The time of this capture.
    public func record(from particle: Particle, timestamp: Double = 0) {
        let state = ParticleState(from: particle, timestamp: timestamp)
        record(state)
    }
    
    // MARK: - Retrieval
    
    /// Gets the state at the specified index.
    /// - Parameter index: Index (0 = newest).
    /// - Returns: The state at the index, or nil if out of bounds.
    public func state(at index: Int) -> ParticleState? {
        lock.lock()
        defer { lock.unlock() }
        guard index >= 0 && index < states.count else { return nil }
        return states[index]
    }
    
    /// Gets an interpolated state at the specified time.
    /// - Parameter targetTime: The time to interpolate to.
    /// - Returns: The interpolated state, or nil if no states exist.
    public func interpolatedState(at targetTime: Double) -> ParticleState? {
        lock.lock()
        defer { lock.unlock() }
        
        guard !states.isEmpty else { return nil }
        guard states.count > 1 else { return states.first }
        
        // Find the two states surrounding the target time
        for i in 0..<(states.count - 1) {
            let newer = states[i]
            let older = states[i + 1]
            
            if older.timestamp <= targetTime && targetTime <= newer.timestamp {
                let range = newer.timestamp - older.timestamp
                if range > 0 {
                    let t = (targetTime - older.timestamp) / range
                    return older.lerp(to: newer, t: t)
                } else {
                    return newer
                }
            }
        }
        
        // Return the closest edge state
        if targetTime > states.first!.timestamp {
            return states.first
        } else {
            return states.last
        }
    }
    
    // MARK: - Clearing
    
    /// Clears all stored states.
    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        states.removeAll()
    }
    
    /// Removes states older than the specified timestamp.
    /// - Parameter timestamp: The cutoff timestamp.
    public func removeStates(olderThan timestamp: Double) {
        lock.lock()
        defer { lock.unlock() }
        states.removeAll { $0.timestamp < timestamp }
    }
}

// MARK: - ParticleSnapshot

/// A complete snapshot of all particles at a moment in time.
public struct ParticleSnapshot: Sendable {
    
    /// The timestamp of this snapshot.
    public let timestamp: Double
    
    /// All particle states at this time.
    public let particles: [ParticleState]
    
    /// Number of particles in the snapshot.
    public var count: Int {
        particles.count
    }
    
    /// Creates a snapshot from an array of particles.
    /// - Parameters:
    ///   - particles: The particles to snapshot.
    ///   - timestamp: The time of the snapshot.
    public init(particles: [Particle], timestamp: Double = 0) {
        self.timestamp = timestamp
        self.particles = particles.map { ParticleState(from: $0, timestamp: timestamp) }
    }
    
    /// Creates a snapshot from existing states.
    /// - Parameters:
    ///   - states: The states to include.
    ///   - timestamp: The time of the snapshot.
    public init(states: [ParticleState], timestamp: Double = 0) {
        self.timestamp = timestamp
        self.particles = states
    }
}
