// ParticleAnimation.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - ParticleAnimation

/// Provides animation utilities for particle systems.
///
/// `ParticleAnimation` includes interpolation functions, timing curves,
/// and animation helpers for creating smooth particle effects.
public enum ParticleAnimation {
    
    // MARK: - Interpolation
    
    /// Linearly interpolates between two values.
    /// - Parameters:
    ///   - from: Start value.
    ///   - to: End value.
    ///   - t: Interpolation factor (0-1).
    /// - Returns: Interpolated value.
    public static func lerp(_ from: Double, _ to: Double, t: Double) -> Double {
        from + (to - from) * clamp(t, min: 0, max: 1)
    }
    
    /// Smoothly interpolates using smooth step.
    /// - Parameters:
    ///   - from: Start value.
    ///   - to: End value.
    ///   - t: Interpolation factor (0-1).
    /// - Returns: Smoothly interpolated value.
    public static func smoothStep(_ from: Double, _ to: Double, t: Double) -> Double {
        let clamped = clamp(t, min: 0, max: 1)
        let smooth = clamped * clamped * (3 - 2 * clamped)
        return from + (to - from) * smooth
    }
    
    /// Even smoother interpolation using smoother step.
    /// - Parameters:
    ///   - from: Start value.
    ///   - to: End value.
    ///   - t: Interpolation factor (0-1).
    /// - Returns: Very smoothly interpolated value.
    public static func smootherStep(_ from: Double, _ to: Double, t: Double) -> Double {
        let clamped = clamp(t, min: 0, max: 1)
        let smoother = clamped * clamped * clamped * (clamped * (clamped * 6 - 15) + 10)
        return from + (to - from) * smoother
    }
    
    /// Inverse lerp - finds t given a value between from and to.
    /// - Parameters:
    ///   - from: Start value.
    ///   - to: End value.
    ///   - value: Value to find t for.
    /// - Returns: The t value (0-1).
    public static func inverseLerp(_ from: Double, _ to: Double, value: Double) -> Double {
        guard to != from else { return 0 }
        return clamp((value - from) / (to - from), min: 0, max: 1)
    }
    
    /// Remaps a value from one range to another.
    /// - Parameters:
    ///   - value: Input value.
    ///   - fromMin: Input range minimum.
    ///   - fromMax: Input range maximum.
    ///   - toMin: Output range minimum.
    ///   - toMax: Output range maximum.
    /// - Returns: Remapped value.
    public static func remap(
        _ value: Double,
        from fromMin: Double,
        _ fromMax: Double,
        to toMin: Double,
        _ toMax: Double
    ) -> Double {
        let t = inverseLerp(fromMin, fromMax, value: value)
        return lerp(toMin, toMax, t: t)
    }
    
    // MARK: - Clamping
    
    /// Clamps a value to a range.
    /// - Parameters:
    ///   - value: Value to clamp.
    ///   - min: Minimum value.
    ///   - max: Maximum value.
    /// - Returns: Clamped value.
    public static func clamp(_ value: Double, min minVal: Double, max maxVal: Double) -> Double {
        Swift.min(Swift.max(value, minVal), maxVal)
    }
    
    /// Clamps a value to 0-1 range.
    /// - Parameter value: Value to clamp.
    /// - Returns: Clamped value.
    public static func clamp01(_ value: Double) -> Double {
        clamp(value, min: 0, max: 1)
    }
    
    // MARK: - Timing Functions
    
    /// Ping-pong a value between 0 and 1.
    /// - Parameter t: Time value.
    /// - Returns: Value that bounces between 0 and 1.
    public static func pingPong(_ t: Double) -> Double {
        let normalized = t.truncatingRemainder(dividingBy: 2)
        return normalized <= 1 ? normalized : 2 - normalized
    }
    
    /// Creates a repeating value between 0 and 1.
    /// - Parameter t: Time value.
    /// - Returns: Repeating value (0-1).
    public static func repeat01(_ t: Double) -> Double {
        t.truncatingRemainder(dividingBy: 1)
    }
    
    /// Creates a step function (0 or 1).
    /// - Parameters:
    ///   - value: Input value.
    ///   - threshold: Step threshold.
    /// - Returns: 0 if below threshold, 1 if at or above.
    public static func step(_ value: Double, threshold: Double) -> Double {
        value < threshold ? 0 : 1
    }
    
    // MARK: - Curves
    
    /// Evaluates a quadratic bezier curve.
    /// - Parameters:
    ///   - p0: Start point.
    ///   - p1: Control point.
    ///   - p2: End point.
    ///   - t: Time (0-1).
    /// - Returns: Point on curve.
    public static func quadraticBezier(
        p0: Double,
        p1: Double,
        p2: Double,
        t: Double
    ) -> Double {
        let oneMinusT = 1 - t
        return oneMinusT * oneMinusT * p0 +
               2 * oneMinusT * t * p1 +
               t * t * p2
    }
    
    /// Evaluates a cubic bezier curve.
    /// - Parameters:
    ///   - p0: Start point.
    ///   - p1: First control point.
    ///   - p2: Second control point.
    ///   - p3: End point.
    ///   - t: Time (0-1).
    /// - Returns: Point on curve.
    public static func cubicBezier(
        p0: Double,
        p1: Double,
        p2: Double,
        p3: Double,
        t: Double
    ) -> Double {
        let oneMinusT = 1 - t
        let oneMinusT2 = oneMinusT * oneMinusT
        let oneMinusT3 = oneMinusT2 * oneMinusT
        let t2 = t * t
        let t3 = t2 * t
        
        return oneMinusT3 * p0 +
               3 * oneMinusT2 * t * p1 +
               3 * oneMinusT * t2 * p2 +
               t3 * p3
    }
    
