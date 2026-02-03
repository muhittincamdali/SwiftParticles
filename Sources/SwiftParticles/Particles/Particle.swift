// Particle.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - Particle

/// Represents a single particle in the system with position, velocity, and visual properties.
///
/// Each particle maintains its own state including physical properties (position, velocity,
/// acceleration) and visual properties (color, opacity, size, rotation). Particles are
/// updated each frame by the particle system.
///
/// ## Creating Particles
/// ```swift
/// let particle = Particle(
///     position: Vector2D(x: 100, y: 100),
///     velocity: Vector2D(x: 50, y: -100),
///     lifetime: 2.0,
///     color: .orange
/// )
/// ```
public struct Particle: Identifiable, Sendable {
    
    // MARK: - Properties
    
    /// Unique identifier for this particle instance.
    public let id: UUID
    
    /// Current position in 2D space.
    public var position: Vector2D
    
    /// Current velocity vector (points per second).
    public var velocity: Vector2D
    
    /// Current acceleration vector (points per second squared).
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
    
    /// Initial position when the particle was created.
    public let birthPosition: Vector2D
    
    /// Initial velocity when the particle was created.
    public let birthVelocity: Vector2D
    
    /// Initial color when the particle was created.
    public let birthColor: ParticleColor
    
    /// Initial scale when the particle was created.
    public let birthScale: Double
    
    /// Initial opacity when the particle was created.
    public let birthOpacity: Double
    
    /// Trail positions for particles with trails enabled.
    public var trailPositions: [Vector2D]
    
    /// Maximum number of trail positions to store.
    public var maxTrailLength: Int
    
    /// Custom texture name for this particle.
    public var textureName: String?
    
    /// Custom user data dictionary for extensions.
    public var userData: [String: Double]
    
    // MARK: - Computed Properties
    
    /// Whether this particle is still active.
    public var isAlive: Bool {
        age < lifetime && opacity > 0.001
    }
    
    /// Normalized age from 0 (born) to 1 (end of life).
    public var normalizedAge: Double {
        min(age / lifetime, 1.0)
    }
    
    /// Remaining lifetime in seconds.
    public var remainingLifetime: Double {
        max(lifetime - age, 0)
    }
    
    /// Current speed (magnitude of velocity).
    public var speed: Double {
        velocity.magnitude
    }
    
    /// Direction of movement in radians.
    public var direction: Double {
        atan2(velocity.y, velocity.x)
    }
    
    /// The scaled size of the particle.
    public var scaledSize: CGSize {
        CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
    }
    
    /// Bounding rectangle for collision detection.
    public var bounds: CGRect {
        CGRect(
            x: position.x - scaledSize.width / 2,
            y: position.y - scaledSize.height / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )
    }
    
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
    ///   - maxTrailLength: Maximum trail positions to store.
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
        shape: ParticleShape = .circle,
        maxTrailLength: Int = 10
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
        self.birthPosition = position
        self.birthVelocity = velocity
        self.birthColor = color
        self.birthScale = scale
        self.birthOpacity = opacity
        self.trailPositions = []
        self.maxTrailLength = maxTrailLength
        self.textureName = nil
        self.userData = [:]
    }
    
    // MARK: - Update
    
    /// Advances the particle by the given time step.
    /// - Parameter deltaTime: Time elapsed in seconds.
    public mutating func update(deltaTime: Double) {
        // Store position in trail
        if maxTrailLength > 0 {
            trailPositions.insert(position, at: 0)
            if trailPositions.count > maxTrailLength {
                trailPositions.removeLast()
            }
        }
        
        // Update physics
        velocity = velocity + acceleration * deltaTime
        position = position + velocity * deltaTime
        rotation += angularVelocity * deltaTime
        age += deltaTime
    }
    
    /// Applies a force to this particle based on its mass.
    /// - Parameter force: The force vector to apply.
    public mutating func applyForce(_ force: Vector2D) {
        guard mass > 0 else { return }
        let accel = force / mass
        acceleration = acceleration + accel
    }
    
    /// Applies an impulse directly to velocity.
    /// - Parameter impulse: The impulse vector to apply.
    public mutating func applyImpulse(_ impulse: Vector2D) {
        guard mass > 0 else { return }
        velocity = velocity + impulse / mass
    }
    
    /// Resets acceleration to zero. Call at the start of each physics step.
    public mutating func resetForces() {
        acceleration = .zero
    }
    
    /// Clears the trail history.
    public mutating func clearTrail() {
        trailPositions.removeAll()
    }
    
    /// Kills the particle immediately.
    public mutating func kill() {
        age = lifetime
        opacity = 0
    }
    
    // MARK: - State Management
    
    /// Sets a custom user data value.
    /// - Parameters:
    ///   - value: The value to store.
    ///   - key: The key to store it under.
    public mutating func setUserData(_ value: Double, forKey key: String) {
        userData[key] = value
    }
    
    /// Gets a custom user data value.
    /// - Parameter key: The key to retrieve.
    /// - Returns: The stored value, or nil if not found.
    public func getUserData(forKey key: String) -> Double? {
        userData[key]
    }
    
    /// Resets the particle to its birth state.
    public mutating func resetToBirthState() {
        position = birthPosition
        velocity = birthVelocity
        color = birthColor
        scale = birthScale
        opacity = birthOpacity
        age = 0
        acceleration = .zero
        trailPositions.removeAll()
    }
}

