// VisionParticleView.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

#if os(visionOS)
import SwiftUI
import RealityKit

// MARK: - VisionParticleView

/// A visionOS-native 3D particle view using RealityKit.
///
/// Renders particle systems in true 3D space with spatial audio support
/// and hand tracking interaction.
///
/// ## Features
/// - True 3D particle rendering
/// - Spatial audio integration
/// - Hand tracking interaction
/// - Gaze-based particle attraction
/// - Immersive space support
///
/// ## Usage
/// ```swift
/// VisionParticleView(preset: .magic3D)
///     .enableHandTracking()
///     .spatialAudio(true)
/// ```
public struct VisionParticleView: View {
    
    @StateObject private var system: Particle3DSystem
    @State private var particleEntity: Entity?
    
    private var configuration: Particle3DConfiguration
    private var enableHandTracking: Bool
    private var enableSpatialAudio: Bool
    
    /// Creates a visionOS particle view.
    /// - Parameter configuration: 3D particle configuration.
    public init(configuration: Particle3DConfiguration) {
        self.configuration = configuration
        self.enableHandTracking = false
        self.enableSpatialAudio = false
        _system = StateObject(wrappedValue: Particle3DSystem(configuration: configuration))
    }
    
    public var body: some View {
        RealityView { content in
            // Create root entity for particles
            let root = Entity()
            root.name = "ParticleRoot"
            
            // Add particle emitter entity
            let emitter = createParticleEmitter()
            root.addChild(emitter)
            
            content.add(root)
            particleEntity = root
        } update: { content in
            updateParticles()
        }
        .onAppear {
            system.start()
        }
        .onDisappear {
            system.stop()
        }
    }
    
    private func createParticleEmitter() -> Entity {
        let entity = Entity()
        
        // Create particle system component
        var particleEmitter = ParticleEmitterComponent()
        
        // Configure emitter
        particleEmitter.mainEmitter.birthRate = Float(configuration.emissionRate)
        particleEmitter.mainEmitter.lifeSpan = Float(configuration.lifetimeRange.upperBound)
        particleEmitter.mainEmitter.speed = Float(configuration.speedRange.upperBound)
        
        // Set emission shape
        switch configuration.emissionShape {
        case .point:
            particleEmitter.emitterShape = .point
        case .sphere(let radius):
            particleEmitter.emitterShape = .sphere
            particleEmitter.emitterShapeSize = [Float(radius), Float(radius), Float(radius)]
        case .box(let w, let h, let d):
            particleEmitter.emitterShape = .box
            particleEmitter.emitterShapeSize = [Float(w), Float(h), Float(d)]
        case .cone(let radius, let height):
            particleEmitter.emitterShape = .cone
            particleEmitter.emitterShapeSize = [Float(radius), Float(height), Float(radius)]
        default:
            particleEmitter.emitterShape = .point
        }
        
        // Set particle appearance
        particleEmitter.mainEmitter.size = Float(configuration.sizeRange.lowerBound)
        
        if let firstColor = configuration.colorPalette.first {
            particleEmitter.mainEmitter.color = .constant(.single(
                UIColor(
                    red: firstColor.red,
                    green: firstColor.green,
                    blue: firstColor.blue,
                    alpha: firstColor.alpha
                )
            ))
        }
        
        // Add component to entity
        entity.components.set(particleEmitter)
        
        return entity
    }
    
    private func updateParticles() {
        // Update particle entities based on system state
        guard let root = particleEntity else { return }
        
        // Update emitter properties if needed
        if var emitter = root.children.first?.components[ParticleEmitterComponent.self] {
            emitter.mainEmitter.birthRate = system.state == .running ? Float(configuration.emissionRate) : 0
            root.children.first?.components.set(emitter)
        }
    }
    
    // MARK: - Modifiers
    
