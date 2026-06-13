import Foundation
import Metal

/// Main entry point for the high-performance SwiftParticles engine.
public enum SwiftParticles {
    public static let version = "2.0.0"
}

/// Represents a single particle in the system, optimized for SIMD operations.
public struct Particle: Sendable {
    public var position: SIMD2<Float>
    public var velocity: SIMD2<Float>
    public var color: SIMD4<Float>
    public var size: Float
    public var life: Float
    
    public init(position: SIMD2<Float> = .zero, velocity: SIMD2<Float> = .zero, color: SIMD4<Float> = [1, 1, 1, 1], size: Float = 1.0, life: Float = 1.0) {
        self.position = position
        self.velocity = velocity
        self.color = color
        self.size = size
        self.life = life
    }
}
