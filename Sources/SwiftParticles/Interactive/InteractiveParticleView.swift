// InteractiveParticleView.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import SwiftUI

// MARK: - InteractiveParticleView

/// A SwiftUI view that enables interactive particle effects.
@available(iOS 16.0, macOS 14.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
///
/// Particles respond to touch/mouse input with attraction, repulsion,
/// burst on tap, and drag trails. Fully customizable interaction modes.
///
/// ## Features
/// - Touch/tap to create bursts
/// - Drag to attract particles
/// - Multi-touch support
/// - Customizable interaction radius
/// - Force strength control
///
/// ## Usage
/// ```swift
/// InteractiveParticleView(preset: .magic)
///     .interactionMode(.attract)
///     .interactionRadius(100)
///     .interactionStrength(500)
/// ```
public struct InteractiveParticleView: View {
    
    // MARK: - Properties
    
    @StateObject private var system: InteractiveParticleSystem
    
    private var preset: ParticleConfiguration
    private var interactionMode: InteractionMode
    private var interactionRadius: CGFloat
    private var interactionStrength: CGFloat
    private var burstOnTap: Bool
    private var burstCount: Int
    
    // MARK: - Initialization
    
    /// Creates an interactive particle view with a preset.
    /// - Parameter preset: The particle configuration to use.
    public init(preset: ParticleConfiguration) {
        self.preset = preset
        self.interactionMode = .attract
        self.interactionRadius = 80
        self.interactionStrength = 300
        self.burstOnTap = true
        self.burstCount = 30
        _system = StateObject(wrappedValue: InteractiveParticleSystem(configuration: preset))
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Particle canvas
                Canvas { context, size in
                    for particle in system.particles {
                        let rect = CGRect(
                            x: particle.position.x - particle.size.width / 2,
                            y: particle.position.y - particle.size.width / 2,
                            width: particle.size.width,
                            height: particle.size.width
                        )
                        
                        let color = Color(
                            red: particle.color.red,
                            green: particle.color.green,
                            blue: particle.color.blue,
                            opacity: particle.color.alpha * (1 - particle.age / particle.lifetime)
                        )
                        
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(color)
                        )
                    }
                }
                .gesture(dragGesture)
                .gesture(tapGesture)
                #if os(iOS)
                .simultaneousGesture(longPressGesture)
                #endif
            }
            .onAppear {
                system.bounds = CGRect(origin: .zero, size: geometry.size)
                system.start()
            }
            .onChange(of: geometry.size) { _, newSize in
                system.bounds = CGRect(origin: .zero, size: newSize)
            }
        }
    }
    
    // MARK: - Gestures
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                switch interactionMode {
                case .attract:
                    system.applyAttraction(at: value.location, radius: interactionRadius, strength: interactionStrength)
                case .repel:
                    system.applyRepulsion(at: value.location, radius: interactionRadius, strength: interactionStrength)
                case .turbulence:
                    system.applyTurbulence(at: value.location, radius: interactionRadius, strength: interactionStrength)
                case .trail:
                    system.emitParticles(at: value.location, count: 3)
                case .none:
                    break
                }
            }
            .onEnded { _ in
                system.clearForces()
            }
    }
    
    private var tapGesture: some Gesture {
        SpatialTapGesture()
            .onEnded { value in
                if burstOnTap {
                    system.burst(at: value.location, count: burstCount)
                }
            }
    }
    
    #if os(iOS)
    private var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .sequenced(before: DragGesture())
            .onEnded { value in
                // Continuous emission while long pressing
                if case .second(true, let drag) = value, let location = drag?.location {
                    system.emitContinuous(at: location, rate: 50)
                }
            }
    }
    #endif
    
    // MARK: - Modifiers
    
    /// Sets the interaction mode.
    public func interactionMode(_ mode: InteractionMode) -> InteractiveParticleView {
        var view = self
        view.interactionMode = mode
        return view
    }
    
    /// Sets the interaction radius.
    public func interactionRadius(_ radius: CGFloat) -> InteractiveParticleView {
        var view = self
        view.interactionRadius = radius
        return view
    }
    
    /// Sets the interaction strength.
    public func interactionStrength(_ strength: CGFloat) -> InteractiveParticleView {
        var view = self
        view.interactionStrength = strength
        return view
    }
    
    /// Enables or disables burst on tap.
    public func burstOnTap(_ enabled: Bool) -> InteractiveParticleView {
        var view = self
        view.burstOnTap = enabled
        return view
    }
    
    /// Sets the number of particles in a tap burst.
    public func burstCount(_ count: Int) -> InteractiveParticleView {
        var view = self
        view.burstCount = count
        return view
    }
}

