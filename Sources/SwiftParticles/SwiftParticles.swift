// SwiftParticles.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

/// SwiftParticles - A GPU-accelerated particle system for SwiftUI
///
/// SwiftParticles provides high-performance particle effects for iOS, macOS,
/// tvOS, watchOS, and visionOS applications. Create stunning visual effects
/// like confetti, snow, fire, smoke, and more with minimal code.
///
/// ## Quick Start
/// ```swift
/// import SwiftParticles
///
/// // Using a preset
/// ParticleView(preset: .confetti)
///
/// // Using view modifier
/// Text("Congratulations!")
///     .confetti(isActive: $showConfetti)
/// ```
///
/// ## Topics
///
/// ### Core Components
/// - ``ParticleSystem``
/// - ``ParticleEmitter``
/// - ``ParticleConfiguration``
/// - ``Particle``
///
/// ### Emitters
/// - ``PointEmitter``
/// - ``LineEmitter``
/// - ``CircleEmitter``
/// - ``RectangleEmitter``
/// - ``CustomShapeEmitter``
///
/// ### Forces
/// - ``Force``
/// - ``GravityForce``
/// - ``WindForce``
/// - ``TurbulenceForce``
/// - ``AttractorForce``
/// - ``VortexForce``
///
/// ### Behaviors
/// - ``ParticleBehavior``
/// - ``FadeOutBehavior``
/// - ``ScaleBehavior``
/// - ``ColorBehavior``
/// - ``RotationBehavior``
///
/// ### SwiftUI Views
/// - ``ParticleView``
/// - ``ParticleOverlay``
///
/// ### Presets
/// - ``ParticlePreset``

// Re-export all public types for convenience
@_exported import Foundation
@_exported import SwiftUI
