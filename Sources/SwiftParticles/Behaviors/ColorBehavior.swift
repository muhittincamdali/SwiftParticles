// ColorBehavior.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation

// MARK: - ColorBehavior

/// A behavior that changes particle color over its lifetime.
///
/// `ColorBehavior` transitions particle colors through a gradient or between
/// specific colors. Useful for fire (yellow to red), ice (white to blue),
/// or rainbow effects.
///
/// ## Usage Example
/// ```swift
/// // Fire gradient
/// let fire = ColorBehavior.gradient([.yellow, .orange, .red])
///
/// // Simple color transition
/// let transition = ColorBehavior(
///     startColor: .white,
///     endColor: .blue
/// )
///
/// // Rainbow cycling
/// let rainbow = ColorBehavior.rainbow()
/// ```
public final class ColorBehavior: BaseBehavior {
    
    // MARK: - Properties
    
    /// Starting color for simple transitions.
    public var startColor: ParticleColor?
    
    /// Ending color for simple transitions.
    public var endColor: ParticleColor?
    
    /// Gradient colors with positions (0-1).
    public var gradientStops: [(color: ParticleColor, position: Double)]
    
    /// Whether to use HSB interpolation (smoother for hue changes).
    public var useHSBInterpolation: Bool = false
    
    /// Whether to preserve original color's brightness.
    public var preserveBrightness: Bool = false
    
    /// Whether to preserve original color's alpha.
    public var preserveAlpha: Bool = false
    
    /// Whether to cycle through colors repeatedly.
    public var cycleColors: Bool = false
    
    /// Number of color cycles over lifetime.
    public var cycleCount: Double = 1.0
    
    /// Random color variation amount (0-1).
    public var colorVariation: Double = 0
    
    // MARK: - Initialization
    
    /// Creates a color behavior with start and end colors.
    /// - Parameters:
    ///   - startColor: Initial color.
    ///   - endColor: Final color.
    ///   - easing: Easing function.
    public init(
        startColor: ParticleColor,
        endColor: ParticleColor,
        easing: EasingFunction = .linear
    ) {
        self.startColor = startColor
        self.endColor = endColor
        self.gradientStops = []
        super.init()
        self.easing = easing
    }
    
    /// Creates a color behavior with a gradient.
    /// - Parameter colors: Gradient colors (evenly distributed).
    public init(colors: [ParticleColor]) {
        self.gradientStops = []
        super.init()
        
        guard !colors.isEmpty else { return }
        
        if colors.count == 1 {
            gradientStops = [(colors[0], 0.0), (colors[0], 1.0)]
        } else {
            for (index, color) in colors.enumerated() {
                let position = Double(index) / Double(colors.count - 1)
                gradientStops.append((color, position))
            }
        }
    }
    
    /// Creates a color behavior with explicit gradient stops.
    /// - Parameter stops: Array of (color, position) tuples.
    public init(stops: [(color: ParticleColor, position: Double)]) {
        self.gradientStops = stops.sorted { $0.position < $1.position }
        super.init()
    }
    
    // MARK: - Behavior Application
    
    public override func apply(to particle: inout Particle, deltaTime: Double) {
        guard shouldApply(to: particle) else { return }
        
        var progress = calculateProgress(for: particle)
        
        // Handle color cycling
        if cycleColors {
            progress = (progress * cycleCount).truncatingRemainder(dividingBy: 1.0)
        }
        
        let newColor: ParticleColor
        
        if !gradientStops.isEmpty {
            newColor = sampleGradient(at: progress)
        } else if let start = startColor, let end = endColor {
            if useHSBInterpolation {
                newColor = interpolateHSB(from: start, to: end, t: progress)
            } else {
                newColor = start.lerp(to: end, t: progress)
            }
        } else {
            return
        }
        
        // Apply the new color
        var finalColor = newColor
        
        // Add random variation
        if colorVariation > 0 {
            let variation = colorVariation
            finalColor = ParticleColor(
                red: finalColor.red + Double.random(in: -variation...variation),
                green: finalColor.green + Double.random(in: -variation...variation),
                blue: finalColor.blue + Double.random(in: -variation...variation),
                alpha: finalColor.alpha
            )
        }
        
        // Preserve original properties if requested
        if preserveBrightness {
            let originalBrightness = particle.birthColor.luminance
            let currentBrightness = finalColor.luminance
            if currentBrightness > 0 {
                let ratio = originalBrightness / currentBrightness
                finalColor = ParticleColor(
                    red: finalColor.red * ratio,
                    green: finalColor.green * ratio,
                    blue: finalColor.blue * ratio,
                    alpha: finalColor.alpha
                )
            }
        }
        
        if preserveAlpha {
            finalColor = finalColor.withAlpha(particle.birthColor.alpha)
        }
        
        particle.color = finalColor
    }
    
    // MARK: - Private Methods
    
