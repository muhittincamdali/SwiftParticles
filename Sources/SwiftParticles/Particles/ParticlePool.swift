// ParticlePool.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ParticlePool

/// Object pool for efficient particle reuse and memory management.
///
/// `ParticlePool` implements the object pool pattern to minimize memory allocation
/// overhead during particle simulation. Instead of creating and destroying particles
/// frequently, the pool maintains a collection of reusable particle instances.
///
/// ## Performance Benefits
/// - Reduces memory allocation overhead
/// - Minimizes garbage collection pressure
/// - Improves frame rate consistency
///
/// ## Usage Example
/// ```swift
/// let pool = ParticlePool(capacity: 1000)
/// let particle = pool.acquire()
/// // ... use particle ...
/// pool.release(particle)
/// ```
public final class ParticlePool: @unchecked Sendable {
    
    // MARK: - Properties
    
    /// Maximum number of particles the pool can hold.
    public let capacity: Int
    
    /// Stack of available (recycled) particles.
    private var availableParticles: [Particle]
    
    /// Set of particle IDs currently in use.
    private var activeParticleIds: Set<UUID>
    
    /// Lock for thread-safe operations.
    private let lock = NSLock()
    
    /// Default configuration for new particles.
    private var defaultConfiguration: ParticlePoolConfiguration
    
    /// Statistics about pool usage.
    public private(set) var statistics: PoolStatistics
    
    /// Callback invoked when the pool is exhausted.
    public var onPoolExhausted: (() -> Void)?
    
    // MARK: - Computed Properties
    
