// ParticleSystem.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI
import Combine
import QuartzCore

// MARK: - ParticleSystem

/// The main particle system coordinator that manages emitters, particles, forces, and behaviors.
///
/// `ParticleSystem` is the central hub for all particle operations. It coordinates:
/// - Multiple emitters that spawn particles
/// - Force fields that affect particle movement
/// - Behaviors that modify particle properties over time
/// - Object pooling for memory efficiency
/// - Frame updates and physics simulation
///
/// ## Usage Example
/// ```swift
/// let system = ParticleSystem()
/// system.addEmitter(ParticleEmitter(configuration: .confetti))
/// system.addForce(GravityForce(strength: 98))
/// system.start()
/// ```
@MainActor
public final class ParticleSystem: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All currently active particles in the system.
    @Published public private(set) var particles: [Particle] = []
    
    /// Current state of the particle system.
    @Published public private(set) var state: ParticleSystemState = .stopped
    
    /// Performance statistics for the current frame.
    @Published public private(set) var statistics: ParticleStatistics = ParticleStatistics()
    
    /// Whether the system is paused.
    @Published public var isPaused: Bool = false
    
    // MARK: - Configuration
    
    /// Global configuration for the particle system.
    public var configuration: SystemConfiguration
    
    /// Maximum number of particles allowed across all emitters.
    public var maxParticles: Int {
        get { configuration.maxParticles }
        set { configuration.maxParticles = newValue }
    }
    
    /// Global time scale multiplier (1.0 = normal speed).
    public var timeScale: Double {
        get { configuration.timeScale }
        set { configuration.timeScale = max(0, newValue) }
    }
    
    /// The bounds within which particles are simulated.
    public var bounds: CGRect {
        get { configuration.bounds }
        set { configuration.bounds = newValue }
    }
    
    // MARK: - Components
    
    /// Array of emitters that spawn particles.
    private var emitters: [ParticleEmitter] = []
    
    /// Array of forces applied to all particles.
    private var forces: [any Force] = []
    
    /// Array of behaviors applied to all particles.
    private var behaviors: [any ParticleBehavior] = []
    
    /// Object pool for particle recycling.
    private var particlePool: ParticlePool
    
    /// Display link for frame updates.
    private var displayLink: CADisplayLink?
    
    /// Timestamp of the last update.
    private var lastUpdateTime: CFTimeInterval = 0
    
    /// Accumulator for fixed time step simulation.
    private var accumulator: Double = 0
    
    /// Fixed time step for physics simulation.
    private let fixedDeltaTime: Double = 1.0 / 60.0
    
    /// Cancellables for Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// Queue for particle updates (for parallel processing).
    private let updateQueue = DispatchQueue(
        label: "com.swiftparticles.update",
        qos: .userInteractive,
        attributes: .concurrent
    )
    
    /// Callback invoked each frame with the current particles.
    public var onUpdate: (([Particle]) -> Void)?
    
    /// Callback invoked when all emitters complete and particles die.
    public var onComplete: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Creates a new particle system with optional configuration.
    /// - Parameter configuration: The system configuration to use.
    public init(configuration: SystemConfiguration = SystemConfiguration()) {
        self.configuration = configuration
        self.particlePool = ParticlePool(capacity: configuration.maxParticles)
    }
    
    /// Creates a particle system with a single emitter using the given configuration.
    /// - Parameter particleConfiguration: Configuration for the default emitter.
    public convenience init(particleConfiguration: ParticleConfiguration) {
        self.init()
        let emitter = ParticleEmitter(configuration: particleConfiguration)
        addEmitter(emitter)
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Emitter Management
    
    /// Adds an emitter to the system.
    /// - Parameter emitter: The emitter to add.
    public func addEmitter(_ emitter: ParticleEmitter) {
        emitters.append(emitter)
    }
    
    /// Removes an emitter from the system.
    /// - Parameter emitter: The emitter to remove.
    public func removeEmitter(_ emitter: ParticleEmitter) {
        emitters.removeAll { $0 === emitter }
    }
    
    /// Removes all emitters from the system.
    public func removeAllEmitters() {
        emitters.removeAll()
    }
    
    /// Returns all emitters in the system.
    public var allEmitters: [ParticleEmitter] {
        emitters
    }
    
    // MARK: - Force Management
    
    /// Adds a force to the system.
    /// - Parameter force: The force to add.
    public func addForce(_ force: any Force) {
        forces.append(force)
    }
    
    /// Removes a force from the system by type.
    /// - Parameter forceType: The type of force to remove.
    public func removeForce<T: Force>(ofType forceType: T.Type) {
        forces.removeAll { $0 is T }
    }
    
    /// Removes all forces from the system.
    public func removeAllForces() {
        forces.removeAll()
    }
    
    /// Returns all forces in the system.
    public var allForces: [any Force] {
        forces
    }
    
    // MARK: - Behavior Management
    
    /// Adds a behavior to the system.
    /// - Parameter behavior: The behavior to add.
    public func addBehavior(_ behavior: any ParticleBehavior) {
        behaviors.append(behavior)
    }
    
    /// Removes a behavior from the system by type.
    /// - Parameter behaviorType: The type of behavior to remove.
    public func removeBehavior<T: ParticleBehavior>(ofType behaviorType: T.Type) {
        behaviors.removeAll { $0 is T }
    }
    
    /// Removes all behaviors from the system.
    public func removeAllBehaviors() {
        behaviors.removeAll()
    }
    
    /// Returns all behaviors in the system.
    public var allBehaviors: [any ParticleBehavior] {
        behaviors
    }
    
    // MARK: - Control
    
    /// Starts the particle system simulation.
    public func start() {
        guard state != .running else { return }
        
        state = .running
        isPaused = false
        lastUpdateTime = CACurrentMediaTime()
        accumulator = 0
        
        // Start all emitters
        for emitter in emitters {
            emitter.start()
        }
        
        // Setup display link
        setupDisplayLink()
    }
    
    /// Stops the particle system and clears all particles.
    public func stop() {
        state = .stopped
        
        // Stop display link
        displayLink?.invalidate()
        displayLink = nil
        
        // Stop all emitters
        for emitter in emitters {
            emitter.stop()
        }
        
        // Return particles to pool
        for particle in particles {
            particlePool.release(particle)
        }
        particles.removeAll()
        
        // Reset statistics
        statistics = ParticleStatistics()
    }
    
    /// Pauses the particle system.
    public func pause() {
        isPaused = true
        state = .paused
    }
    
    /// Resumes a paused particle system.
    public func resume() {
        guard state == .paused else { return }
        isPaused = false
        state = .running
        lastUpdateTime = CACurrentMediaTime()
    }
    
    /// Resets the particle system to its initial state.
    public func reset() {
        stop()
        for emitter in emitters {
            emitter.reset()
        }
        particlePool.reset()
    }
    
    /// Triggers a burst of particles from all emitters.
    /// - Parameter count: Number of particles per emitter. Uses emitter config if nil.
    public func burst(count: Int? = nil) {
        for emitter in emitters {
            let newParticles = emitter.burst(count: count)
            addParticles(newParticles)
        }
    }
    
    // MARK: - Display Link
    
    /// Sets up the display link for frame updates.
    private func setupDisplayLink() {
        displayLink?.invalidate()
        
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 30,
            maximum: 120,
            preferred: 60
        )
        displayLink?.add(to: .main, forMode: .common)
    }
    
    /// Called each frame by the display link.
    @objc private func displayLinkFired(_ link: CADisplayLink) {
        guard state == .running && !isPaused else { return }
        
        let currentTime = link.timestamp
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Clamp delta time to prevent spiral of death
        deltaTime = min(deltaTime, 0.1)
        
        // Apply time scale
        deltaTime *= timeScale
        
        // Update the system
        update(deltaTime: deltaTime)
    }
    
    // MARK: - Update Loop
    
    /// Main update method called each frame.
    /// - Parameter deltaTime: Time elapsed since last update.
    public func update(deltaTime: Double) {
        let frameStartTime = CACurrentMediaTime()
        
        // Fixed timestep accumulator
        accumulator += deltaTime
        
        var physicsIterations = 0
        while accumulator >= fixedDeltaTime {
            physicsUpdate(deltaTime: fixedDeltaTime)
            accumulator -= fixedDeltaTime
            physicsIterations += 1
            
            // Prevent infinite loop
            if physicsIterations > 4 {
                accumulator = 0
                break
            }
        }
        
        // Emit new particles
        emitParticles(deltaTime: deltaTime)
        
        // Remove dead particles
        removeDeadParticles()
        
        // Update statistics
        let frameEndTime = CACurrentMediaTime()
        updateStatistics(frameTime: frameEndTime - frameStartTime)
        
        // Notify callback
        onUpdate?(particles)
        
        // Check for completion
        checkCompletion()
    }
    
    /// Performs physics update at fixed timestep.
    /// - Parameter deltaTime: Fixed time step.
    private func physicsUpdate(deltaTime: Double) {
        // Reset accelerations
        for index in particles.indices {
            particles[index].resetForces()
        }
        
        // Apply forces
        for force in forces where force.isEnabled {
            for index in particles.indices {
                let forceVector = force.calculateForce(for: particles[index], deltaTime: deltaTime)
                particles[index].applyForce(forceVector)
            }
        }
        
        // Apply behaviors
        for behavior in behaviors where behavior.isEnabled {
            for index in particles.indices {
                behavior.apply(to: &particles[index], deltaTime: deltaTime)
            }
        }
        
        // Update particle physics
        for index in particles.indices {
            // Apply drag
            let config = emitters.first?.configuration ?? ParticleConfiguration()
            let drag = config.drag
            particles[index].velocity = particles[index].velocity * (1.0 - drag)
            
            // Update position and rotation
            particles[index].update(deltaTime: deltaTime)
            
            // Handle boundary collisions
            if config.collidesWithBounds {
                handleBoundaryCollision(index: index, bounciness: config.bounciness)
            }
        }
    }
    
    /// Handles collision with system bounds.
    /// - Parameters:
    ///   - index: Index of the particle to check.
    ///   - bounciness: Bounce factor for collisions.
    private func handleBoundaryCollision(index: Int, bounciness: Double) {
        var particle = particles[index]
        let halfSize = particle.size.width / 2
        
        // Left and right bounds
        if particle.position.x - halfSize < bounds.minX {
            particle.position.x = bounds.minX + halfSize
            particle.velocity.x = -particle.velocity.x * bounciness
        } else if particle.position.x + halfSize > bounds.maxX {
            particle.position.x = bounds.maxX - halfSize
            particle.velocity.x = -particle.velocity.x * bounciness
        }
        
        // Top and bottom bounds
        if particle.position.y - halfSize < bounds.minY {
            particle.position.y = bounds.minY + halfSize
            particle.velocity.y = -particle.velocity.y * bounciness
        } else if particle.position.y + halfSize > bounds.maxY {
            particle.position.y = bounds.maxY - halfSize
            particle.velocity.y = -particle.velocity.y * bounciness
        }
        
        particles[index] = particle
    }
    
    /// Emits particles from all active emitters.
    /// - Parameter deltaTime: Time elapsed.
    private func emitParticles(deltaTime: Double) {
        for emitter in emitters where emitter.isActive {
            let newParticles = emitter.update(
                deltaTime: deltaTime,
                currentCount: particles.count
            )
            addParticles(newParticles)
        }
    }
    
    /// Adds particles to the system, respecting max limit.
    /// - Parameter newParticles: Particles to add.
    private func addParticles(_ newParticles: [Particle]) {
        let available = maxParticles - particles.count
        let toAdd = Array(newParticles.prefix(available))
        particles.append(contentsOf: toAdd)
    }
    
    /// Removes dead particles and returns them to the pool.
    private func removeDeadParticles() {
        var deadIndices: [Int] = []
        
        for (index, particle) in particles.enumerated() {
            if !particle.isAlive {
                deadIndices.append(index)
                particlePool.release(particle)
            }
        }
        
        // Remove in reverse order to maintain indices
        for index in deadIndices.reversed() {
            particles.remove(at: index)
        }
    }
    
    /// Updates performance statistics.
    /// - Parameter frameTime: Time taken to process the frame.
    private func updateStatistics(frameTime: Double) {
        statistics.particleCount = particles.count
        statistics.emitterCount = emitters.count
        statistics.forceCount = forces.count
        statistics.behaviorCount = behaviors.count
        statistics.lastFrameTime = frameTime
        statistics.fps = frameTime > 0 ? 1.0 / frameTime : 0
        statistics.pooledParticles = particlePool.availableCount
    }
    
    /// Checks if the system has completed.
    private func checkCompletion() {
        // Check if all emitters are done and no particles remain
        let allEmittersDone = emitters.allSatisfy { $0.isCompleted || !$0.isActive }
        
        if allEmittersDone && particles.isEmpty && state == .running {
            state = .completed
            onComplete?()
        }
    }
}

