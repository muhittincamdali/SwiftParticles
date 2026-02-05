// Available on iOS 16+, macOS 14+, tvOS 16+, watchOS 9+, visionOS 1+
// ParticleView.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import SwiftUI

// MARK: - ParticleView

/// A SwiftUI view that displays an animated particle system.
///
/// `ParticleView` provides an easy way to add particle effects to your
/// SwiftUI interface. It handles the rendering loop and automatically
/// sizes to fit its container.
///
/// ## Usage Example
/// ```swift
/// // Basic usage
/// ParticleView(preset: .confetti)
///
/// // With custom configuration
/// ParticleView(configuration: myConfig)
///     .frame(height: 300)
///
/// // With system access
/// ParticleView { system in
///     system.addForce(GravityForce())
///     system.addBehavior(FadeOutBehavior())
/// }
/// ```
public struct ParticleView: View {
    
    // MARK: - Properties
    
    /// The particle system being displayed.
    @StateObject private var system: ParticleSystem
    
    /// Size of the view from GeometryReader.
    @State private var viewSize: CGSize = .zero
    
    /// Whether to auto-start the system.
    private let autoStart: Bool
    
    /// Callback for configuring the system.
    private let configure: ((ParticleSystem) -> Void)?
    
    /// Emitter position mode.
    private let emitterPosition: EmitterPositionMode
    
    // MARK: - Initialization
    
    /// Creates a particle view with a preset.
    /// - Parameters:
    ///   - preset: The particle preset to use.
    ///   - autoStart: Whether to start automatically. Default is true.
    public init(
        preset: ParticlePreset,
        autoStart: Bool = true
    ) {
        let particleSystem = ParticleSystem.withPreset(preset)
        _system = StateObject(wrappedValue: particleSystem)
        self.autoStart = autoStart
        self.configure = nil
        self.emitterPosition = .center
    }
    
    /// Creates a particle view with a configuration.
    /// - Parameters:
    ///   - configuration: The particle configuration.
    ///   - autoStart: Whether to start automatically.
    public init(
        configuration: ParticleConfiguration,
        autoStart: Bool = true
    ) {
        let particleSystem = ParticleSystem(particleConfiguration: configuration)
        _system = StateObject(wrappedValue: particleSystem)
        self.autoStart = autoStart
        self.configure = nil
        self.emitterPosition = .center
    }
    
    /// Creates a particle view with a custom system configuration.
    /// - Parameters:
    ///   - autoStart: Whether to start automatically.
    ///   - configure: Callback to configure the system.
    public init(
        autoStart: Bool = true,
        configure: @escaping (ParticleSystem) -> Void
    ) {
        let particleSystem = ParticleSystem()
        _system = StateObject(wrappedValue: particleSystem)
        self.autoStart = autoStart
        self.configure = configure
        self.emitterPosition = .center
    }
    
