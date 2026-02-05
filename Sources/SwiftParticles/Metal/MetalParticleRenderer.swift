// MetalParticleRenderer.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

#if canImport(Metal) && canImport(MetalKit)
import Foundation
import Metal
import MetalKit
import simd

// MARK: - MetalParticleRenderer

/// High-performance Metal-based particle renderer.
///
/// Uses GPU acceleration for rendering millions of particles with
/// minimal CPU overhead. Supports compute shaders for physics simulation.
///
/// ## Performance Features
/// - GPU-accelerated rendering
/// - Compute shader physics
/// - Instanced rendering for efficiency
/// - Double-buffered updates
///
/// ## Usage
/// ```swift
/// let renderer = MetalParticleRenderer()
/// renderer.render(particles: system.particles, in: view)
/// ```
@MainActor
public final class MetalParticleRenderer: ObservableObject {
    
    // MARK: - Metal Objects
    
    /// The Metal device (GPU).
    private var device: MTLDevice?
    
    /// Command queue for GPU commands.
    private var commandQueue: MTLCommandQueue?
    
    /// Render pipeline state.
    private var renderPipelineState: MTLRenderPipelineState?
    
    /// Compute pipeline for physics.
    private var computePipelineState: MTLComputePipelineState?
    
    /// Particle vertex buffer.
    private var particleBuffer: MTLBuffer?
    
    /// Uniform buffer for shared data.
    private var uniformBuffer: MTLBuffer?
    
    /// Texture for particle sprites.
    private var particleTexture: MTLTexture?
    
    /// Maximum particles this renderer can handle.
    public let maxParticles: Int
    
    /// Current particle count.
    @Published public private(set) var particleCount: Int = 0
    
    /// Whether Metal is available.
    public var isMetalAvailable: Bool { device != nil }
    
    /// Performance statistics.
    @Published public private(set) var stats: RenderStatistics = RenderStatistics()
    
    // MARK: - Initialization
    
    /// Creates a new Metal particle renderer.
    /// - Parameter maxParticles: Maximum number of particles (default 100,000).
    public init(maxParticles: Int = 100_000) {
        self.maxParticles = maxParticles
        setupMetal()
    }
    
    // MARK: - Setup
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not available on this device")
            return
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        setupBuffers()
        setupPipelines()
    }
    
    private func setupBuffers() {
        guard let device = device else { return }
        
        // Create particle buffer
        let bufferSize = maxParticles * MemoryLayout<GPUParticle>.stride
        particleBuffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)
        
        // Create uniform buffer
        uniformBuffer = device.makeBuffer(length: MemoryLayout<RenderUniforms>.stride, options: .storageModeShared)
    }
    
    private func setupPipelines() {
        guard let device = device else { return }
        
        // Create render pipeline
        let library = device.makeDefaultLibrary()
        
        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.vertexFunction = library?.makeFunction(name: "particleVertex")
        renderDescriptor.fragmentFunction = library?.makeFunction(name: "particleFragment")
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Enable blending
        renderDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        renderDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        renderDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
        renderDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: renderDescriptor)
        } catch {
            print("Failed to create render pipeline: \(error)")
        }
        
        // Create compute pipeline for physics
        if let computeFunction = library?.makeFunction(name: "updateParticles") {
            do {
                computePipelineState = try device.makeComputePipelineState(function: computeFunction)
            } catch {
                print("Failed to create compute pipeline: \(error)")
            }
        }
    }
    
    // MARK: - Rendering
    
    /// Updates particle buffer with current particle data.
    /// - Parameter particles: Array of particles to render.
    public func updateParticles(_ particles: [Particle]) {
        guard let buffer = particleBuffer else { return }
        
        let count = min(particles.count, maxParticles)
        particleCount = count
        
        let pointer = buffer.contents().bindMemory(to: GPUParticle.self, capacity: maxParticles)
        
        for i in 0..<count {
            let particle = particles[i]
            pointer[i] = GPUParticle(
                position: SIMD2<Float>(Float(particle.position.x), Float(particle.position.y)),
                velocity: SIMD2<Float>(Float(particle.velocity.x), Float(particle.velocity.y)),
                color: SIMD4<Float>(Float(particle.color.red), Float(particle.color.green), Float(particle.color.blue), Float(particle.color.alpha)),
                size: Float(particle.size.width),
                rotation: Float(particle.rotation),
                lifetime: Float(particle.lifetime),
                age: Float(particle.age),
                flags: 0
            )
        }
    }
    
    /// Performs GPU-accelerated physics update.
    /// - Parameter deltaTime: Time since last update.
    public func updatePhysics(deltaTime: Float) {
        guard let commandQueue = commandQueue,
              let computePipeline = computePipelineState,
              let particleBuffer = particleBuffer,
              particleCount > 0 else { return }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        computeEncoder.setComputePipelineState(computePipeline)
        computeEncoder.setBuffer(particleBuffer, offset: 0, index: 0)
        
        // Set delta time
        var dt = deltaTime
        computeEncoder.setBytes(&dt, length: MemoryLayout<Float>.size, index: 1)
        
        // Dispatch compute
        let threadGroupSize = min(computePipeline.maxTotalThreadsPerThreadgroup, particleCount)
        let threadGroups = (particleCount + threadGroupSize - 1) / threadGroupSize
        
        computeEncoder.dispatchThreadgroups(MTLSize(width: threadGroups, height: 1, depth: 1),
                                           threadsPerThreadgroup: MTLSize(width: threadGroupSize, height: 1, depth: 1))
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
    }
    
    /// Renders particles to a Metal view.
    /// - Parameters:
    ///   - view: The MTKView to render to.
    ///   - particles: Particles to render.
    public func render(to view: MTKView, particles: [Particle]) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        updateParticles(particles)
        
        guard let commandQueue = commandQueue,
              let renderPipeline = renderPipelineState,
              let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              particleCount > 0 else { return }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
        
        renderEncoder.setRenderPipelineState(renderPipeline)
        renderEncoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        
        // Update uniforms
        if let uniformBuffer = uniformBuffer {
            let viewportSize = SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
            var uniforms = RenderUniforms(viewportSize: viewportSize, time: Float(CACurrentMediaTime()))
            memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<RenderUniforms>.size)
            renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        }
        
        // Draw instanced particles
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: particleCount)
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        // Update stats
        let renderTime = CFAbsoluteTimeGetCurrent() - startTime
        stats.lastRenderTime = renderTime
        stats.particlesRendered = particleCount
        stats.framesPerSecond = 1.0 / renderTime
    }
}

// MARK: - GPU Data Structures

/// GPU-compatible particle data structure.
public struct GPUParticle {
    var position: SIMD2<Float>
    var velocity: SIMD2<Float>
    var color: SIMD4<Float>
    var size: Float
    var rotation: Float
    var lifetime: Float
    var age: Float
    var flags: UInt32
}

/// Uniforms passed to shaders.
struct RenderUniforms {
    var viewportSize: SIMD2<Float>
    var time: Float
}

/// Rendering performance statistics.
public struct RenderStatistics {
    public var lastRenderTime: Double = 0
    public var particlesRendered: Int = 0
    public var framesPerSecond: Double = 0
    
    public var renderTimeMs: Double { lastRenderTime * 1000 }
}

#endif