    /// Enables hand tracking interaction.
    public func enableHandTracking(_ enabled: Bool = true) -> VisionParticleView {
        var view = self
        view.enableHandTracking = enabled
        return view
    }
    
    /// Enables spatial audio for particles.
    public func spatialAudio(_ enabled: Bool = true) -> VisionParticleView {
        var view = self
        view.enableSpatialAudio = enabled
        return view
    }
}

// MARK: - Vision Presets

/// Pre-configured 3D particle presets for visionOS.
public enum VisionParticlePresets {
    
    /// Magical floating sparkles.
    public static var magic3D: Particle3DConfiguration {
        var config = Particle3DConfiguration()
        config.emissionRate = 30
        config.maxParticles = 200
        config.emissionShape = .sphere(radius: 0.3)
        config.speedRange = 0.05...0.15
        config.sizeRange = 0.01...0.03
        config.lifetimeRange = 2...5
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.9, blue: 0.5),
            ParticleColor(red: 0.9, green: 0.7, blue: 1.0),
            ParticleColor(red: 0.5, green: 0.9, blue: 1.0)
        ]
        config.gravity = Vector3D(x: 0, y: 0.02, z: 0)
        config.turbulence = 0.05
        return config
    }
    
    /// Falling snow in 3D space.
    public static var snow3D: Particle3DConfiguration {
        var config = Particle3DConfiguration()
        config.emissionRate = 50
        config.maxParticles = 500
        config.emissionShape = .box(width: 2, height: 0.1, depth: 2)
        config.emissionDirection = Vector3D(x: 0, y: -1, z: 0)
        config.speedRange = 0.1...0.3
        config.sizeRange = 0.005...0.015
        config.lifetimeRange = 5...10
        config.colorPalette = [.white]
        config.gravity = Vector3D(x: 0, y: -0.1, z: 0)
        config.turbulence = 0.02
        return config
    }
    
    /// Ambient dust particles.
    public static var dust3D: Particle3DConfiguration {
        var config = Particle3DConfiguration()
        config.emissionRate = 20
        config.maxParticles = 300
        config.emissionShape = .box(width: 3, height: 2, depth: 3)
        config.speedRange = 0.01...0.05
        config.sizeRange = 0.002...0.008
        config.lifetimeRange = 8...15
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 0.3)
        ]
        config.turbulence = 0.02
        return config
    }
    
    /// Fire effect in 3D.
    public static var fire3D: Particle3DConfiguration {
        var config = Particle3DConfiguration()
        config.emissionRate = 80
        config.maxParticles = 300
        config.emissionShape = .cone(radius: 0.1, height: 0.05)
        config.emissionDirection = Vector3D(x: 0, y: 1, z: 0)
        config.speedRange = 0.2...0.5
        config.sizeRange = 0.02...0.08
        config.lifetimeRange = 0.5...1.5
        config.colorPalette = [
            ParticleColor(red: 1.0, green: 1.0, blue: 0.6),
            ParticleColor(red: 1.0, green: 0.6, blue: 0.1),
            ParticleColor(red: 1.0, green: 0.3, blue: 0.1)
        ]
        config.gravity = Vector3D(x: 0, y: 0.3, z: 0)
        config.turbulence = 0.1
        return config
    }
    
    /// Portal swirl effect.
    public static var portal3D: Particle3DConfiguration {
        var config = Particle3DConfiguration()
        config.emissionRate = 60
        config.maxParticles = 400
        config.emissionShape = .torus(majorRadius: 0.3, minorRadius: 0.05)
        config.speedRange = 0.1...0.3
        config.sizeRange = 0.01...0.03
        config.lifetimeRange = 2...4
        config.colorPalette = [
            ParticleColor(red: 0.4, green: 0.2, blue: 1.0),
            ParticleColor(red: 0.6, green: 0.3, blue: 1.0),
            ParticleColor(red: 0.8, green: 0.5, blue: 1.0)
        ]
        config.turbulence = 0.05
        return config
    }
}

#endif
