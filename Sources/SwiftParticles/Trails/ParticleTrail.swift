// ParticleTrail.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI

// MARK: - ParticleTrail

/// A trail that follows a particle, creating motion blur effects.
///
/// Trails store historical positions and render them with fading opacity
/// to create the illusion of motion.
public struct ParticleTrail: Identifiable, Hashable, Sendable {
    public let id: UUID
    
    /// The particle this trail belongs to.
    public let particleId: UUID
    
    /// Historical positions (newest first).
    public var positions: [CGPoint]
    
    /// Historical sizes.
    public var sizes: [CGFloat]
    
    /// Historical colors.
    public var colors: [ParticleColor]
    
    /// Maximum number of trail points.
    public var maxLength: Int
    
    /// Fade rate (0 = instant, 1 = linear fade).
    public var fadeRate: CGFloat
    
    /// Whether the trail should taper in size.
    public var taperSize: Bool
    
    public init(
        id: UUID = UUID(),
        particleId: UUID,
        maxLength: Int = 10,
        fadeRate: CGFloat = 0.15,
        taperSize: Bool = true
    ) {
        self.id = id
        self.particleId = particleId
        self.positions = []
        self.sizes = []
        self.colors = []
        self.maxLength = maxLength
        self.fadeRate = fadeRate
        self.taperSize = taperSize
    }
    
    /// Adds a new point to the trail.
    public mutating func addPoint(_ point: CGPoint, size: CGFloat, color: ParticleColor) {
        positions.insert(point, at: 0)
        sizes.insert(size, at: 0)
        colors.insert(color, at: 0)
        
        // Trim excess
        if positions.count > maxLength {
            positions.removeLast()
            sizes.removeLast()
            colors.removeLast()
        }
    }
    
    /// Clears all trail points.
    public mutating func clear() {
        positions.removeAll()
        sizes.removeAll()
        colors.removeAll()
    }
}

// MARK: - TrailRenderer

/// Renders particle trails with various styles.
public struct TrailRenderer {
    
    /// Trail rendering style.
    public enum Style {
        /// Simple points with fading opacity.
        case points
        
        /// Connected line segments.
        case line
        
        /// Smooth curve through points.
        case smooth
        
        /// Ribbon/tape style.
        case ribbon
        
        /// Glow effect trail.
        case glow
    }
    
    /// Renders a trail to a graphics context.
    public static func render(
        trail: ParticleTrail,
        style: Style,
        in context: inout GraphicsContext
    ) {
        guard trail.positions.count > 1 else { return }
        
        switch style {
        case .points:
            renderPoints(trail: trail, in: &context)
        case .line:
            renderLine(trail: trail, in: &context)
        case .smooth:
            renderSmooth(trail: trail, in: &context)
        case .ribbon:
            renderRibbon(trail: trail, in: &context)
        case .glow:
            renderGlow(trail: trail, in: &context)
        }
    }
    
    // MARK: - Render Methods
    
    private static func renderPoints(trail: ParticleTrail, in context: inout GraphicsContext) {
        for (index, point) in trail.positions.enumerated() {
            let progress = CGFloat(index) / CGFloat(trail.positions.count)
            let opacity = 1 - (progress * trail.fadeRate * 10)
            
            guard opacity > 0 else { continue }
            
            let size = trail.taperSize ? trail.sizes[index] * (1 - progress * 0.7) : trail.sizes[index]
            let color = trail.colors[index]
            
            let rect = CGRect(
                x: point.x - size / 2,
                y: point.y - size / 2,
                width: size,
                height: size
            )
            
            context.opacity = opacity * color.alpha
            context.fill(
                Circle().path(in: rect),
                with: .color(Color(red: color.red, green: color.green, blue: color.blue))
            )
        }
    }
    
    private static func renderLine(trail: ParticleTrail, in context: inout GraphicsContext) {
        var path = Path()
        path.move(to: trail.positions[0])
        
        for point in trail.positions.dropFirst() {
            path.addLine(to: point)
        }
        
        let gradient = Gradient(stops: trail.colors.enumerated().map { index, color in
            let progress = CGFloat(index) / CGFloat(trail.colors.count)
            return .init(
                color: Color(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha * (1 - progress)),
                location: progress
            )
        })
        
        context.stroke(
            path,
            with: .linearGradient(gradient, startPoint: trail.positions[0], endPoint: trail.positions.last!),
            lineWidth: trail.sizes[0] * 0.5
        )
    }
    
    private static func renderSmooth(trail: ParticleTrail, in context: inout GraphicsContext) {
        guard trail.positions.count >= 2 else { return }
        
        var path = Path()
        path.move(to: trail.positions[0])
        
        if trail.positions.count == 2 {
            path.addLine(to: trail.positions[1])
        } else {
            for i in 0..<(trail.positions.count - 2) {
                let p0 = trail.positions[i]
                let p1 = trail.positions[i + 1]
                let p2 = trail.positions[i + 2]
                
                let midPoint = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
                path.addQuadCurve(to: midPoint, control: p1)
            }
            path.addLine(to: trail.positions.last!)
        }
        
        let color = trail.colors[0]
        context.stroke(
            path,
            with: .color(Color(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha)),
            style: StrokeStyle(lineWidth: trail.sizes[0] * 0.3, lineCap: .round, lineJoin: .round)
        )
    }
    