// MARK: - SystemConfiguration

/// Configuration options for the particle system.
public struct SystemConfiguration: Sendable {
    
    /// Maximum number of particles allowed in the system.
    public var maxParticles: Int
    
    /// Global time scale multiplier.
    public var timeScale: Double
    
    /// Bounds for particle simulation.
    public var bounds: CGRect
    
    /// Whether to use parallel processing for updates.
    public var useParallelProcessing: Bool
    
    /// Whether to enable performance profiling.
    public var profilingEnabled: Bool
    
    /// Seed for random number generation (nil for random seed).
    public var randomSeed: UInt64?
    
    /// Creates a default system configuration.
    public init(
        maxParticles: Int = 10000,
        timeScale: Double = 1.0,
        bounds: CGRect = CGRect(x: 0, y: 0, width: 400, height: 800),
        useParallelProcessing: Bool = false,
        profilingEnabled: Bool = false,
        randomSeed: UInt64? = nil
    ) {
        self.maxParticles = maxParticles
        self.timeScale = timeScale
        self.bounds = bounds
        self.useParallelProcessing = useParallelProcessing
        self.profilingEnabled = profilingEnabled
        self.randomSeed = randomSeed
    }
}

// MARK: - ParticleSystemState

/// Represents the current state of a particle system.
public enum ParticleSystemState: String, CaseIterable, Sendable {
    /// System is stopped and not processing.
    case stopped
    /// System is actively running.
    case running
    /// System is paused.
    case paused
    /// System has completed all emissions and particle lifetimes.
    case completed
}

