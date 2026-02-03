// TurbulenceForce.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - TurbulenceForce

/// A force that applies procedural noise-based turbulence to particles.
///
/// `TurbulenceForce` uses Perlin-like noise to create organic, chaotic movement.
/// This is ideal for effects like smoke, fire, water, or any natural phenomena
/// where particles should move unpredictably.
///
/// ## Usage Example
/// ```swift
/// // Simple turbulence
/// let turbulence = TurbulenceForce(strength: 50)
///
/// // Detailed turbulence with octaves
/// let detailed = TurbulenceForce(strength: 80, frequency: 0.01, octaves: 4)
/// ```
public final class TurbulenceForce: BaseForce {
    
    // MARK: - Properties
    
    /// Base frequency of the noise (higher = more detailed).
    public var frequency: Double
    
    /// Number of noise octaves (more = more detail but slower).
    public var octaves: Int {
        didSet { octaves = max(1, min(octaves, 8)) }
    }
    
    /// How much each octave contributes relative to the previous.
    public var persistence: Double
    
    /// How much the frequency increases per octave.
    public var lacunarity: Double
    
    /// Offset for animating the noise field over time.
    public var timeOffset: Double = 0
    
    /// Speed at which the noise field evolves.
    public var evolutionSpeed: Double = 1.0
    
    /// Current time accumulator.
    private var currentTime: Double = 0
    
    /// Seed for the noise function.
    public var seed: Int
    
    /// Whether turbulence is 3D (using time as third dimension).
    public var is3D: Bool = true
    
    /// Scale factor for position input to noise function.
    public var spatialScale: Double = 1.0
    
    /// Permutation table for noise generation.
    private var permutation: [Int] = []
    
    // MARK: - Initialization
    
    /// Creates a turbulence force with the specified parameters.
    /// - Parameters:
    ///   - strength: Maximum force strength.
    ///   - frequency: Base noise frequency.
    ///   - octaves: Number of noise octaves.
    ///   - seed: Random seed for noise.
    public init(
        strength: Double = 50,
        frequency: Double = 0.01,
        octaves: Int = 3,
        seed: Int = 0
    ) {
        self.frequency = frequency
        self.octaves = max(1, min(octaves, 8))
        self.persistence = 0.5
        self.lacunarity = 2.0
        self.seed = seed
        super.init(strength: strength)
        
        initializePermutation()
    }
    
    // MARK: - Force Calculation
    
    public override func calculateForce(for particle: Particle, deltaTime: Double) -> Vector2D {
        guard shouldApply(to: particle) else { return .zero }
        
        // Update time
        currentTime += deltaTime * evolutionSpeed
        
        // Sample noise at particle position
        let x = particle.position.x * frequency * spatialScale
        let y = particle.position.y * frequency * spatialScale
        let z = is3D ? (currentTime + timeOffset) * frequency : 0
        
        // Calculate turbulence using fractal Brownian motion (fBm)
        var noiseX: Double = 0
        var noiseY: Double = 0
        var amplitude: Double = 1
        var freq: Double = 1
        var maxValue: Double = 0
        
        for _ in 0..<octaves {
            // Offset for Y noise to get different pattern
            let offsetX = sampleNoise(x: x * freq, y: y * freq, z: z * freq)
            let offsetY = sampleNoise(x: x * freq + 100, y: y * freq + 100, z: z * freq)
            
            noiseX += offsetX * amplitude
            noiseY += offsetY * amplitude
            
            maxValue += amplitude
            amplitude *= persistence
            freq *= lacunarity
        }
        
        // Normalize to -1...1 range
        noiseX /= maxValue
        noiseY /= maxValue
        
        // Create force vector
        var force = Vector2D(x: noiseX * strength, y: noiseY * strength)
        
        // Apply bounds fade
        let fadeMult = boundsFadeMultiplier(for: particle)
        force = force * fadeMult
        
        return force
    }
    
    // MARK: - Noise Functions
    
    /// Initializes the permutation table for noise generation.
    private func initializePermutation() {
        var perm = Array(0..<256)
        
        // Fisher-Yates shuffle with seed
        var rng = SeededRandomGenerator(seed: UInt64(seed))
        for i in stride(from: 255, to: 0, by: -1) {
            let j = Int(rng.next() % UInt64(i + 1))
            perm.swapAt(i, j)
        }
        
        // Duplicate for wrapping
        permutation = perm + perm
    }
    
