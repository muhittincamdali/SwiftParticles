// ParticleModifier.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import SwiftUI

// MARK: - ParticleModifier

/// A view modifier that adds particle effects to any SwiftUI view.
///
/// Use this modifier to easily add particle effects as overlays or
/// backgrounds to existing views without changing their layout.
///
/// ## Usage Example
/// ```swift
/// Text("Congratulations!")
///     .particleEffect(.confetti, isActive: $showConfetti)
///
/// Button("Submit") { }
///     .particleEffect(.sparkle, trigger: submitCount)
/// ```
public struct ParticleModifier: ViewModifier {
    
    // MARK: - Properties
    
    /// The particle preset to use.
    let preset: ParticlePreset
    
    /// Whether the effect is currently active.
    @Binding var isActive: Bool
    
    /// Position of the particle layer.
    let position: ParticleLayerPosition
    
    /// Emitter position mode.
    let emitterPosition: EmitterPositionMode
    
    /// Duration before auto-stop (nil for continuous).
    let duration: TimeInterval?
    
    /// Whether to allow touch-through.
    let allowsHitTesting: Bool
    
    /// State for managing the particle system.
    @State private var particleSystem: ParticleSystem?
    
    // MARK: - Initialization
    
    /// Creates a particle modifier.
    /// - Parameters:
    ///   - preset: The particle preset.
    ///   - isActive: Binding controlling whether effect is active.
    ///   - position: Layer position (overlay/background).
    ///   - emitterPosition: Where to position the emitter.
    ///   - duration: Auto-stop duration (nil for continuous).
    ///   - allowsHitTesting: Whether particles respond to touches.
    public init(
        preset: ParticlePreset,
        isActive: Binding<Bool>,
        position: ParticleLayerPosition = .overlay,
        emitterPosition: EmitterPositionMode = .center,
        duration: TimeInterval? = nil,
        allowsHitTesting: Bool = false
    ) {
        self.preset = preset
        self._isActive = isActive
        self.position = position
        self.emitterPosition = emitterPosition
        self.duration = duration
        self.allowsHitTesting = allowsHitTesting
    }
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .modifier(ParticleLayerModifier(
                position: position,
                particle: particleLayer
            ))
            .onChange(of: isActive) { _, newValue in
                handleActiveChange(newValue)
            }
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var particleLayer: some View {
        if isActive {
            ParticleView(preset: preset, position: emitterPosition)
                .allowsHitTesting(allowsHitTesting)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleActiveChange(_ active: Bool) {
        if active {
            // Start auto-stop timer if duration is set
            if let duration = duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isActive = false
                }
            }
        }
    }
}

// MARK: - ParticleLayerModifier

/// Internal modifier for positioning particle layers.
private struct ParticleLayerModifier<Particle: View>: ViewModifier {
    let position: ParticleLayerPosition
    let particle: Particle
    
    func body(content: Content) -> some View {
        switch position {
        case .overlay:
            content.overlay(particle)
        case .background:
            content.background(particle)
        }
    }
}

// MARK: - ParticleLayerPosition

/// Position of the particle layer relative to content.
public enum ParticleLayerPosition: Sendable {
    /// Particles appear above the content.
    case overlay
    /// Particles appear behind the content.
    case background
}

// MARK: - View Extension

extension View {
    
    /// Adds a particle effect to the view.
    /// - Parameters:
    ///   - preset: The particle preset to use.
    ///   - isActive: Binding controlling whether effect is active.
    ///   - position: Layer position (overlay/background).
    ///   - emitterPosition: Where to position the emitter.
    ///   - duration: Auto-stop duration (nil for continuous).
    /// - Returns: The modified view.
    public func particleEffect(
        _ preset: ParticlePreset,
        isActive: Binding<Bool>,
        position: ParticleLayerPosition = .overlay,
        emitterPosition: EmitterPositionMode = .center,
        duration: TimeInterval? = nil
    ) -> some View {
        modifier(ParticleModifier(
            preset: preset,
            isActive: isActive,
            position: position,
            emitterPosition: emitterPosition,
            duration: duration
        ))
    }
    