// MARK: - ParticleStatistics

/// Performance statistics for the particle system.
public struct ParticleStatistics: Sendable {
    
    /// Current number of active particles.
    public var particleCount: Int = 0
    
    /// Number of active emitters.
    public var emitterCount: Int = 0
    
    /// Number of active forces.
    public var forceCount: Int = 0
    
    /// Number of active behaviors.
    public var behaviorCount: Int = 0
    
    /// Time taken to process the last frame (in seconds).
    public var lastFrameTime: Double = 0
    
    /// Current frames per second.
    public var fps: Double = 0
    
    /// Number of particles available in the pool.
    public var pooledParticles: Int = 0
    
    /// Total particles spawned since start.
    public var totalSpawned: Int = 0
    
    /// Peak particle count reached.
    public var peakParticleCount: Int = 0
}

// MARK: - Convenience Extensions

extension ParticleSystem {
    
    /// Creates a particle system with a preset configuration.
    /// - Parameter preset: The preset to use.
    /// - Returns: A configured particle system.
    public static func withPreset(_ preset: ParticlePreset) -> ParticleSystem {
        let system = ParticleSystem()
        let emitter = ParticleEmitter.withPreset(preset)
        system.addEmitter(emitter)
        
        // Add default gravity for most presets
        if preset != .snow {
            system.addForce(GravityForce())
        }
        
        // Add fade out behavior
        system.addBehavior(FadeOutBehavior())
        
        return system
    }
    
    /// Configures the system for the given view size.
    /// - Parameter size: The size of the containing view.
    public func configure(forSize size: CGSize) {
        configuration.bounds = CGRect(origin: .zero, size: size)
        
        // Update emitter positions if centered
        for emitter in emitters {
            if emitter.position == .zero {
                emitter.position = Vector2D(x: size.width / 2, y: size.height / 2)
            }
        }
    }
}