    /// Creates a particle view with a preset and emitter position.
    /// - Parameters:
    ///   - preset: The particle preset.
    ///   - position: Emitter position mode.
    ///   - autoStart: Whether to start automatically.
    public init(
        preset: ParticlePreset,
        position: EmitterPositionMode,
        autoStart: Bool = true
    ) {
        let particleSystem = ParticleSystem.withPreset(preset)
        _system = StateObject(wrappedValue: particleSystem)
        self.autoStart = autoStart
        self.configure = nil
        self.emitterPosition = position
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                renderParticles(context: context, size: size)
            }
            .onChange(of: geometry.size) { _, newSize in
                viewSize = newSize
                updateSystemBounds(newSize)
            }
            .onAppear {
                viewSize = geometry.size
                setupSystem(size: geometry.size)
            }
            .onDisappear {
                system.stop()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up the particle system.
    private func setupSystem(size: CGSize) {
        // Configure the system
        configure?(system)
        
        // Set bounds
        system.configuration.bounds = CGRect(origin: .zero, size: size)
        
        // Position emitters
        updateEmitterPositions(size: size)
        
        // Add default fade behavior if none exist
        if system.allBehaviors.isEmpty {
            system.addBehavior(FadeOutBehavior())
        }
        
        // Auto-start if enabled
        if autoStart {
            system.start()
        }
    }
    
    /// Updates system bounds when size changes.
    private func updateSystemBounds(_ size: CGSize) {
        system.configuration.bounds = CGRect(origin: .zero, size: size)
        updateEmitterPositions(size: size)
    }
    
    /// Updates emitter positions based on mode.
    private func updateEmitterPositions(size: CGSize) {
        for emitter in system.allEmitters {
            switch emitterPosition {
            case .center:
                emitter.position = Vector2D(x: size.width / 2, y: size.height / 2)
            case .top:
                emitter.position = Vector2D(x: size.width / 2, y: 0)
            case .bottom:
                emitter.position = Vector2D(x: size.width / 2, y: size.height)
            case .left:
                emitter.position = Vector2D(x: 0, y: size.height / 2)
            case .right:
                emitter.position = Vector2D(x: size.width, y: size.height / 2)
            case .topLeft:
                emitter.position = Vector2D(x: 0, y: 0)
            case .topRight:
                emitter.position = Vector2D(x: size.width, y: 0)
            case .bottomLeft:
                emitter.position = Vector2D(x: 0, y: size.height)
            case .bottomRight:
                emitter.position = Vector2D(x: size.width, y: size.height)
            case .custom(let point):
                emitter.position = Vector2D(x: point.x, y: point.y)
            case .relative(let x, let y):
                emitter.position = Vector2D(x: size.width * x, y: size.height * y)
            }
        }
    }
    
    /// Renders particles to the canvas.
    private func renderParticles(context: GraphicsContext, size: CGSize) {
        for particle in system.particles {
            renderParticle(particle, context: context)
        }
    }
    
    /// Renders a single particle.
    private func renderParticle(_ particle: Particle, context: GraphicsContext) {
        let size = particle.scaledSize
        let rect = CGRect(
            x: particle.position.x - size.width / 2,
            y: particle.position.y - size.height / 2,
            width: size.width,
            height: size.height
        )
        
        var context = context
        
        // Apply rotation
        if particle.rotation != 0 {
            context.translateBy(x: particle.position.x, y: particle.position.y)
            context.rotate(by: Angle(radians: particle.rotation))
            context.translateBy(x: -particle.position.x, y: -particle.position.y)
        }
        
        // Set opacity
        context.opacity = particle.opacity
        
        // Get color
        let color = particle.color.swiftUIColor
        
        // Draw based on shape
        switch particle.shape {
        case .circle:
            context.fill(
                Circle().path(in: rect),
                with: .color(color)
            )
            
        case .square:
            context.fill(
                Rectangle().path(in: rect),
                with: .color(color)
            )
            
        case .triangle:
            let path = trianglePath(in: rect)
            context.fill(path, with: .color(color))
            
        case .star:
            let path = starPath(in: rect, points: 5)
            context.fill(path, with: .color(color))
            
        case .diamond:
            let path = diamondPath(in: rect)
            context.fill(path, with: .color(color))
            
        case .heart:
            let path = heartPath(in: rect)
            context.fill(path, with: .color(color))
            
        case .ring:
            context.stroke(
                Circle().path(in: rect),
                with: .color(color),
                lineWidth: size.width * 0.15
            )
            
        case .spark, .line:
            let path = sparkPath(in: rect, direction: particle.direction)
            context.stroke(path, with: .color(color), lineWidth: 2)
            
        default:
            context.fill(
                Circle().path(in: rect),
                with: .color(color)
            )
        }
    }
    
    // MARK: - Shape Paths
    
    private func trianglePath(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
    
    private func starPath(in rect: CGRect, points: Int) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let outerRadius = min(rect.width, rect.height) / 2
            let innerRadius = outerRadius * 0.4
            
            for i in 0..<(points * 2) {
                let angle = Double(i) * .pi / Double(points) - .pi / 2
                let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
                let point = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
                
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
    }
    
    private func diamondPath(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
        }
    }
    
    private func heartPath(in rect: CGRect) -> Path {
        Path { path in
            let width = rect.width
            let height = rect.height
            
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addCurve(
                to: CGPoint(x: rect.minX, y: rect.minY + height * 0.25),
                control1: CGPoint(x: rect.midX - width * 0.1, y: rect.maxY - height * 0.3),
                control2: CGPoint(x: rect.minX, y: rect.midY)
            )
            path.addArc(
                center: CGPoint(x: rect.minX + width * 0.25, y: rect.minY + height * 0.25),
                radius: width * 0.25,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.addArc(
                center: CGPoint(x: rect.maxX - width * 0.25, y: rect.minY + height * 0.25),
                radius: width * 0.25,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            path.addCurve(
                to: CGPoint(x: rect.midX, y: rect.maxY),
                control1: CGPoint(x: rect.maxX, y: rect.midY),
                control2: CGPoint(x: rect.midX + width * 0.1, y: rect.maxY - height * 0.3)
            )
        }
    }
    
    private func sparkPath(in rect: CGRect, direction: Double) -> Path {
        Path { path in
            let length = max(rect.width, rect.height)
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            path.move(to: CGPoint(
                x: center.x - cos(direction) * length / 2,
                y: center.y - sin(direction) * length / 2
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(direction) * length / 2,
                y: center.y + sin(direction) * length / 2
            ))
        }
    }
}

// MARK: - EmitterPositionMode

/// Position modes for particle emitters.
public enum EmitterPositionMode: Sendable {
    /// Center of the view.
    case center
    /// Top center.
    case top
    /// Bottom center.
    case bottom
    /// Left center.
    case left
    /// Right center.
    case right
    /// Top-left corner.
    case topLeft
    /// Top-right corner.
    case topRight
    /// Bottom-left corner.
    case bottomLeft
    /// Bottom-right corner.
    case bottomRight
    /// Custom fixed position.
    case custom(CGPoint)
    /// Relative position (0-1 range for x and y).
    case relative(x: Double, y: Double)
}

// MARK: - View Modifiers

extension ParticleView {
    
    /// Accesses the underlying particle system.
    /// - Parameter action: Action to perform with the system.
    /// - Returns: The view.
    public func onSystem(_ action: @escaping (ParticleSystem) -> Void) -> some View {
        self.onAppear {
            action(system)
        }
    }
}