    /// Adds a particle effect that triggers on value change.
    /// - Parameters:
    ///   - preset: The particle preset.
    ///   - trigger: Value that triggers the effect when changed.
    ///   - duration: How long the effect plays.
    ///   - position: Layer position.
    /// - Returns: The modified view.
    public func particleEffect<T: Equatable>(
        _ preset: ParticlePreset,
        trigger: T,
        duration: TimeInterval = 2.0,
        position: ParticleLayerPosition = .overlay
    ) -> some View {
        modifier(ParticleTriggerModifier(
            preset: preset,
            trigger: trigger,
            duration: duration,
            position: position
        ))
    }
    
    /// Adds a confetti celebration effect.
    /// - Parameters:
    ///   - isActive: Binding controlling the effect.
    ///   - duration: How long confetti falls.
    /// - Returns: The modified view.
    public func confetti(
        isActive: Binding<Bool>,
        duration: TimeInterval = 3.0
    ) -> some View {
        particleEffect(
            .confetti,
            isActive: isActive,
            position: .overlay,
            emitterPosition: .top,
            duration: duration
        )
    }
    
    /// Adds a sparkle highlight effect.
    /// - Parameter isActive: Binding controlling the effect.
    /// - Returns: The modified view.
    public func sparkle(isActive: Binding<Bool>) -> some View {
        particleEffect(
            .sparkle,
            isActive: isActive,
            position: .overlay,
            emitterPosition: .center
        )
    }
    
    /// Adds snow falling effect.
    /// - Parameter isActive: Binding controlling the effect.
    /// - Returns: The modified view.
    public func snow(isActive: Binding<Bool>) -> some View {
        particleEffect(
            .snow,
            isActive: isActive,
            position: .overlay,
            emitterPosition: .top
        )
    }
}

// MARK: - ParticleTriggerModifier

/// Modifier that triggers particles on value change.
private struct ParticleTriggerModifier<T: Equatable>: ViewModifier {
    let preset: ParticlePreset
    let trigger: T
    let duration: TimeInterval
    let position: ParticleLayerPosition
    
    @State private var isActive = false
    @State private var previousValue: T?
    
    func body(content: Content) -> some View {
        content
            .modifier(ParticleModifier(
                preset: preset,
                isActive: $isActive,
                position: position,
                duration: duration
            ))
            .onChange(of: trigger) { oldValue, newValue in
                if previousValue != nil && oldValue != newValue {
                    isActive = true
                }
                previousValue = newValue
            }
            .onAppear {
                previousValue = trigger
            }
    }
}

// MARK: - ParticleBurstModifier

/// Modifier for one-shot particle bursts.
public struct ParticleBurstModifier: ViewModifier {
    
    let preset: ParticlePreset
    @Binding var trigger: Bool
    let position: ParticleLayerPosition
    let emitterPosition: EmitterPositionMode
    
    @State private var showParticles = false
    
    public func body(content: Content) -> some View {
        content
            .modifier(ParticleModifier(
                preset: preset,
                isActive: $showParticles,
                position: position,
                emitterPosition: emitterPosition,
                duration: 2.0
            ))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    showParticles = true
                    trigger = false
                }
            }
    }
}

extension View {
    
    /// Adds a particle burst that fires once when triggered.
    /// - Parameters:
    ///   - preset: The particle preset.
    ///   - trigger: Binding that triggers the burst when set to true.
    ///   - position: Layer position.
    ///   - emitterPosition: Emitter position.
    /// - Returns: The modified view.
    public func particleBurst(
        _ preset: ParticlePreset,
        trigger: Binding<Bool>,
        position: ParticleLayerPosition = .overlay,
        emitterPosition: EmitterPositionMode = .center
    ) -> some View {
        modifier(ParticleBurstModifier(
            preset: preset,
            trigger: trigger,
            position: position,
            emitterPosition: emitterPosition
        ))
    }
}
