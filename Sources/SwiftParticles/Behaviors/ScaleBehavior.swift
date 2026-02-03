// ScaleBehavior.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ScaleBehavior

/// A behavior that changes particle scale over its lifetime.
///
/// `ScaleBehavior` smoothly transitions particle scale from an initial
/// value to a final value. Useful for growing/shrinking effects.
///
/// ## Usage Example
/// ```swift
/// // Shrink over lifetime
/// let shrink = ScaleBehavior(startScale: 1.0, endScale: 0.0)
///
/// // Grow then shrink
/// let growShrink = ScaleBehavior.growThenShrink(peakScale: 1.5)
///
/// // Pulse effect
/// let pulse = ScaleBehavior.pulsing(frequency: 4.0, amplitude: 0.3)
/// ```
public final class ScaleBehavior: BaseBehavior {
    
    // MARK: - Properties
    
    /// Starting scale value.
    public var startScale: Double
    
    /// Ending scale value.
    public var endScale: Double
    
    /// Whether to preserve the particle's original scale.
    public var preserveOriginalScale: Bool
    
    /// Whether to scale width and height independently.
    public var uniformScaling: Bool = true
    
    /// Horizontal scale multiplier (when non-uniform).
    public var widthScale: Double = 1.0
    
    /// Vertical scale multiplier (when non-uniform).
    public var heightScale: Double = 1.0
    
    /// Pulse settings for breathing/pulsing effects.
    public var pulseEnabled: Bool = false
    
    /// Pulse amplitude (as fraction of scale).
    public var pulseAmplitude: Double = 0.2
    
    /// Pulse frequency (oscillations per second).
    public var pulseFrequency: Double = 2.0
    
    /// Whether pulse dampens over lifetime.
    public var pulseDamping: Bool = true
    
    // MARK: - Initialization
    
    /// Creates a scale behavior with the specified parameters.
    /// - Parameters:
    ///   - startScale: Initial scale (default: 1.0).
    ///   - endScale: Final scale (default: 0.0).
    ///   - easing: Easing function for the transition.
    ///   - preserveOriginalScale: Whether to multiply by original scale.
    public init(
        startScale: Double = 1.0,
        endScale: Double = 0.0,
        easing: EasingFunction = .easeOut,
        preserveOriginalScale: Bool = true
    ) {
        self.startScale = startScale
        self.endScale = endScale
        self.preserveOriginalScale = preserveOriginalScale
        super.init()
        self.easing = easing
    }
    
    // MARK: - Behavior Application
    
    public override func apply(to particle: inout Particle, deltaTime: Double) {
        guard shouldApply(to: particle) else { return }
        
        let progress = calculateProgress(for: particle)
        var scale = startScale + (endScale - startScale) * progress
        
        // Apply pulse
        if pulseEnabled {
            var amplitude = pulseAmplitude
            
            if pulseDamping {
                amplitude *= (1.0 - progress)
            }
            
            let pulse = sin(particle.age * pulseFrequency * .pi * 2) * amplitude
            scale += pulse
        }
        
        // Preserve original scale
        if preserveOriginalScale {
            scale *= particle.birthScale
        }
        
        // Ensure non-negative scale
        scale = max(0, scale)
        
        if uniformScaling {
            particle.scale = scale
        } else {
            // Non-uniform scaling affects size directly
            let baseWidth = particle.size.width / particle.scale
            let baseHeight = particle.size.height / particle.scale
            particle.size = CGSize(
                width: baseWidth * scale * widthScale,
                height: baseHeight * scale * heightScale
            )
            particle.scale = 1.0  // Reset scale since we modified size
        }
    }
}

// MARK: - Factory Methods

extension ScaleBehavior {
    
    /// Creates a behavior that shrinks particles to nothing.
    public static var shrink: ScaleBehavior {
        ScaleBehavior(startScale: 1.0, endScale: 0.0, easing: .easeIn)
    }
    
    /// Creates a behavior that grows particles.
    /// - Parameter maxScale: Maximum scale to reach.
    public static func grow(to maxScale: Double = 2.0) -> ScaleBehavior {
        ScaleBehavior(startScale: 0.5, endScale: maxScale, easing: .easeOut)
    }
    
    /// Creates a behavior that grows then shrinks.
    /// - Parameters:
    ///   - peakScale: Scale at the midpoint.
    ///   - peakTime: When peak occurs (0-1).
    public static func growThenShrink(
        peakScale: Double = 1.5,
        peakTime: Double = 0.3
    ) -> ScaleBehavior {
        let behavior = ScaleBehavior(startScale: 0.5, endScale: 0.0)
        behavior.pingPong = true
        behavior.startScale = 0.5
        behavior.endScale = peakScale
        return behavior
    }
    
    /// Creates a pulsing scale behavior.
    /// - Parameters:
    ///   - frequency: Pulse frequency.
    ///   - amplitude: Pulse amplitude.
    public static func pulsing(
        frequency: Double = 2.0,
        amplitude: Double = 0.3
    ) -> ScaleBehavior {
        let behavior = ScaleBehavior(startScale: 1.0, endScale: 1.0)
        behavior.pulseEnabled = true
        behavior.pulseFrequency = frequency
        behavior.pulseAmplitude = amplitude
        return behavior
    }
    
    /// Creates a breathing scale effect.
    public static var breathing: ScaleBehavior {
        pulsing(frequency: 1.5, amplitude: 0.2)
    }
    
    /// Creates a pop-in effect (starts small, pops to full size).
    public static var popIn: ScaleBehavior {
        let behavior = ScaleBehavior(startScale: 0.0, endScale: 1.0, easing: .easeOutBack)
        behavior.endAge = 0.2
        return behavior
    }
    
    /// Creates a stretch effect (elongates horizontally).
    /// - Parameter stretch: Amount of horizontal stretch.
    public static func stretch(amount: Double = 2.0) -> ScaleBehavior {
        let behavior = ScaleBehavior(startScale: 1.0, endScale: 1.0)
        behavior.uniformScaling = false
        behavior.widthScale = amount
        behavior.heightScale = 1.0 / sqrt(amount)  // Preserve area
        return behavior
    }
}

// MARK: - Builder Methods

extension ScaleBehavior {
    
    /// Enables pulsing effect.
    /// - Parameters:
    ///   - amplitude: Pulse amplitude.
    ///   - frequency: Pulse frequency.
    ///   - damping: Whether to dampen over time.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withPulse(
        amplitude: Double = 0.2,
        frequency: Double = 2.0,
        damping: Bool = true
    ) -> Self {
        pulseEnabled = true
        pulseAmplitude = amplitude
        pulseFrequency = frequency
        pulseDamping = damping
        return self
    }
    
    /// Sets non-uniform scaling.
    /// - Parameters:
    ///   - width: Width scale multiplier.
    ///   - height: Height scale multiplier.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withNonUniformScale(width: Double, height: Double) -> Self {
        uniformScaling = false
        widthScale = width
        heightScale = height
        return self
    }
}