// MARK: - InteractionMode

/// Defines how particles respond to user interaction.
public enum InteractionMode {
    /// Particles are attracted towards touch point.
    case attract
    
    /// Particles are repelled from touch point.
    case repel
    
    /// Touch creates turbulence in the particle field.
    case turbulence
    
    /// Dragging leaves a trail of new particles.
    case trail
    
    /// No interaction.
    case none
}

// MARK: - InteractiveParticleSystem

/// Particle system with interaction support.
@available(iOS 16.0, macOS 14.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
@MainActor
public final class InteractiveParticleSystem: ObservableObject {
    
    @Published public private(set) var particles: [Particle] = []
    
    public var bounds: CGRect = .zero
    
    private var configuration: ParticleConfiguration
    #if os(iOS) || os(tvOS)
    private var displayLink: CADisplayLink?
    #else
    private var timer: Timer?
    #endif
    private var lastUpdate: CFTimeInterval = 0
    
    private var attractionPoint: CGPoint?
    private var attractionRadius: CGFloat = 0
    private var attractionStrength: CGFloat = 0
    
    private var repulsionPoint: CGPoint?
    private var repulsionRadius: CGFloat = 0
    private var repulsionStrength: CGFloat = 0
    
    public init(configuration: ParticleConfiguration) {
        self.configuration = configuration
    }
    
    public func start() {
        #if os(iOS) || os(tvOS)
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .common)
        #else
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.timerUpdate()
            }
        }
        #endif
    }
    
    public func stop() {
        #if os(iOS) || os(tvOS)
        displayLink?.invalidate()
        displayLink = nil
        #else
        timer?.invalidate()
        timer = nil
        #endif
    }
    
    #if os(iOS) || os(tvOS)
    @objc private func update(_ link: CADisplayLink) {
        let deltaTime = lastUpdate == 0 ? 1.0 / 60.0 : link.timestamp - lastUpdate
        lastUpdate = link.timestamp
        performUpdate(deltaTime: deltaTime)
    }
    #else
    private func timerUpdate() {
        let currentTime = CACurrentMediaTime()
        let deltaTime = lastUpdate == 0 ? 1.0 / 60.0 : currentTime - lastUpdate
        lastUpdate = currentTime
        performUpdate(deltaTime: deltaTime)
    }
    #endif
    
    private func performUpdate(deltaTime: Double) {
        // Emit new particles
        emitParticles(deltaTime: deltaTime)
        
        // Update existing particles
        updateParticles(deltaTime: deltaTime)
        
        // Apply forces
        applyForces()
        
        // Remove dead particles
        particles.removeAll { $0.age >= $0.lifetime }
    }
    
    private func emitParticles(deltaTime: Double) {
        let count = Int(configuration.emissionRate * deltaTime)
        for _ in 0..<count {
            if particles.count < configuration.maxParticles {
                particles.append(createParticle(at: randomEmissionPoint()))
            }
        }
    }
    
    private func updateParticles(deltaTime: Double) {
        for i in particles.indices {
            var p = particles[i]
            
            // Apply gravity
            p.velocity.x += configuration.gravity.x * deltaTime
            p.velocity.y += configuration.gravity.y * deltaTime
            
            // Apply drag
            p.velocity.x *= 1 - configuration.drag
            p.velocity.y *= 1 - configuration.drag
            
            // Update position
            p.position.x += p.velocity.x * deltaTime
            p.position.y += p.velocity.y * deltaTime
            
            // Update age
            p.age += deltaTime
            
            particles[i] = p
        }
    }
    
    private func applyForces() {
        // Apply attraction
        if let point = attractionPoint {
            for i in particles.indices {
                let dx = point.x - particles[i].position.x
                let dy = point.y - particles[i].position.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist < attractionRadius && dist > 1 {
                    let force = attractionStrength / (dist * dist) * 0.1
                    particles[i].velocity.x += dx / dist * force
                    particles[i].velocity.y += dy / dist * force
                }
            }
        }
        
        // Apply repulsion
        if let point = repulsionPoint {
            for i in particles.indices {
                let dx = particles[i].position.x - point.x
                let dy = particles[i].position.y - point.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist < repulsionRadius && dist > 1 {
                    let force = repulsionStrength / (dist * dist) * 0.1
                    particles[i].velocity.x += dx / dist * force
                    particles[i].velocity.y += dy / dist * force
                }
            }
        }
    }
    
    private func randomEmissionPoint() -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 0...bounds.width),
            y: CGFloat.random(in: 0...bounds.height * 0.1)
        )
    }
    
    private func createParticle(at position: CGPoint) -> Particle {
        let lifetime = Double.random(in: configuration.lifetimeRange)
        let speed = Double.random(in: configuration.speedRange)
        let angle = configuration.emissionAngle + Double.random(in: -configuration.spreadAngle/2...configuration.spreadAngle/2)
        let color = configuration.colorPalette.randomElement() ?? .white
        let size = Double.random(in: configuration.sizeRange)
        
        return Particle(
            position: Vector2D(x: position.x, y: position.y),
            velocity: Vector2D(x: cos(angle) * speed, y: sin(angle) * speed),
            color: color,
            lifetime: lifetime,
            size: CGSize(width: size, height: size)
        )
    }
    
    // MARK: - Interaction Methods
    
    public func applyAttraction(at point: CGPoint, radius: CGFloat, strength: CGFloat) {
        attractionPoint = point
        attractionRadius = radius
        attractionStrength = strength
    }
    
    public func applyRepulsion(at point: CGPoint, radius: CGFloat, strength: CGFloat) {
        repulsionPoint = point
        repulsionRadius = radius
        repulsionStrength = strength
    }
    
    public func applyTurbulence(at point: CGPoint, radius: CGFloat, strength: CGFloat) {
        for i in particles.indices {
            let dx = particles[i].position.x - point.x
            let dy = particles[i].position.y - point.y
            let dist = sqrt(dx * dx + dy * dy)
            
            if dist < radius {
                let noise = CGFloat.random(in: -1...1) * strength * 0.01
                particles[i].velocity.x += noise
                particles[i].velocity.y += noise
            }
        }
    }
    
    public func clearForces() {
        attractionPoint = nil
        repulsionPoint = nil
    }
    
    public func burst(at point: CGPoint, count: Int) {
        for _ in 0..<count {
            if particles.count < configuration.maxParticles {
                var particle = createParticle(at: point)
                let angle = CGFloat.random(in: 0...(.pi * 2))
                let speed = CGFloat.random(in: 100...300)
                particle.velocity = Vector2D(x: cos(angle) * speed, y: sin(angle) * speed)
                particles.append(particle)
            }
        }
    }
    
    public func emitParticles(at point: CGPoint, count: Int) {
        for _ in 0..<count {
            if particles.count < configuration.maxParticles {
                particles.append(createParticle(at: point))
            }
        }
    }
    
    public func emitContinuous(at point: CGPoint, rate: Int) {
        let count = max(1, rate / 60)
        emitParticles(at: point, count: count)
    }
}