    private static func renderRibbon(trail: ParticleTrail, in context: inout GraphicsContext) {
        guard trail.positions.count >= 2 else { return }
        
        var topPoints: [CGPoint] = []
        var bottomPoints: [CGPoint] = []
        
        for i in 0..<trail.positions.count {
            let pos = trail.positions[i]
            let size = trail.taperSize ? trail.sizes[i] * (1 - CGFloat(i) / CGFloat(trail.positions.count) * 0.8) : trail.sizes[i]
            
            // Calculate perpendicular direction
            var perpX: CGFloat = 0
            var perpY: CGFloat = 1
            
            if i < trail.positions.count - 1 {
                let next = trail.positions[i + 1]
                let dx = next.x - pos.x
                let dy = next.y - pos.y
                let len = sqrt(dx * dx + dy * dy)
                if len > 0 {
                    perpX = -dy / len
                    perpY = dx / len
                }
            }
            
            let halfWidth = size / 2
            topPoints.append(CGPoint(x: pos.x + perpX * halfWidth, y: pos.y + perpY * halfWidth))
            bottomPoints.append(CGPoint(x: pos.x - perpX * halfWidth, y: pos.y - perpY * halfWidth))
        }
        
        var path = Path()
        path.move(to: topPoints[0])
        for point in topPoints.dropFirst() {
            path.addLine(to: point)
        }
        for point in bottomPoints.reversed() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        
        let color = trail.colors[0]
        context.fill(
            path,
            with: .color(Color(red: color.red, green: color.green, blue: color.blue, opacity: color.alpha * 0.7))
        )
    }
    
    private static func renderGlow(trail: ParticleTrail, in context: inout GraphicsContext) {
        // Render multiple layers with blur for glow effect
        for layer in 0..<3 {
            let blur = CGFloat(layer + 1) * 3
            let opacity = 0.3 / CGFloat(layer + 1)
            
            for (index, point) in trail.positions.enumerated() {
                let progress = CGFloat(index) / CGFloat(trail.positions.count)
                let alpha = (1 - progress) * opacity
                
                guard alpha > 0.01 else { continue }
                
                let baseSize = trail.sizes[index]
                let size = baseSize * (1 + CGFloat(layer) * 0.5)
                let color = trail.colors[index]
                
                let rect = CGRect(
                    x: point.x - size / 2,
                    y: point.y - size / 2,
                    width: size,
                    height: size
                )
                
                context.opacity = alpha * color.alpha
                context.addFilter(.blur(radius: blur))
                context.fill(
                    Circle().path(in: rect),
                    with: .color(Color(red: color.red, green: color.green, blue: color.blue))
                )
                context.addFilter(.blur(radius: 0))
            }
        }
    }
}

// MARK: - TrailManager

/// Manages trails for a particle system.
@MainActor
public final class TrailManager: ObservableObject {
    
    @Published public private(set) var trails: [UUID: ParticleTrail] = [:]
    
    public var style: TrailRenderer.Style = .smooth
    public var maxLength: Int = 10
    public var fadeRate: CGFloat = 0.15
    public var taperSize: Bool = true
    public var updateInterval: Int = 1  // Update every N frames
    
    private var frameCounter = 0
    
    public init() {}
    
    /// Updates trails with current particle positions.
    public func update(with particles: [Particle]) {
        frameCounter += 1
        guard frameCounter % updateInterval == 0 else { return }
        
        let particleIds = Set(particles.map { $0.id })
        
        // Remove trails for dead particles
        trails = trails.filter { particleIds.contains($0.key) }
        
        // Update existing trails and create new ones
        for particle in particles {
            if var trail = trails[particle.id] {
                trail.addPoint(
                    CGPoint(x: particle.position.x, y: particle.position.y),
                    size: particle.size.width,
                    color: particle.color
                )
                trails[particle.id] = trail
            } else {
                var newTrail = ParticleTrail(
                    particleId: particle.id,
                    maxLength: maxLength,
                    fadeRate: fadeRate,
                    taperSize: taperSize
                )
                newTrail.addPoint(
                    CGPoint(x: particle.position.x, y: particle.position.y),
                    size: particle.size.width,
                    color: particle.color
                )
                trails[particle.id] = newTrail
            }
        }
    }
    
    /// Renders all trails.
    public func render(in context: inout GraphicsContext) {
        for trail in trails.values {
            TrailRenderer.render(trail: trail, style: style, in: &context)
        }
    }
    
    /// Clears all trails.
    public func clear() {
        trails.removeAll()
    }
}