    /// Number of particles currently available for reuse.
    public var availableCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return availableParticles.count
    }
    
    /// Number of particles currently in use.
    public var activeCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return activeParticleIds.count
    }
    
    /// Whether the pool has available particles.
    public var hasAvailable: Bool {
        availableCount > 0
    }
    
    /// Whether the pool is empty (all particles in use).
    public var isEmpty: Bool {
        availableCount == 0
    }
    
    /// Percentage of pool currently in use (0.0 - 1.0).
    public var utilizationRate: Double {
        Double(activeCount) / Double(capacity)
    }
    
    // MARK: - Initialization
    
    /// Creates a new particle pool with the specified capacity.
    /// - Parameters:
    ///   - capacity: Maximum number of particles to pool.
    ///   - prewarm: Whether to pre-allocate all particles. Default is false.
    ///   - configuration: Default configuration for pooled particles.
    public init(
        capacity: Int,
        prewarm: Bool = false,
        configuration: ParticlePoolConfiguration = ParticlePoolConfiguration()
    ) {
        self.capacity = max(1, capacity)
        self.availableParticles = []
        self.activeParticleIds = Set()
        self.defaultConfiguration = configuration
        self.statistics = PoolStatistics()
        
        if prewarm {
            prewarmPool()
        }
    }
    
    // MARK: - Pool Operations
    
    /// Acquires a particle from the pool or creates a new one.
    /// - Parameter configuration: Optional configuration for the particle.
    /// - Returns: A particle instance, or nil if pool is exhausted and at capacity.
    public func acquire(configuration: ParticlePoolConfiguration? = nil) -> Particle? {
        lock.lock()
        defer { lock.unlock() }
        
        let config = configuration ?? defaultConfiguration
        var particle: Particle
        
        if let recycled = availableParticles.popLast() {
            // Reuse an existing particle
            particle = recycled
            resetParticle(&particle, with: config)
            statistics.reusedCount += 1
        } else if activeParticleIds.count < capacity {
            // Create a new particle
            particle = createParticle(with: config)
            statistics.allocatedCount += 1
        } else {
            // Pool exhausted
            statistics.exhaustedCount += 1
            onPoolExhausted?()
            return nil
        }
        
        activeParticleIds.insert(particle.id)
        statistics.acquireCount += 1
        statistics.peakActiveCount = max(statistics.peakActiveCount, activeParticleIds.count)
        
        return particle
    }
    
    /// Acquires multiple particles from the pool.
    /// - Parameters:
    ///   - count: Number of particles to acquire.
    ///   - configuration: Optional configuration for the particles.
    /// - Returns: Array of acquired particles (may be fewer than requested if pool is exhausted).
    public func acquire(count: Int, configuration: ParticlePoolConfiguration? = nil) -> [Particle] {
        var particles: [Particle] = []
        particles.reserveCapacity(count)
        
        for _ in 0..<count {
            if let particle = acquire(configuration: configuration) {
                particles.append(particle)
            } else {
                break
            }
        }
        
        return particles
    }
    
    /// Releases a particle back to the pool for reuse.
    /// - Parameter particle: The particle to release.
    public func release(_ particle: Particle) {
        lock.lock()
        defer { lock.unlock() }
        
        guard activeParticleIds.contains(particle.id) else {
            // Particle not from this pool or already released
            return
        }
        
        activeParticleIds.remove(particle.id)
        
        // Only keep in pool if under capacity
        if availableParticles.count < capacity {
            var mutableParticle = particle
            mutableParticle.resetForces()
            mutableParticle.clearTrail()
            availableParticles.append(mutableParticle)
        }
        
        statistics.releaseCount += 1
    }
    
    /// Releases multiple particles back to the pool.
    /// - Parameter particles: The particles to release.
    public func release(_ particles: [Particle]) {
        for particle in particles {
            release(particle)
        }
    }
    
    /// Releases all active particles back to the pool.
    public func releaseAll() {
        lock.lock()
        defer { lock.unlock() }
        
        activeParticleIds.removeAll()
        // Note: We don't add them back because we don't have references to them
        // The caller should release particles individually
    }
    
    /// Resets the pool to its initial state.
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        
        availableParticles.removeAll()
        activeParticleIds.removeAll()
        statistics = PoolStatistics()
    }
    
    /// Prewarms the pool by allocating all particles upfront.
    public func prewarmPool() {
        lock.lock()
        defer { lock.unlock() }
        
        let toCreate = capacity - availableParticles.count
        for _ in 0..<toCreate {
            let particle = createParticle(with: defaultConfiguration)
            availableParticles.append(particle)
            statistics.allocatedCount += 1
        }
    }
    
    /// Trims the pool to the specified size.
    /// - Parameter targetSize: The target number of available particles.
    public func trim(to targetSize: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        while availableParticles.count > targetSize {
            availableParticles.removeLast()
            statistics.trimmedCount += 1
        }
    }
    
    /// Updates the default configuration for new particles.
    /// - Parameter configuration: The new default configuration.
    public func updateDefaultConfiguration(_ configuration: ParticlePoolConfiguration) {
        lock.lock()
        defer { lock.unlock() }
        defaultConfiguration = configuration
    }
    
    // MARK: - Private Helpers
    
    /// Creates a new particle with the given configuration.
    private func createParticle(with config: ParticlePoolConfiguration) -> Particle {
        Particle(
            position: config.position,
            velocity: config.velocity,
            acceleration: .zero,
            rotation: config.rotation,
            angularVelocity: config.angularVelocity,
            scale: config.scale,
            opacity: config.opacity,
            color: config.color,
            lifetime: config.lifetime,
            mass: config.mass,
            size: config.size,
            shape: config.shape,
            maxTrailLength: config.maxTrailLength
        )
    }
    
    /// Resets an existing particle with new configuration.
    private func resetParticle(_ particle: inout Particle, with config: ParticlePoolConfiguration) {
        particle.position = config.position
        particle.velocity = config.velocity
        particle.acceleration = .zero
        particle.rotation = config.rotation
        particle.angularVelocity = config.angularVelocity
        particle.scale = config.scale
        particle.opacity = config.opacity
        particle.color = config.color
        particle.age = 0
        particle.lifetime = config.lifetime
        particle.mass = config.mass
        particle.size = config.size
        particle.shape = config.shape
        particle.clearTrail()
        particle.userData.removeAll()
    }
}

// MARK: - ParticlePoolConfiguration

/// Configuration for particles acquired from the pool.
public struct ParticlePoolConfiguration: Sendable {
    