    /// Evaluates a Catmull-Rom spline.
    /// - Parameters:
    ///   - p0: Point before start.
    ///   - p1: Start point.
    ///   - p2: End point.
    ///   - p3: Point after end.
    ///   - t: Time (0-1).
    /// - Returns: Point on spline.
    public static func catmullRom(
        p0: Double,
        p1: Double,
        p2: Double,
        p3: Double,
        t: Double
    ) -> Double {
        let t2 = t * t
        let t3 = t2 * t
        
        return 0.5 * (
            (2 * p1) +
            (-p0 + p2) * t +
            (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
            (-p0 + 3 * p1 - 3 * p2 + p3) * t3
        )
    }
    
    // MARK: - Oscillation
    
    /// Creates a sine wave oscillation.
    /// - Parameters:
    ///   - time: Current time.
    ///   - frequency: Oscillation frequency.
    ///   - amplitude: Oscillation amplitude.
    ///   - phase: Phase offset.
    /// - Returns: Oscillation value.
    public static func sine(
        time: Double,
        frequency: Double = 1,
        amplitude: Double = 1,
        phase: Double = 0
    ) -> Double {
        sin(time * frequency * .pi * 2 + phase) * amplitude
    }
    
    /// Creates a cosine wave oscillation.
    public static func cosine(
        time: Double,
        frequency: Double = 1,
        amplitude: Double = 1,
        phase: Double = 0
    ) -> Double {
        cos(time * frequency * .pi * 2 + phase) * amplitude
    }
    
    /// Creates a triangle wave oscillation.
    public static func triangle(
        time: Double,
        frequency: Double = 1,
        amplitude: Double = 1
    ) -> Double {
        let period = 1.0 / frequency
        let phase = (time / period).truncatingRemainder(dividingBy: 1)
        return (abs(phase * 4 - 2) - 1) * amplitude
    }
    
    /// Creates a sawtooth wave oscillation.
    public static func sawtooth(
        time: Double,
        frequency: Double = 1,
        amplitude: Double = 1
    ) -> Double {
        let period = 1.0 / frequency
        let phase = (time / period).truncatingRemainder(dividingBy: 1)
        return (phase * 2 - 1) * amplitude
    }
    
    /// Creates a square wave oscillation.
    public static func square(
        time: Double,
        frequency: Double = 1,
        amplitude: Double = 1
    ) -> Double {
        sine(time: time, frequency: frequency) >= 0 ? amplitude : -amplitude
    }
    
    // MARK: - Noise
    
    /// Simple 1D noise function.
    /// - Parameter x: Input value.
    /// - Returns: Pseudo-random value between -1 and 1.
    public static func noise1D(_ x: Double) -> Double {
        let xi = Int(floor(x)) & 255
        let xf = x - floor(x)
        
        let u = xf * xf * (3 - 2 * xf)
        
        let a = hash(xi)
        let b = hash(xi + 1)
        
        return lerp(Double(a) / 127.5 - 1, Double(b) / 127.5 - 1, t: u)
    }
    
    /// Simple hash function for noise.
    private static func hash(_ n: Int) -> Int {
        var x = n
        x = ((x >> 16) ^ x) &* 0x45d9f3b
        x = ((x >> 16) ^ x) &* 0x45d9f3b
        x = (x >> 16) ^ x
        return x & 255
    }
    
    // MARK: - Spring Animation
    
    /// Calculates spring animation value.
    /// - Parameters:
    ///   - time: Current time.
    ///   - target: Target value.
    ///   - current: Current value.
    ///   - velocity: Current velocity.
    ///   - stiffness: Spring stiffness.
    ///   - damping: Damping ratio.
    /// - Returns: Tuple of new position and velocity.
    public static func spring(
        time: Double,
        target: Double,
        current: Double,
        velocity: inout Double,
        stiffness: Double = 100,
        damping: Double = 10
    ) -> Double {
        let displacement = current - target
        let springForce = -stiffness * displacement
        let dampingForce = -damping * velocity
        let acceleration = springForce + dampingForce
        
        velocity += acceleration * time
        return current + velocity * time
    }
}

// MARK: - Animation Curve

/// A custom animation curve defined by keyframes.
public struct AnimationCurve: Sendable {
    
    /// Keyframes defining the curve (time: value pairs).
    public let keyframes: [(time: Double, value: Double)]
    
    /// Creates an animation curve from keyframes.
    /// - Parameter keyframes: Dictionary of time-value pairs.
    public init(_ keyframes: [Double: Double]) {
        self.keyframes = keyframes.sorted { $0.key < $1.key }.map { ($0.key, $0.value) }
    }
    
    /// Evaluates the curve at a given time.
    /// - Parameter time: Time value (0-1).
    /// - Returns: Interpolated value.
    public func evaluate(at time: Double) -> Double {
        guard !keyframes.isEmpty else { return 0 }
        guard keyframes.count > 1 else { return keyframes[0].value }
        
        let clampedTime = ParticleAnimation.clamp01(time)
        
        // Find surrounding keyframes
        var lower = keyframes[0]
        var upper = keyframes[keyframes.count - 1]
        
        for keyframe in keyframes {
            if keyframe.time <= clampedTime {
                lower = keyframe
            }
            if keyframe.time >= clampedTime {
                upper = keyframe
                break
            }
        }
        
        // Interpolate
        let range = upper.time - lower.time
        if range <= 0 { return lower.value }
        
        let t = (clampedTime - lower.time) / range
        return ParticleAnimation.lerp(lower.value, upper.value, t: t)
    }
}
