// RenderConfiguration.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - RenderConfiguration

/// Configuration options for particle rendering.
///
/// `RenderConfiguration` controls how particles are rendered, including
/// blend modes, quality settings, and visual effects like trails and shadows.
public struct RenderConfiguration: Sendable {
    
    // MARK: - Rendering Mode
    
    /// The rendering engine to use.
    public var renderingEngine: RenderingEngine
    
    /// Blend mode for particle rendering.
    public var blendMode: ParticleBlendMode
    
    /// Whether to use antialiasing.
    public var antialiased: Bool
    
    /// Quality level for rendering.
    public var quality: RenderQuality
    
    // MARK: - Performance
    
    /// Target frame rate.
    public var targetFrameRate: Double
    
    /// Whether to skip frames when performance drops.
    public var adaptiveFrameRate: Bool
    
    /// Maximum particles to render per frame (0 = no limit).
    public var maxRenderParticles: Int
    
    /// Whether to sort particles by depth/age.
    public var sortParticles: Bool
    
    /// Sorting mode for particles.
    public var sortMode: ParticleSortMode
    
    // MARK: - Visual Effects
    
    /// Whether to render particle trails.
    public var trailsEnabled: Bool
    
    /// Number of trail segments.
    public var trailSegments: Int
    
    /// Trail width decay factor.
    public var trailWidthDecay: Double
    
    /// Trail opacity decay factor.
    public var trailOpacityDecay: Double
    
    /// Whether to render particle shadows.
    public var shadowsEnabled: Bool
    
    /// Shadow offset from particles.
    public var shadowOffset: CGSize
    
    /// Shadow blur radius.
    public var shadowBlur: Double
    
    /// Shadow opacity.
    public var shadowOpacity: Double
    
    /// Shadow color.
    public var shadowColor: ParticleColor
    
    /// Whether to apply bloom effect.
    public var bloomEnabled: Bool
    
    /// Bloom intensity (0-1).
    public var bloomIntensity: Double
    
    /// Bloom threshold (brightness above which bloom applies).
    public var bloomThreshold: Double
    
    // MARK: - Textures
    
    /// Custom texture for particles.
    public var customTexture: String?
    
    /// Texture filtering mode.
    public var textureFiltering: TextureFiltering
    
    /// Whether to use mipmaps for textures.
    public var useMipmaps: Bool
    
    // MARK: - Background
    
    /// Background color (nil for transparent).
    public var backgroundColor: ParticleColor?
    
    /// Whether to clear background each frame.
    public var clearBackground: Bool
    
    // MARK: - Debug
    
    /// Whether to show debug information.
    public var showDebugInfo: Bool
    
    /// Whether to show particle bounds.
    public var showBounds: Bool
    
    /// Whether to show velocity vectors.
    public var showVelocity: Bool
    
    // MARK: - Initialization
    
    /// Creates a default render configuration.
    public init(
        renderingEngine: RenderingEngine = .metal,
        blendMode: ParticleBlendMode = .additive,
        antialiased: Bool = true,
        quality: RenderQuality = .high
    ) {
        self.renderingEngine = renderingEngine
        self.blendMode = blendMode
        self.antialiased = antialiased
        self.quality = quality
        
        self.targetFrameRate = 60
        self.adaptiveFrameRate = true
        self.maxRenderParticles = 0
        self.sortParticles = false
        self.sortMode = .none
        
        self.trailsEnabled = false
        self.trailSegments = 10
        self.trailWidthDecay = 0.8
        self.trailOpacityDecay = 0.7
        
        self.shadowsEnabled = false
        self.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowBlur = 4
        self.shadowOpacity = 0.3
        self.shadowColor = .black
        
        self.bloomEnabled = false
        self.bloomIntensity = 0.5
        self.bloomThreshold = 0.8
        
        self.customTexture = nil
        self.textureFiltering = .linear
        self.useMipmaps = true
        
        self.backgroundColor = nil
        self.clearBackground = true
        
        self.showDebugInfo = false
        self.showBounds = false
        self.showVelocity = false
    }
}

// MARK: - RenderingEngine

/// The rendering engine to use for particles.
public enum RenderingEngine: String, CaseIterable, Sendable {
    /// Use Metal for GPU-accelerated rendering.
    case metal
    /// Use Core Animation layers.
    case coreAnimation
    /// Use SwiftUI Canvas.
    case canvas
    /// Automatic selection based on device capabilities.
    case automatic
}

// MARK: - RenderQuality

/// Quality levels for particle rendering.
public enum RenderQuality: String, CaseIterable, Sendable {
    /// Low quality for maximum performance.
    case low
    /// Medium quality balance.
    case medium
    /// High quality for best visuals.
    case high
    /// Ultra quality with all effects.
    case ultra
    