// MARK: - Particle Copying

extension Particle {
    
    /// Creates a copy of this particle with a new ID.
    /// - Returns: A new particle with the same properties.
    public func copy() -> Particle {
        var newParticle = Particle(
            position: position,
            velocity: velocity,
            acceleration: acceleration,
            rotation: rotation,
            angularVelocity: angularVelocity,
            scale: scale,
            opacity: opacity,
            color: color,
            lifetime: lifetime,
            mass: mass,
            size: size,
            shape: shape,
            maxTrailLength: maxTrailLength
        )
        newParticle.age = age
        newParticle.textureName = textureName
        newParticle.userData = userData
        return newParticle
    }
}

// MARK: - ParticleShape

/// Defines the visual shape of a particle.
public enum ParticleShape: String, CaseIterable, Sendable, Hashable {
    /// A filled circle.
    case circle
    /// A filled square.
    case square
    /// A filled equilateral triangle.
    case triangle
    /// A five-pointed star.
    case star
    /// A diamond/rhombus shape.
    case diamond
    /// A heart shape.
    case heart
    /// A spark/line shape oriented to velocity.
    case spark
    /// A ring/hollow circle.
    case ring
    /// A simple line.
    case line
    /// A snowflake shape.
    case snowflake
    /// A raindrop shape.
    case raindrop
    /// A leaf shape.
    case leaf
    /// A custom shape using an image.
    case custom
}

// MARK: - ParticleColor

/// Represents a color for particles with convenient presets and utilities.
public struct ParticleColor: Sendable, Equatable, Hashable {
    
    /// Red component (0.0 - 1.0).
    public let red: Double
    
    /// Green component (0.0 - 1.0).
    public let green: Double
    
    /// Blue component (0.0 - 1.0).
    public let blue: Double
    
    /// Alpha component (0.0 - 1.0).
    public let alpha: Double
    
    // MARK: - Initialization
    