    /// Samples the noise function at the given coordinates.
    private func sampleNoise(x: Double, y: Double, z: Double) -> Double {
        // Find unit cube containing point
        let xi = Int(floor(x)) & 255
        let yi = Int(floor(y)) & 255
        let zi = Int(floor(z)) & 255
        
        // Find relative position in cube
        let xf = x - floor(x)
        let yf = y - floor(y)
        let zf = z - floor(z)
        
        // Compute fade curves
        let u = fade(xf)
        let v = fade(yf)
        let w = fade(zf)
        
        // Hash coordinates of cube corners
        let a = permutation[xi] + yi
        let aa = permutation[a] + zi
        let ab = permutation[a + 1] + zi
        let b = permutation[xi + 1] + yi
        let ba = permutation[b] + zi
        let bb = permutation[b + 1] + zi
        
        // Blend results from 8 corners
        return lerp(w,
            lerp(v,
                lerp(u, grad(permutation[aa], xf, yf, zf),
                     grad(permutation[ba], xf - 1, yf, zf)),
                lerp(u, grad(permutation[ab], xf, yf - 1, zf),
                     grad(permutation[bb], xf - 1, yf - 1, zf))),
            lerp(v,
                lerp(u, grad(permutation[aa + 1], xf, yf, zf - 1),
                     grad(permutation[ba + 1], xf - 1, yf, zf - 1)),
                lerp(u, grad(permutation[ab + 1], xf, yf - 1, zf - 1),
                     grad(permutation[bb + 1], xf - 1, yf - 1, zf - 1))))
    }
    
    /// Fade function for smooth interpolation.
    private func fade(_ t: Double) -> Double {
        t * t * t * (t * (t * 6 - 15) + 10)
    }
    
    /// Linear interpolation.
    private func lerp(_ t: Double, _ a: Double, _ b: Double) -> Double {
        a + t * (b - a)
    }
    
    /// Gradient function for Perlin noise.
    private func grad(_ hash: Int, _ x: Double, _ y: Double, _ z: Double) -> Double {
        let h = hash & 15
        let u = h < 8 ? x : y
        let v = h < 4 ? y : (h == 12 || h == 14 ? x : z)
        return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v)
    }
    
    // MARK: - Configuration
    
    /// Sets the noise detail level.
    /// - Parameters:
    ///   - octaves: Number of octaves.
    ///   - persistence: Amplitude decay per octave.
    ///   - lacunarity: Frequency increase per octave.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withDetail(
        octaves: Int = 3,
        persistence: Double = 0.5,
        lacunarity: Double = 2.0
    ) -> Self {
        self.octaves = octaves
        self.persistence = persistence
        self.lacunarity = lacunarity
        return self
    }
    
    /// Sets the evolution speed.
    /// - Parameter speed: How fast the turbulence changes over time.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withEvolution(speed: Double) -> Self {
        evolutionSpeed = speed
        return self
    }
    
    public override func reset() {
        currentTime = 0
    }
}

// MARK: - SeededRandomGenerator

/// A simple seeded random number generator for deterministic noise.
private struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }
    
    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

// MARK: - Factory Methods

extension TurbulenceForce {
    
    /// Creates gentle smoke-like turbulence.
    public static var smoke: TurbulenceForce {
        let turbulence = TurbulenceForce(strength: 30, frequency: 0.005, octaves: 4)
        turbulence.evolutionSpeed = 0.5
        return turbulence
    }
    
    /// Creates energetic fire-like turbulence.
    public static var fire: TurbulenceForce {
        let turbulence = TurbulenceForce(strength: 80, frequency: 0.02, octaves: 3)
        turbulence.evolutionSpeed = 2.0
        return turbulence
    }
    
    /// Creates subtle water-like turbulence.
    public static var water: TurbulenceForce {
        let turbulence = TurbulenceForce(strength: 40, frequency: 0.008, octaves: 5)
        turbulence.evolutionSpeed = 0.3
        turbulence.persistence = 0.6
        return turbulence
    }
    
    /// Creates chaotic explosion-like turbulence.
    public static var chaos: TurbulenceForce {
        let turbulence = TurbulenceForce(strength: 150, frequency: 0.03, octaves: 2)
        turbulence.evolutionSpeed = 5.0
        return turbulence
    }
}
