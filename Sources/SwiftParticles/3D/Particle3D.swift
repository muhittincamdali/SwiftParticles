// Particle3D.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import simd

// MARK: - Vector3D

/// A 3D vector for particle physics.
public struct Vector3D: Codable, Hashable, Sendable {
    public var x: CGFloat
    public var y: CGFloat
    public var z: CGFloat
    
    public static let zero = Vector3D(x: 0, y: 0, z: 0)
    
    public init(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public var length: CGFloat {
        sqrt(x * x + y * y + z * z)
    }
    
    public var normalized: Vector3D {
        let len = length
        guard len > 0 else { return .zero }
        return Vector3D(x: x / len, y: y / len, z: z / len)
    }
    
    public static func + (lhs: Vector3D, rhs: Vector3D) -> Vector3D {
        Vector3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    public static func - (lhs: Vector3D, rhs: Vector3D) -> Vector3D {
        Vector3D(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    public static func * (lhs: Vector3D, rhs: CGFloat) -> Vector3D {
        Vector3D(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    public static func dot(_ a: Vector3D, _ b: Vector3D) -> CGFloat {
        a.x * b.x + a.y * b.y + a.z * b.z
    }
    
    public static func cross(_ a: Vector3D, _ b: Vector3D) -> Vector3D {
        Vector3D(
            x: a.y * b.z - a.z * b.y,
            y: a.z * b.x - a.x * b.z,
            z: a.x * b.y - a.y * b.x
        )
    }
}

// MARK: - Particle3D

/// A 3D particle with full spatial properties.
public struct Particle3D: Identifiable, Hashable, Sendable {
    public let id: UUID
    
    /// 3D position in world space.
    public var position: Vector3D
    
    /// 3D velocity vector.
    public var velocity: Vector3D
    
    /// 3D acceleration vector.
    public var acceleration: Vector3D
    
    /// Particle color with alpha.
    public var color: ParticleColor
    
    /// Particle size/scale.
    public var size: CGFloat
    
    /// 3D rotation (Euler angles: pitch, yaw, roll).
    public var rotation: Vector3D
    
    /// Angular velocity for rotation.
    public var angularVelocity: Vector3D
    
    /// Total lifetime in seconds.
    public var lifetime: Double
    
    /// Current age in seconds.
    public var age: Double
    
    /// Custom data for shader effects.
    public var userData: [String: Double]
    
    public init(
        id: UUID = UUID(),
        position: Vector3D = .zero,
        velocity: Vector3D = .zero,
        acceleration: Vector3D = .zero,
        color: ParticleColor = .white,
        size: CGFloat = 10,
        rotation: Vector3D = .zero,
        angularVelocity: Vector3D = .zero,
        lifetime: Double = 1,
        age: Double = 0,
        userData: [String: Double] = [:]
    ) {
        self.id = id
        self.position = position
        self.velocity = velocity
        self.acceleration = acceleration
        self.color = color
        self.size = size
        self.rotation = rotation
        self.angularVelocity = angularVelocity
        self.lifetime = lifetime
        self.age = age
        self.userData = userData
    }
    
    /// Normalized age (0 = just born, 1 = about to die).
    public var normalizedAge: Double {
        min(1, max(0, age / lifetime))
    }
    
    /// Whether the particle is still alive.
    public var isAlive: Bool {
        age < lifetime
    }
}

// MARK: - Particle3DConfiguration

/// Configuration for 3D particle systems.
public struct Particle3DConfiguration: Sendable {
    
    // MARK: - Emission
    
    /// Particles per second.
    public var emissionRate: Double = 50
    
    /// Maximum particles.
    public var maxParticles: Int = 1000
    
    /// Burst count on trigger.
    public var burstCount: Int = 0
    
    /// Emission duration.
    public var duration: Double = .infinity
    
    /// Particle lifetime range.
    public var lifetimeRange: ClosedRange<Double> = 1.0...3.0
    
    // MARK: - 3D Emission Shape
    
    /// 3D emission shape.
    public var emissionShape: EmissionShape3D = .point
    
    /// Emission direction (normalized).
    public var emissionDirection: Vector3D = Vector3D(x: 0, y: 1, z: 0)
    
    /// Spread cone angle in radians.
    public var spreadAngle: CGFloat = .pi / 4
    
    // MARK: - Velocity
    
    /// Speed range.
    public var speedRange: ClosedRange<CGFloat> = 50...150
    
    /// Velocity randomness factor.
    public var velocityRandomness: CGFloat = 0.2
    
    // MARK: - Visual
    
    /// Size range.
    public var sizeRange: ClosedRange<CGFloat> = 5...15
    
    /// Color palette.
    public var colorPalette: [ParticleColor] = [.white]
    
    /// Size over lifetime curve.
    public var sizeOverLifetime: [Double: Double] = [0: 1.0, 1.0: 0.0]
    
    /// Color over lifetime.
    public var colorOverLifetime: [Double: ParticleColor]?
    
    /// Opacity over lifetime.
    public var opacityOverLifetime: [Double: Double]?
    
    // MARK: - 3D Rotation
    
    /// Initial rotation range (Euler).
    public var rotationRange: ClosedRange<CGFloat> = 0...(.pi * 2)
    
    /// Angular velocity range.
    public var angularVelocityRange: ClosedRange<CGFloat> = -1...1
    
    // MARK: - Physics
    
    /// 3D gravity.
    public var gravity: Vector3D = Vector3D(x: 0, y: -98, z: 0)
    
    /// Drag coefficient.
    public var drag: CGFloat = 0.02
    
    /// Turbulence strength.
    public var turbulence: CGFloat = 0
    
    // MARK: - Billboard
    
    /// Billboard mode for rendering.
    public var billboardMode: BillboardMode = .viewFacing
    
    public init() {}
}

// MARK: - Emission Shape 3D

/// 3D emission shapes.
public enum EmissionShape3D: Codable, Sendable {
    case point
    case sphere(radius: CGFloat)
    case hemisphere(radius: CGFloat)
    case box(width: CGFloat, height: CGFloat, depth: CGFloat)
    case cylinder(radius: CGFloat, height: CGFloat)
    case cone(radius: CGFloat, height: CGFloat)
    case torus(majorRadius: CGFloat, minorRadius: CGFloat)
    
    /// Generates a random point within the shape.
    public func randomPoint() -> Vector3D {
        switch self {
        case .point:
            return .zero
            
        case .sphere(let radius):
            let u = CGFloat.random(in: 0...1)
            let v = CGFloat.random(in: 0...1)
            let theta = u * 2 * .pi
            let phi = acos(2 * v - 1)
            let r = radius * pow(CGFloat.random(in: 0...1), 1/3)
            return Vector3D(
                x: r * sin(phi) * cos(theta),
                y: r * sin(phi) * sin(theta),
                z: r * cos(phi)
            )
            
        case .hemisphere(let radius):
            let u = CGFloat.random(in: 0...1)
            let v = CGFloat.random(in: 0...0.5)
            let theta = u * 2 * .pi
            let phi = acos(2 * v - 1)
            let r = radius * pow(CGFloat.random(in: 0...1), 1/3)
            return Vector3D(
                x: r * sin(phi) * cos(theta),
                y: abs(r * cos(phi)),
                z: r * sin(phi) * sin(theta)
            )
            
        case .box(let width, let height, let depth):
            return Vector3D(
                x: CGFloat.random(in: -width/2...width/2),
                y: CGFloat.random(in: -height/2...height/2),
                z: CGFloat.random(in: -depth/2...depth/2)
            )
            
        case .cylinder(let radius, let height):
            let angle = CGFloat.random(in: 0...2 * .pi)
            let r = radius * sqrt(CGFloat.random(in: 0...1))
            return Vector3D(
                x: r * cos(angle),
                y: CGFloat.random(in: -height/2...height/2),
                z: r * sin(angle)
            )
            
        case .cone(let radius, let height):
            let y = CGFloat.random(in: 0...height)
            let currentRadius = radius * (1 - y / height)
            let angle = CGFloat.random(in: 0...2 * .pi)
            let r = currentRadius * sqrt(CGFloat.random(in: 0...1))
            return Vector3D(
                x: r * cos(angle),
                y: y,
                z: r * sin(angle)
            )
            
        case .torus(let majorRadius, let minorRadius):
            let u = CGFloat.random(in: 0...2 * .pi)
            let v = CGFloat.random(in: 0...2 * .pi)
            return Vector3D(
                x: (majorRadius + minorRadius * cos(v)) * cos(u),
                y: minorRadius * sin(v),
                z: (majorRadius + minorRadius * cos(v)) * sin(u)
            )
        }
    }
}

// MARK: - Billboard Mode

/// How 3D particles face the camera.
public enum BillboardMode: String, Codable, Sendable {
    /// Always face the camera.
    case viewFacing
    
    /// Face camera but maintain vertical axis.
    case viewFacingVertical
    
    /// Use particle rotation (no billboarding).
    case none
    
    /// Stretch in velocity direction.
    case velocityAligned
}

// MARK: - Particle3DSystem

/// A 3D particle system manager.
@available(iOS 16.0, macOS 14.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
@MainActor
public final class Particle3DSystem: ObservableObject {
    
    @Published public private(set) var particles: [Particle3D] = []
    @Published public private(set) var state: ParticleSystemState = .stopped
    
    public var configuration: Particle3DConfiguration
    
    #if os(iOS) || os(tvOS)
    private var displayLink: CADisplayLink?
    #else
    private var timer: Timer?
    #endif
    private var lastUpdateTime: CFTimeInterval = 0
    private var emissionAccumulator: Double = 0
    
    public init(configuration: Particle3DConfiguration = Particle3DConfiguration()) {
        self.configuration = configuration
    }
    
    public func start() {
        state = .running
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
        state = .stopped
        #if os(iOS) || os(tvOS)
        displayLink?.invalidate()
        displayLink = nil
        #else
        timer?.invalidate()
        timer = nil
        #endif
    }
    
    #if os(macOS) || os(watchOS) || os(visionOS)
    private func timerUpdate() {
        guard state == .running else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 60.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        performUpdate(deltaTime: deltaTime)
    }
    #endif
    
    public func pause() {
        state = .paused
    }
    
    public func resume() {
        state = .running
    }
    
    public func clear() {
        particles.removeAll()
    }
    
    public func burst(at position: Vector3D? = nil, count: Int? = nil) {
        let burstCount = count ?? configuration.burstCount
        for _ in 0..<burstCount {
            if particles.count < configuration.maxParticles {
                particles.append(createParticle(at: position ?? .zero))
            }
        }
    }
    
    #if os(iOS) || os(tvOS)
    @objc private func update(_ link: CADisplayLink) {
        guard state == .running else { return }
        
        let currentTime = link.timestamp
        let deltaTime = lastUpdateTime == 0 ? 1.0 / 60.0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        performUpdate(deltaTime: deltaTime)
    }
    #endif
    
    private func performUpdate(deltaTime: Double) {
        // Emit particles
        emissionAccumulator += configuration.emissionRate * deltaTime
        while emissionAccumulator >= 1 && particles.count < configuration.maxParticles {
            particles.append(createParticle(at: .zero))
            emissionAccumulator -= 1
        }
        
        // Update particles
        for i in particles.indices {
            updateParticle(index: i, deltaTime: deltaTime)
        }
        
        // Remove dead particles
        particles.removeAll { !$0.isAlive }
    }
    
    private func createParticle(at basePosition: Vector3D) -> Particle3D {
        let emissionPoint = configuration.emissionShape.randomPoint()
        let position = basePosition + emissionPoint
        
        // Random direction within spread cone
        let speed = CGFloat.random(in: configuration.speedRange)
        let velocity = randomDirectionInCone(
            direction: configuration.emissionDirection,
            angle: configuration.spreadAngle
        ) * speed
        
        let lifetime = Double.random(in: configuration.lifetimeRange)
        let size = CGFloat.random(in: configuration.sizeRange)
        let color = configuration.colorPalette.randomElement() ?? .white
        
        return Particle3D(
            position: position,
            velocity: velocity,
            color: color,
            size: size,
            rotation: Vector3D(
                x: CGFloat.random(in: configuration.rotationRange),
                y: CGFloat.random(in: configuration.rotationRange),
                z: CGFloat.random(in: configuration.rotationRange)
            ),
            angularVelocity: Vector3D(
                x: CGFloat.random(in: configuration.angularVelocityRange),
                y: CGFloat.random(in: configuration.angularVelocityRange),
                z: CGFloat.random(in: configuration.angularVelocityRange)
            ),
            lifetime: lifetime
        )
    }
    
    private func updateParticle(index: Int, deltaTime: Double) {
        var p = particles[index]
        
        // Apply gravity
        p.velocity = p.velocity + configuration.gravity * deltaTime
        
        // Apply drag
        let dragFactor = 1 - configuration.drag
        p.velocity = p.velocity * dragFactor
        
        // Apply turbulence
        if configuration.turbulence > 0 {
            let noise = Vector3D(
                x: CGFloat.random(in: -1...1) * configuration.turbulence,
                y: CGFloat.random(in: -1...1) * configuration.turbulence,
                z: CGFloat.random(in: -1...1) * configuration.turbulence
            )
            p.velocity = p.velocity + noise * deltaTime
        }
        
        // Update position
        p.position = p.position + p.velocity * deltaTime
        
        // Update rotation
        p.rotation = p.rotation + p.angularVelocity * deltaTime
        
        // Update age
        p.age += deltaTime
        
        particles[index] = p
    }
    
    private func randomDirectionInCone(direction: Vector3D, angle: CGFloat) -> Vector3D {
        let cosAngle = cos(angle)
        let z = CGFloat.random(in: cosAngle...1)
        let phi = CGFloat.random(in: 0...2 * .pi)
        let sinTheta = sqrt(1 - z * z)
        
        let localDir = Vector3D(
            x: sinTheta * cos(phi),
            y: sinTheta * sin(phi),
            z: z
        )
        
        // Rotate to align with emission direction
        return rotateVector(localDir, toAlign: direction)
    }
    
    private func rotateVector(_ v: Vector3D, toAlign target: Vector3D) -> Vector3D {
        let up = Vector3D(x: 0, y: 0, z: 1)
        let axis = Vector3D.cross(up, target)
        let angle = acos(Vector3D.dot(up, target.normalized))
        
        if axis.length < 0.001 {
            return v
        }
        
        // Rodrigues rotation formula
        let k = axis.normalized
        let cosA = cos(angle)
        let sinA = sin(angle)
        
        let vRotated = v * cosA + Vector3D.cross(k, v) * sinA + k * Vector3D.dot(k, v) * (1 - cosA)
        return vRotated
    }
}