    /// Creates a particle color from RGBA components.
    /// - Parameters:
    ///   - red: Red component (0.0 - 1.0).
    ///   - green: Green component (0.0 - 1.0).
    ///   - blue: Blue component (0.0 - 1.0).
    ///   - alpha: Alpha component (0.0 - 1.0).
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = min(max(red, 0), 1)
        self.green = min(max(green, 0), 1)
        self.blue = min(max(blue, 0), 1)
        self.alpha = min(max(alpha, 0), 1)
    }
    
    /// Creates a particle color from a hex string.
    /// - Parameter hex: Hex color string (e.g., "#FF5500" or "FF5500").
    public init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        if hexString.count == 8 {
            // RGBA
            self.red = Double((rgb & 0xFF000000) >> 24) / 255.0
            self.green = Double((rgb & 0x00FF0000) >> 16) / 255.0
            self.blue = Double((rgb & 0x0000FF00) >> 8) / 255.0
            self.alpha = Double(rgb & 0x000000FF) / 255.0
        } else {
            // RGB
            self.red = Double((rgb & 0xFF0000) >> 16) / 255.0
            self.green = Double((rgb & 0x00FF00) >> 8) / 255.0
            self.blue = Double(rgb & 0x0000FF) / 255.0
            self.alpha = 1.0
        }
    }
    
    /// Creates a particle color from HSB components.
    /// - Parameters:
    ///   - hue: Hue value (0.0 - 1.0).
    ///   - saturation: Saturation value (0.0 - 1.0).
    ///   - brightness: Brightness value (0.0 - 1.0).
    ///   - alpha: Alpha value (0.0 - 1.0).
    public init(hue: Double, saturation: Double, brightness: Double, alpha: Double = 1.0) {
        let h = hue * 6.0
        let s = saturation
        let v = brightness
        
        let i = Int(h)
        let f = h - Double(i)
        let p = v * (1.0 - s)
        let q = v * (1.0 - s * f)
        let t = v * (1.0 - s * (1.0 - f))
        
        switch i % 6 {
        case 0:
            self.red = v; self.green = t; self.blue = p
        case 1:
            self.red = q; self.green = v; self.blue = p
        case 2:
            self.red = p; self.green = v; self.blue = t
        case 3:
            self.red = p; self.green = q; self.blue = v
        case 4:
            self.red = t; self.green = p; self.blue = v
        default:
            self.red = v; self.green = p; self.blue = q
        }
        self.alpha = alpha
    }
    
    // MARK: - Presets
    
    /// Pure white color.
    public static let white = ParticleColor(red: 1, green: 1, blue: 1)
    /// Pure black color.
    public static let black = ParticleColor(red: 0, green: 0, blue: 0)
    /// Bright red color.
    public static let red = ParticleColor(red: 1, green: 0.2, blue: 0.15)
    /// Vibrant orange color.
    public static let orange = ParticleColor(red: 1, green: 0.6, blue: 0.1)
    /// Bright yellow color.
    public static let yellow = ParticleColor(red: 1, green: 0.95, blue: 0.2)
    /// Fresh green color.
    public static let green = ParticleColor(red: 0.2, green: 0.9, blue: 0.3)
    /// Sky blue color.
    public static let blue = ParticleColor(red: 0.2, green: 0.5, blue: 1.0)
    /// Rich purple color.
    public static let purple = ParticleColor(red: 0.7, green: 0.3, blue: 0.95)
    /// Soft pink color.
    public static let pink = ParticleColor(red: 1.0, green: 0.4, blue: 0.7)
    /// Cyan/aqua color.
    public static let cyan = ParticleColor(red: 0.2, green: 0.9, blue: 0.95)
    /// Golden yellow color.
    public static let gold = ParticleColor(red: 1.0, green: 0.84, blue: 0.0)
    /// Silver/gray color.
    public static let silver = ParticleColor(red: 0.75, green: 0.75, blue: 0.75)
    /// Bronze color.
    public static let bronze = ParticleColor(red: 0.8, green: 0.5, blue: 0.2)
    /// Transparent (invisible).
    public static let clear = ParticleColor(red: 0, green: 0, blue: 0, alpha: 0)
    
    // MARK: - Random Generation
    
    /// Generates a random color with full alpha.
    public static func random() -> ParticleColor {
        ParticleColor(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
    /// Generates a random bright color.
    public static func randomBright() -> ParticleColor {
        ParticleColor(
            hue: Double.random(in: 0...1),
            saturation: Double.random(in: 0.7...1.0),
            brightness: Double.random(in: 0.8...1.0)
        )
    }
    
    /// Generates a random pastel color.
    public static func randomPastel() -> ParticleColor {
        ParticleColor(
            hue: Double.random(in: 0...1),
            saturation: Double.random(in: 0.2...0.5),
            brightness: Double.random(in: 0.8...1.0)
        )
    }
    
    // MARK: - Color Operations
    
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
    
    /// Returns a brightened version of this color.
    /// - Parameter amount: Brightness increase (0.0 - 1.0).
    /// - Returns: A brighter color.
    public func brightened(by amount: Double) -> ParticleColor {
        ParticleColor(
            red: min(red + amount, 1),
            green: min(green + amount, 1),
            blue: min(blue + amount, 1),
            alpha: alpha
        )
    }
    
    /// Returns a darkened version of this color.
    /// - Parameter amount: Darkness increase (0.0 - 1.0).
    /// - Returns: A darker color.
    public func darkened(by amount: Double) -> ParticleColor {
        ParticleColor(
            red: max(red - amount, 0),
            green: max(green - amount, 0),
            blue: max(blue - amount, 0),
            alpha: alpha
        )
    }
    
    /// Returns a version of this color with the specified alpha.
    /// - Parameter alpha: New alpha value.
    /// - Returns: Color with new alpha.
    public func withAlpha(_ alpha: Double) -> ParticleColor {
        ParticleColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /// Returns the grayscale luminance of this color.
    public var luminance: Double {
        0.299 * red + 0.587 * green + 0.114 * blue
    }
    
    // MARK: - Conversion
    
    /// Converts to SwiftUI Color.
    public var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    /// Converts to an array of floats [R, G, B, A] for Metal shaders.
    public var floatArray: [Float] {
        [Float(red), Float(green), Float(blue), Float(alpha)]
    }
}