    /// Initial position.
    public var position: Vector2D
    
    /// Initial velocity.
    public var velocity: Vector2D
    
    /// Initial rotation.
    public var rotation: Double
    
    /// Initial angular velocity.
    public var angularVelocity: Double
    
    /// Initial scale.
    public var scale: Double
    
    /// Initial opacity.
    public var opacity: Double
    
    /// Initial color.
    public var color: ParticleColor
    
    /// Particle lifetime.
    public var lifetime: Double
    
    /// Particle mass.
    public var mass: Double
    
    /// Particle size.
    public var size: CGSize
    
    /// Particle shape.
    public var shape: ParticleShape
    
    /// Maximum trail length.
    public var maxTrailLength: Int
    
    /// Creates a default pool configuration.
    public init(
        position: Vector2D = .zero,
        velocity: Vector2D = .zero,
        rotation: Double = 0,
        angularVelocity: Double = 0,
        scale: Double = 1.0,
        opacity: Double = 1.0,
        color: ParticleColor = .white,
        lifetime: Double = 2.0,
        mass: Double = 1.0,
        size: CGSize = CGSize(width: 8, height: 8),
        shape: ParticleShape = .circle,
        maxTrailLength: Int = 10
    ) {
        self.position = position
        self.velocity = velocity
        self.rotation = rotation
        self.angularVelocity = angularVelocity
        self.scale = scale
        self.opacity = opacity
        self.color = color
        self.lifetime = lifetime
        self.mass = mass
        self.size = size
        self.shape = shape
        self.maxTrailLength = maxTrailLength
    }
}

// MARK: - PoolStatistics

/// Statistics about particle pool usage.
public struct PoolStatistics: Sendable {
    
    /// Total number of acquire calls.
    public var acquireCount: Int = 0
    
    /// Total number of release calls.
    public var releaseCount: Int = 0
    
    /// Number of particles that were reused from the pool.
    public var reusedCount: Int = 0
    
    /// Number of particles that were newly allocated.
    public var allocatedCount: Int = 0
    
    /// Number of times the pool was exhausted.
    public var exhaustedCount: Int = 0
    
    /// Peak number of active particles at any time.
    public var peakActiveCount: Int = 0
    
    /// Number of particles trimmed from the pool.
    public var trimmedCount: Int = 0
    
    /// Reuse ratio (reused / total acquired).
    public var reuseRatio: Double {
        guard acquireCount > 0 else { return 0 }
        return Double(reusedCount) / Double(acquireCount)
    }
}

// MARK: - ThreadSafeParticlePool

/// A thread-safe wrapper around ParticlePool for concurrent access.
public final class ThreadSafeParticlePool: @unchecked Sendable {
    
    /// The underlying particle pool.
    private let pool: ParticlePool
    
    /// Dispatch queue for synchronization.
    private let queue: DispatchQueue
    
    /// Creates a thread-safe particle pool.
    /// - Parameters:
    ///   - capacity: Maximum number of particles.
    ///   - qos: Quality of service for the synchronization queue.
    public init(capacity: Int, qos: DispatchQoS = .userInteractive) {
        self.pool = ParticlePool(capacity: capacity)
        self.queue = DispatchQueue(
            label: "com.swiftparticles.pool",
            qos: qos,
            attributes: .concurrent
        )
    }
    
    /// Acquires a particle thread-safely.
    /// - Returns: A particle, or nil if pool is exhausted.
    public func acquire() -> Particle? {
        queue.sync(flags: .barrier) {
            pool.acquire()
        }
    }
    
    /// Releases a particle thread-safely.
    /// - Parameter particle: The particle to release.
    public func release(_ particle: Particle) {
        queue.async(flags: .barrier) {
            self.pool.release(particle)
        }
    }
    
    /// Number of available particles.
    public var availableCount: Int {
        queue.sync { pool.availableCount }
    }
    
    /// Number of active particles.
    public var activeCount: Int {
        queue.sync { pool.activeCount }
    }
    
    /// Pool statistics.
    public var statistics: PoolStatistics {
        queue.sync { pool.statistics }
    }
}
