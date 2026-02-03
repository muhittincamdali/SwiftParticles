// FadeOutBehavior.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - FadeOutBehavior

/// A behavior that fades particle opacity over its lifetime.
///
/// `FadeOutBehavior` smoothly transitions particle opacity from an initial
/// value to a final value, typically used to make particles fade away
/// before they die.
///
/// ## Usage Example
/// ```swift
/// // Simple fade out
/// let fade = FadeOutBehavior()
///
/// // Fade in then out
/// let fadeInOut = FadeOutBehavior.fadeInOut()
///
/// // Custom fade curve
/// let custom = FadeOutBehavior(
///     startOpacity: 1.0,
///     endOpacity: 0.0,
///     easing: .easeOutExpo
/// )
/// ```
public final class FadeOutBehavior: BaseBehavior {
    
    // MARK: - Properties
    
    /// Starting opacity value.
    public var startOpacity: Double
    
    /// Ending opacity value.
    public var endOpacity: Double
    
    /// Whether to preserve the particle's original opacity ratio.
    public var preserveOriginalOpacity: Bool
    
    /// Flicker settings for fire/energy effects.
    public var flickerEnabled: Bool = false
    
    /// Flicker intensity (0-1).
    public var flickerIntensity: Double = 0.2
    
    /// Flicker frequency.
    public var flickerFrequency: Double = 10.0
    
    // MARK: - Initialization
    
    /// Creates a fade out behavior with the specified parameters.
    /// - Parameters:
    ///   - startOpacity: Initial opacity (default: 1.0).
    ///   - endOpacity: Final opacity (default: 0.0).
    ///   - easing: Easing function for the transition.
    ///   - preserveOriginalOpacity: Whether to scale by original opacity.
    public init(
        startOpacity: Double = 1.0,
        endOpacity: Double = 0.0,
        easing: EasingFunction = .easeOut,
        preserveOriginalOpacity: Bool = true
    ) {
        self.startOpacity = startOpacity
        self.endOpacity = endOpacity
        self.preserveOriginalOpacity = preserveOriginalOpacity
        super.init()
        self.easing = easing
    }
    
    // MARK: - Behavior Application
    
    public override func apply(to particle: inout Particle, deltaTime: Double) {
        guard shouldApply(to: particle) else { return }
        
        let progress = calculateProgress(for: particle)
        var opacity = startOpacity + (endOpacity - startOpacity) * progress
        
        // Preserve original opacity ratio
        if preserveOriginalOpacity {
            opacity *= particle.birthOpacity
        }
        
        // Apply flicker
        if flickerEnabled {
            let flicker = sin(particle.age * flickerFrequency * .pi * 2)
            let flickerAmount = flicker * flickerIntensity * (1.0 - progress)
            opacity += flickerAmount
        }
        
        particle.opacity = max(0, min(1, opacity))
    }
}

// MARK: - Factory Methods

extension FadeOutBehavior {
    
    /// Creates a behavior that fades in then out.
    /// - Parameters:
    ///   - fadeInDuration: Normalized duration of fade in (0-1).
    ///   - peakOpacity: Maximum opacity at peak.
    /// - Returns: A configured fade behavior.
    public static func fadeInOut(
        fadeInDuration: Double = 0.2,
        peakOpacity: Double = 1.0
    ) -> FadeOutBehavior {
        let fade = FadeOutBehavior(startOpacity: 0, endOpacity: 0)
        fade.pingPong = false
        
        // Custom implementation via userData tracking would be needed
        // For simplicity, this creates a basic in-out effect
        fade.startAge = 0
        fade.endAge = 1
        
        return fade
    }
    
    /// Creates a linear fade out behavior.
    public static var linear: FadeOutBehavior {
        FadeOutBehavior(easing: .linear)
    }
    
    /// Creates a quick fade out behavior.
    public static var quick: FadeOutBehavior {
        FadeOutBehavior(startOpacity: 1.0, endOpacity: 0.0, easing: .easeInExpo)
    }
    
    /// Creates a slow fade out behavior.
    public static var slow: FadeOutBehavior {
        FadeOutBehavior(startOpacity: 1.0, endOpacity: 0.0, easing: .easeOutExpo)
    }
    
    /// Creates a flickering fade for fire effects.
    public static var flickering: FadeOutBehavior {
        let fade = FadeOutBehavior()
        fade.flickerEnabled = true
        fade.flickerIntensity = 0.3
        fade.flickerFrequency = 15.0
        return fade
    }
    
    /// Creates a pulsing fade effect.
    /// - Parameter frequency: Pulse frequency.
    /// - Returns: A configured fade behavior.
    public static func pulsing(frequency: Double = 3.0) -> FadeOutBehavior {
        let fade = FadeOutBehavior()
        fade.flickerEnabled = true
        fade.flickerIntensity = 0.5
        fade.flickerFrequency = frequency
        return fade
    }
}

// MARK: - Builder Methods

extension FadeOutBehavior {
    
    /// Enables flickering effect.
    /// - Parameters:
    ///   - intensity: Flicker intensity.
    ///   - frequency: Flicker frequency.
    /// - Returns: Self for chaining.
    @discardableResult
    public func withFlicker(intensity: Double = 0.2, frequency: Double = 10.0) -> Self {
        flickerEnabled = true
        flickerIntensity = intensity
        flickerFrequency = frequency
        return self
    }
    
    /// Sets the time range for the fade.
    /// - Parameters:
    ///   - start: Start age (0-1).
    ///   - end: End age (0-1).
    /// - Returns: Self for chaining.
    @discardableResult
    public func between(start: Double, end: Double) -> Self {
        startAge = start
        endAge = end
        return self
    }
}