    /// Samples the gradient at a specific position.
    private func sampleGradient(at position: Double) -> ParticleColor {
        guard !gradientStops.isEmpty else { return .white }
        
        let clampedPos = max(0, min(1, position))
        
        // Find surrounding stops
        var lowerStop = gradientStops[0]
        var upperStop = gradientStops[gradientStops.count - 1]
        
        for stop in gradientStops {
            if stop.position <= clampedPos {
                lowerStop = stop
            }
            if stop.position >= clampedPos {
                upperStop = stop
                break
            }
        }
        
        // Interpolate between stops
        let range = upperStop.position - lowerStop.position
        if range <= 0 {
            return lowerStop.color
        }
        
        let t = (clampedPos - lowerStop.position) / range
        
        if useHSBInterpolation {
            return interpolateHSB(from: lowerStop.color, to: upperStop.color, t: t)
        } else {
            return lowerStop.color.lerp(to: upperStop.color, t: t)
        }
    }
    
    /// Interpolates colors in HSB space.
    private func interpolateHSB(
        from: ParticleColor,
        to: ParticleColor,
        t: Double
    ) -> ParticleColor {
        // Convert to HSB
        let (h1, s1, b1) = rgbToHsb(from.red, from.green, from.blue)
        let (h2, s2, b2) = rgbToHsb(to.red, to.green, to.blue)
        
        // Interpolate hue (take shortest path around color wheel)
        var hDiff = h2 - h1
        if hDiff > 0.5 { hDiff -= 1 }
        if hDiff < -0.5 { hDiff += 1 }
        let h = (h1 + hDiff * t).truncatingRemainder(dividingBy: 1.0)
        let hNormalized = h < 0 ? h + 1 : h
        
        let s = s1 + (s2 - s1) * t
        let b = b1 + (b2 - b1) * t
        let a = from.alpha + (to.alpha - from.alpha) * t
        
        return ParticleColor(hue: hNormalized, saturation: s, brightness: b, alpha: a)
    }
    
    /// Converts RGB to HSB.
    private func rgbToHsb(_ r: Double, _ g: Double, _ b: Double) -> (h: Double, s: Double, b: Double) {
        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let delta = maxVal - minVal
        
        var h: Double = 0
        let s: Double = maxVal == 0 ? 0 : delta / maxVal
        let brightness = maxVal
        
        if delta > 0 {
            if maxVal == r {
                h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            } else if maxVal == g {
                h = (b - r) / delta + 2
            } else {
                h = (r - g) / delta + 4
            }
            h /= 6
            if h < 0 { h += 1 }
        }
        
        return (h, s, brightness)
    }
}

// MARK: - Factory Methods

extension ColorBehavior {
    
    /// Creates a gradient color behavior.
    /// - Parameter colors: Colors in the gradient.
    public static func gradient(_ colors: [ParticleColor]) -> ColorBehavior {
        ColorBehavior(colors: colors)
    }
    
    /// Creates a fire color gradient (yellow -> orange -> red).
    public static var fire: ColorBehavior {
        gradient([.yellow, .orange, .red, .red.darkened(by: 0.3)])
    }
    
    /// Creates an ice color gradient (white -> light blue -> blue).
    public static var ice: ColorBehavior {
        gradient([.white, .cyan, .blue])
    }
    
    /// Creates a smoke color gradient (white -> gray -> dark gray).
    public static var smoke: ColorBehavior {
        gradient([
            ParticleColor(red: 0.9, green: 0.9, blue: 0.9),
            ParticleColor(red: 0.6, green: 0.6, blue: 0.6),
            ParticleColor(red: 0.3, green: 0.3, blue: 0.3)
        ])
    }
    
    /// Creates a rainbow color behavior.
    /// - Parameter cycles: Number of color cycles over lifetime.
    public static func rainbow(cycles: Double = 1.0) -> ColorBehavior {
        let colors: [ParticleColor] = [
            .red, .orange, .yellow, .green, .blue, .purple, .red
        ]
        let behavior = ColorBehavior(colors: colors)
        behavior.useHSBInterpolation = true
        behavior.cycleColors = cycles > 1
        behavior.cycleCount = cycles
        return behavior
    }
    
    /// Creates a plasma/energy color gradient.
    public static var plasma: ColorBehavior {
        let behavior = gradient([.cyan, .purple, .pink, .cyan])
        behavior.useHSBInterpolation = true
        return behavior
    }
    
    /// Creates a sunset color gradient.
    public static var sunset: ColorBehavior {
        gradient([.yellow, .orange, .red, .purple])
    }
    
    /// Creates a nature/leaf color gradient.
    public static var nature: ColorBehavior {
        gradient([.green, .yellow, .orange, .red])
    }
}

// MARK: - Builder Methods

extension ColorBehavior {
    
    /// Uses HSB interpolation for smoother hue transitions.
    /// - Returns: Self for chaining.
    @discardableResult
    public func usingHSBInterpolation() -> Self {
        useHSBInterpolation = true
        return self
    }
    
    /// Enables color cycling.
    /// - Parameter count: Number of cycles over lifetime.
    /// - Returns: Self for chaining.
    @discardableResult
    public func cycling(_ count: Double = 1.0) -> Self {
        cycleColors = true
        cycleCount = count
        return self
    }
    
    /// Adds random color variation.
    /// - Parameter amount: Variation amount (0-1).
    /// - Returns: Self for chaining.
    @discardableResult
    public func withVariation(_ amount: Double) -> Self {
        colorVariation = amount
        return self
    }
}