    /// Particle texture size for this quality level.
    public var textureSize: Int {
        switch self {
        case .low: return 32
        case .medium: return 64
        case .high: return 128
        case .ultra: return 256
        }
    }
    
    /// Maximum particles for this quality level.
    public var maxParticles: Int {
        switch self {
        case .low: return 500
        case .medium: return 2000
        case .high: return 5000
        case .ultra: return 10000
        }
    }
}

// MARK: - ParticleSortMode

/// How particles are sorted for rendering.
public enum ParticleSortMode: String, CaseIterable, Sendable {
    /// No sorting (fastest).
    case none
    /// Sort by age (oldest first).
    case oldestFirst
    /// Sort by age (youngest first).
    case youngestFirst
    /// Sort by size (smallest first).
    case smallestFirst
    /// Sort by size (largest first).
    case largestFirst
    /// Sort by distance from a point.
    case byDistance
}

// MARK: - TextureFiltering

/// Texture filtering modes.
public enum TextureFiltering: String, CaseIterable, Sendable {
    /// Nearest neighbor filtering (pixelated).
    case nearest
    /// Linear filtering (smooth).
    case linear
    /// Trilinear filtering with mipmaps.
    case trilinear
}

// MARK: - Configuration Presets

extension RenderConfiguration {
    
    /// Configuration optimized for performance.
    public static var performance: RenderConfiguration {
        var config = RenderConfiguration()
        config.quality = .low
        config.antialiased = false
        config.adaptiveFrameRate = true
        config.sortParticles = false
        config.trailsEnabled = false
        config.shadowsEnabled = false
        config.bloomEnabled = false
        return config
    }
    
    /// Configuration optimized for quality.
    public static var quality: RenderConfiguration {
        var config = RenderConfiguration()
        config.quality = .ultra
        config.antialiased = true
        config.sortParticles = true
        config.sortMode = .oldestFirst
        return config
    }
    
    /// Configuration with trails enabled.
    public static var withTrails: RenderConfiguration {
        var config = RenderConfiguration()
        config.trailsEnabled = true
        config.trailSegments = 15
        config.trailWidthDecay = 0.9
        config.trailOpacityDecay = 0.8
        return config
    }
    
    /// Configuration with glow/bloom effects.
    public static var glowing: RenderConfiguration {
        var config = RenderConfiguration()
        config.blendMode = .additive
        config.bloomEnabled = true
        config.bloomIntensity = 0.6
        config.bloomThreshold = 0.5
        return config
    }
    
    /// Configuration for debug visualization.
    public static var debug: RenderConfiguration {
        var config = RenderConfiguration()
        config.showDebugInfo = true
        config.showBounds = true
        config.showVelocity = true
        return config
    }
}

// MARK: - Builder Methods

extension RenderConfiguration {
    
    /// Enables trails with the specified parameters.
    /// - Parameters:
    ///   - segments: Number of trail segments.
    ///   - widthDecay: Width decay per segment.
    ///   - opacityDecay: Opacity decay per segment.
    /// - Returns: Modified configuration.
    public func withTrails(
        segments: Int = 10,
        widthDecay: Double = 0.8,
        opacityDecay: Double = 0.7
    ) -> RenderConfiguration {
        var config = self
        config.trailsEnabled = true
        config.trailSegments = segments
        config.trailWidthDecay = widthDecay
        config.trailOpacityDecay = opacityDecay
        return config
    }
    
    /// Enables shadows with the specified parameters.
    /// - Parameters:
    ///   - offset: Shadow offset.
    ///   - blur: Shadow blur radius.
    ///   - opacity: Shadow opacity.
    /// - Returns: Modified configuration.
    public func withShadows(
        offset: CGSize = CGSize(width: 0, height: 2),
        blur: Double = 4,
        opacity: Double = 0.3
    ) -> RenderConfiguration {
        var config = self
        config.shadowsEnabled = true
        config.shadowOffset = offset
        config.shadowBlur = blur
        config.shadowOpacity = opacity
        return config
    }
    
    /// Enables bloom effect.
    /// - Parameters:
    ///   - intensity: Bloom intensity.
    ///   - threshold: Brightness threshold for bloom.
    /// - Returns: Modified configuration.
    public func withBloom(
        intensity: Double = 0.5,
        threshold: Double = 0.8
    ) -> RenderConfiguration {
        var config = self
        config.bloomEnabled = true
        config.bloomIntensity = intensity
        config.bloomThreshold = threshold
        return config
    }
}
