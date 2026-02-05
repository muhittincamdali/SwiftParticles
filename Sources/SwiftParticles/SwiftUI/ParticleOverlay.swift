// Available on iOS 16+, macOS 14+, tvOS 16+, watchOS 9+, visionOS 1+
// ParticleOverlay.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import SwiftUI

// MARK: - ParticleOverlay

/// A full-screen particle overlay for global effects.
///
/// `ParticleOverlay` creates a particle effect that covers the entire
/// screen, useful for app-wide celebrations, weather effects, or
/// ambient animations.
///
/// ## Usage Example
/// ```swift
/// ZStack {
///     ContentView()
///     
///     ParticleOverlay(preset: .snow)
///         .opacity(showSnow ? 1 : 0)
/// }
/// ```
public struct ParticleOverlay: View {
    
    // MARK: - Properties
    
    /// The particle preset to display.
    let preset: ParticlePreset
    
    /// Emitter position mode.
    let emitterPosition: EmitterPositionMode
    
    /// Whether the overlay ignores safe area.
    let ignoresSafeArea: Bool
    
    /// Background color (nil for transparent).
    let backgroundColor: Color?
    
    /// Whether to allow interaction with content below.
    let allowsHitTesting: Bool
    
    // MARK: - Initialization
    
    /// Creates a particle overlay.
    /// - Parameters:
    ///   - preset: The particle preset.
    ///   - emitterPosition: Where to position emitters.
    ///   - ignoresSafeArea: Whether to extend into safe area.
    ///   - backgroundColor: Optional background color.
    ///   - allowsHitTesting: Whether to block touches.
    public init(
        preset: ParticlePreset,
        emitterPosition: EmitterPositionMode = .top,
        ignoresSafeArea: Bool = true,
        backgroundColor: Color? = nil,
        allowsHitTesting: Bool = false
    ) {
        self.preset = preset
        self.emitterPosition = emitterPosition
        self.ignoresSafeArea = ignoresSafeArea
        self.backgroundColor = backgroundColor
        self.allowsHitTesting = allowsHitTesting
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack {
            if let bgColor = backgroundColor {
                bgColor
            }
            
            ParticleView(preset: preset, position: emitterPosition)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .if(ignoresSafeArea) { view in
            view.ignoresSafeArea()
        }
        .allowsHitTesting(allowsHitTesting)
    }
}

// MARK: - Conditional Modifier

private extension View {
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preset Overlays

extension ParticleOverlay {
    
    /// Creates a snow overlay.
    /// - Parameter intensity: Snow intensity (0.5 = light, 1.0 = normal, 2.0 = heavy).
    /// - Returns: A snow particle overlay.
    public static func snow(intensity: Double = 1.0) -> ParticleOverlay {
        ParticleOverlay(
            preset: .snow,
            emitterPosition: .top
        )
    }
    
    /// Creates a rain overlay.
    /// - Parameter intensity: Rain intensity.
    /// - Returns: A rain particle overlay.
    public static func rain(intensity: Double = 1.0) -> ParticleOverlay {
        ParticleOverlay(
            preset: .rain,
            emitterPosition: .top
        )
    }
    
    /// Creates a confetti celebration overlay.
    /// - Returns: A confetti particle overlay.
    public static var confetti: ParticleOverlay {
        ParticleOverlay(
            preset: .confetti,
            emitterPosition: .top
        )
    }
    
    /// Creates an ambient sparkle overlay.
    /// - Returns: A sparkle particle overlay.
    public static var sparkle: ParticleOverlay {
        ParticleOverlay(
            preset: .sparkle,
            emitterPosition: .center
        )
    }
    
    /// Creates falling leaves overlay.
    /// - Returns: A leaves particle overlay.
    public static var leaves: ParticleOverlay {
        ParticleOverlay(
            preset: .leaves,
            emitterPosition: .top
        )
    }
}

// MARK: - InteractiveParticleOverlay

/// An overlay that responds to touch/drag gestures.
public struct InteractiveParticleOverlay: View {
    
    // MARK: - Properties
    
    let preset: ParticlePreset
    
    @State private var touchLocation: CGPoint = .zero
    @State private var isTouching = false
    @StateObject private var system = ParticleSystem()
    
    // MARK: - Initialization
    
    /// Creates an interactive particle overlay.
    /// - Parameter preset: The particle preset.
    public init(preset: ParticlePreset) {
        self.preset = preset
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas { context, size in
                    for particle in system.particles {
                        renderParticle(particle, context: context)
                    }
                }
                
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(dragGesture(in: geometry.size))
            }
            .onAppear {
                setupSystem(preset: preset, size: geometry.size)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSystem(preset: ParticlePreset, size: CGSize) {
        let emitter = ParticleEmitter(configuration: preset.configuration)
        emitter.position = Vector2D(x: size.width / 2, y: size.height / 2)
        emitter.isActive = false
        
        system.addEmitter(emitter)
        system.addBehavior(FadeOutBehavior())
        system.configuration.bounds = CGRect(origin: .zero, size: size)
        system.start()
    }
    
    private func dragGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                touchLocation = value.location
                isTouching = true
                updateEmitterPosition()
            }
            .onEnded { _ in
                isTouching = false
                stopEmitting()
            }
    }
    
    private func updateEmitterPosition() {
        for emitter in system.allEmitters {
            emitter.position = Vector2D(x: touchLocation.x, y: touchLocation.y)
            emitter.isActive = true
        }
    }
    
    private func stopEmitting() {
        for emitter in system.allEmitters {
            emitter.isActive = false
        }
    }
    
    private func renderParticle(_ particle: Particle, context: GraphicsContext) {
        let size = particle.scaledSize
        let rect = CGRect(
            x: particle.position.x - size.width / 2,
            y: particle.position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
        
        var context = context
        context.opacity = particle.opacity
        
        let color = particle.color.swiftUIColor
        context.fill(Circle().path(in: rect), with: .color(color))
    }
}

// MARK: - View Extension

extension View {
    
    /// Adds a particle overlay to the view hierarchy.
    /// - Parameters:
    ///   - preset: The particle preset.
    ///   - isActive: Binding controlling visibility.
    ///   - position: Emitter position.
    /// - Returns: The modified view with overlay.
    public func particleOverlay(
        _ preset: ParticlePreset,
        isActive: Binding<Bool>,
        position: EmitterPositionMode = .top
    ) -> some View {
        ZStack {
            self
            
            if isActive.wrappedValue {
                ParticleOverlay(preset: preset, emitterPosition: position)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isActive.wrappedValue)
    }
}
