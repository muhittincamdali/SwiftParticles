// ParticleRenderer.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import SwiftUI
import Metal
import MetalKit
import QuartzCore

// MARK: - ParticleRenderer

/// GPU-accelerated particle renderer using Metal.
///
/// `ParticleRenderer` provides high-performance rendering of large numbers
/// of particles using the Metal graphics API. It supports various blend
/// modes, custom textures, and efficient batched rendering.
///
/// ## Features
/// - GPU-accelerated rendering for thousands of particles
/// - Multiple blend modes (additive, normal, multiply)
/// - Custom texture support
/// - Instanced rendering for efficiency
/// - Automatic fallback to CPU rendering if Metal unavailable
@MainActor
public final class ParticleRenderer: ObservableObject {
    
    // MARK: - Properties
    
    /// Metal device for GPU operations.
    private var device: MTLDevice?
    
    /// Command queue for rendering commands.
    private var commandQueue: MTLCommandQueue?
    
    /// Render pipeline state for particles.
    private var pipelineState: MTLRenderPipelineState?
    
    /// Texture for particle sprites.
    private var particleTexture: MTLTexture?
    
    /// Vertex buffer for particle data.
    private var vertexBuffer: MTLBuffer?
    
    /// Instance buffer for per-particle data.
    private var instanceBuffer: MTLBuffer?
    
    /// Uniform buffer for shared data.
    private var uniformBuffer: MTLBuffer?
    
    /// Render configuration.
    public var configuration: RenderConfiguration
    
    /// Whether Metal is available on this device.
    public private(set) var isMetalAvailable: Bool = false
    
    /// Current blend mode.
    public var blendMode: ParticleBlendMode {
        get { configuration.blendMode }
        set {
            configuration.blendMode = newValue
            rebuildPipeline()
        }
    }
    
    /// Maximum number of particles this renderer can handle.
    public let maxParticles: Int
    
    /// Pre-built shape textures.
    private var shapeTextures: [ParticleShape: MTLTexture] = [:]
    
    /// Texture loader for custom textures.
    private var textureLoader: MTKTextureLoader?
    
    // MARK: - Initialization
    
    /// Creates a particle renderer with the specified configuration.
    /// - Parameters:
    ///   - configuration: Render configuration.
    ///   - maxParticles: Maximum number of particles to support.
    public init(
        configuration: RenderConfiguration = RenderConfiguration(),
        maxParticles: Int = 10000
    ) {
        self.configuration = configuration
        self.maxParticles = maxParticles
        
        setupMetal()
    }
    
    // MARK: - Metal Setup
    
    /// Initializes Metal resources.
    private func setupMetal() {
        // Get default Metal device
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("SwiftParticles: Metal not available, using CPU rendering")
            isMetalAvailable = false
            return
        }
        
        self.device = device
        isMetalAvailable = true
        
        // Create command queue
        guard let queue = device.makeCommandQueue() else {
            isMetalAvailable = false
            return
        }
        self.commandQueue = queue
        
        // Create texture loader
        textureLoader = MTKTextureLoader(device: device)
        
        // Setup buffers
        setupBuffers()
        
        // Build pipeline
        rebuildPipeline()
        
        // Generate shape textures
        generateShapeTextures()
    }
    
    /// Sets up Metal buffers.
    private func setupBuffers() {
        guard let device = device else { return }
        
        // Vertex buffer for quad (2 triangles)
        let vertices: [Float] = [
            // Position (x, y), TexCoord (u, v)
            -0.5, -0.5, 0.0, 1.0,  // Bottom left
             0.5, -0.5, 1.0, 1.0,  // Bottom right
            -0.5,  0.5, 0.0, 0.0,  // Top left
             0.5,  0.5, 1.0, 0.0   // Top right
        ]
        
        vertexBuffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Float>.stride,
            options: .storageModeShared
        )
        
        // Instance buffer for particle data
        let instanceSize = MemoryLayout<ParticleInstanceData>.stride * maxParticles
        instanceBuffer = device.makeBuffer(
            length: instanceSize,
            options: .storageModeShared
        )
        
        // Uniform buffer
        uniformBuffer = device.makeBuffer(
            length: MemoryLayout<ParticleUniforms>.stride,
            options: .storageModeShared
        )
    }
    
    /// Rebuilds the render pipeline with current settings.
    private func rebuildPipeline() {
        guard let device = device else { return }
        
        // Create shader library
        guard let library = createShaderLibrary() else {
            print("SwiftParticles: Failed to create shader library")
            return
        }
        
        // Get shader functions
        guard let vertexFunction = library.makeFunction(name: "particleVertex"),
              let fragmentFunction = library.makeFunction(name: "particleFragment") else {
            print("SwiftParticles: Failed to load shader functions")
            return
        }
        
        // Create pipeline descriptor
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = vertexFunction
        descriptor.fragmentFunction = fragmentFunction
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // Configure blending based on mode
        let colorAttachment = descriptor.colorAttachments[0]!
        colorAttachment.isBlendingEnabled = true
        
        switch blendMode {
        case .normal:
            colorAttachment.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            colorAttachment.sourceAlphaBlendFactor = .one
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
        case .additive:
            colorAttachment.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment.destinationRGBBlendFactor = .one
            colorAttachment.sourceAlphaBlendFactor = .one
            colorAttachment.destinationAlphaBlendFactor = .one
            
        case .multiply:
            colorAttachment.sourceRGBBlendFactor = .destinationColor
            colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            colorAttachment.sourceAlphaBlendFactor = .one
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
        case .screen:
            colorAttachment.sourceRGBBlendFactor = .one
            colorAttachment.destinationRGBBlendFactor = .oneMinusSourceColor
            colorAttachment.sourceAlphaBlendFactor = .one
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
        case .softLight:
            // Approximate soft light with overlay-like blend
            colorAttachment.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment.destinationRGBBlendFactor = .one
            colorAttachment.sourceAlphaBlendFactor = .one
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
        
        // Create pipeline state
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("SwiftParticles: Failed to create pipeline state: \(error)")
        }
    }
    
    /// Creates the shader library from embedded source.
    private func createShaderLibrary() -> MTLLibrary? {
        guard let device = device else { return nil }
        
        let shaderSource = ParticleShaderSource.source
        
        do {
            return try device.makeLibrary(source: shaderSource, options: nil)
        } catch {
            print("SwiftParticles: Shader compilation error: \(error)")
            return nil
        }
    }
    
    /// Generates texture for each particle shape.
    private func generateShapeTextures() {
        guard let device = device else { return }
        
        let textureSize = 64
        
        for shape in ParticleShape.allCases where shape != .custom {
            if let texture = createShapeTexture(shape: shape, size: textureSize, device: device) {
                shapeTextures[shape] = texture
            }
        }
    }
    
    /// Creates a texture for a specific shape.
    private func createShapeTexture(shape: ParticleShape, size: Int, device: MTLDevice) -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: size,
            height: size,
            mipmapped: false
        )
        descriptor.usage = [.shaderRead]
        
        guard let texture = device.makeTexture(descriptor: descriptor) else {
            return nil
        }
        
        // Generate shape pixels
        var pixels = [UInt8](repeating: 0, count: size * size * 4)
        let center = Double(size) / 2
        let radius = center - 2
        
        for y in 0..<size {
            for x in 0..<size {
                let dx = Double(x) - center
                let dy = Double(y) - center
                let distance = sqrt(dx * dx + dy * dy)
                let angle = atan2(dy, dx)
                
                var alpha: UInt8 = 0
                
                switch shape {
                case .circle:
                    if distance <= radius {
                        let edge = 1.0 - max(0, (distance - radius + 2) / 2)
                        alpha = UInt8(min(255, edge * 255))
                    }
                    
                case .square:
                    if abs(dx) <= radius && abs(dy) <= radius {
                        alpha = 255
                    }
                    
                case .triangle:
                    let px = dx / radius
                    let py = dy / radius
                    if py > -0.5 && py < 0.866 - abs(px) * 1.732 {
                        alpha = 255
                    }
                    
                case .star:
                    let normalizedAngle = angle + .pi
                    let starAngle = normalizedAngle.truncatingRemainder(dividingBy: .pi / 2.5)
                    let starRadius = radius * (0.5 + 0.5 * cos(starAngle * 5))
                    if distance <= starRadius {
                        alpha = 255
                    }
                    
                case .diamond:
                    if abs(dx) + abs(dy) <= radius {
                        alpha = 255
                    }
                    
                case .ring:
                    if distance <= radius && distance >= radius * 0.7 {
                        alpha = 255
                    }
                    
                case .spark:
                    // Elongated shape
                    let elongation = 3.0
                    let sparkDist = sqrt(dx * dx / elongation + dy * dy * elongation)
                    if sparkDist <= radius * 0.5 {
                        let edge = 1.0 - sparkDist / (radius * 0.5)
                        alpha = UInt8(min(255, edge * 255))
                    }
                    
                default:
                    if distance <= radius {
                        alpha = 255
                    }
                }
                
                let index = (y * size + x) * 4
                pixels[index] = 255     // R
                pixels[index + 1] = 255 // G
                pixels[index + 2] = 255 // B
                pixels[index + 3] = alpha
            }
        }
        
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                               size: MTLSize(width: size, height: size, depth: 1))
        texture.replace(region: region, mipmapLevel: 0, withBytes: pixels, bytesPerRow: size * 4)
        
        return texture
    }
    
    // MARK: - Rendering
    
    /// Updates particle data for rendering.
    /// - Parameter particles: Array of particles to render.
    public func updateParticles(_ particles: [Particle]) {
        guard let instanceBuffer = instanceBuffer else { return }
        guard !particles.isEmpty else { return }
        
        let count = min(particles.count, maxParticles)
        let pointer = instanceBuffer.contents().bindMemory(to: ParticleInstanceData.self, capacity: count)
        
        for i in 0..<count {
            let particle = particles[i]
            pointer[i] = ParticleInstanceData(
                position: SIMD2<Float>(Float(particle.position.x), Float(particle.position.y)),
                size: SIMD2<Float>(Float(particle.scaledSize.width), Float(particle.scaledSize.height)),
                rotation: Float(particle.rotation),
                color: SIMD4<Float>(
                    Float(particle.color.red),
                    Float(particle.color.green),
                    Float(particle.color.blue),
                    Float(particle.color.alpha * particle.opacity)
                ),
                shapeIndex: UInt32(particleShapeIndex(particle.shape))
            )
        }
    }
    
    /// Gets the texture index for a particle shape.
    private func particleShapeIndex(_ shape: ParticleShape) -> Int {
        switch shape {
        case .circle: return 0
        case .square: return 1
        case .triangle: return 2
        case .star: return 3
        case .diamond: return 4
        case .ring: return 5
        case .spark: return 6
        default: return 0
        }
    }
    
    /// Renders particles to a Metal view.
    /// - Parameters:
    ///   - view: The Metal view to render to.
    ///   - particles: Particles to render.
    ///   - viewSize: Size of the view.
    public func render(
        to view: MTKView,
        particles: [Particle],
        viewSize: CGSize
    ) {
        guard isMetalAvailable,
              let commandQueue = commandQueue,
              let pipelineState = pipelineState,
              let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        
        // Update particle data
        updateParticles(particles)
        
        // Update uniforms
        updateUniforms(viewSize: viewSize)
        
        // Create command buffer
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        // Configure encoder
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(instanceBuffer, offset: 0, index: 1)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 2)
        
        // Set shape texture
        if let circleTexture = shapeTextures[.circle] {
            encoder.setFragmentTexture(circleTexture, index: 0)
        }
        
        // Draw instanced
        let particleCount = min(particles.count, maxParticles)
        encoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4,
            instanceCount: particleCount
        )
        
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    /// Updates uniform buffer with view information.
    private func updateUniforms(viewSize: CGSize) {
        guard let uniformBuffer = uniformBuffer else { return }
        
        let uniforms = ParticleUniforms(
            viewSize: SIMD2<Float>(Float(viewSize.width), Float(viewSize.height)),
            time: Float(CACurrentMediaTime())
        )
        
        memcpy(uniformBuffer.contents(), [uniforms], MemoryLayout<ParticleUniforms>.stride)
    }
}

// MARK: - Metal Data Structures

/// Per-particle instance data for GPU rendering.
struct ParticleInstanceData {
    var position: SIMD2<Float>
    var size: SIMD2<Float>
    var rotation: Float
    var color: SIMD4<Float>
    var shapeIndex: UInt32
}

/// Uniform data shared across all particles.
struct ParticleUniforms {
    var viewSize: SIMD2<Float>
    var time: Float
}

// MARK: - Shader Source

/// Embedded Metal shader source code.
enum ParticleShaderSource {
    static let source = """
    #include <metal_stdlib>
    using namespace metal;
    
    struct VertexIn {
        float2 position [[attribute(0)]];
        float2 texCoord [[attribute(1)]];
    };
    
    struct InstanceData {
        float2 position;
        float2 size;
        float rotation;
        float4 color;
        uint shapeIndex;
    };
    
    struct Uniforms {
        float2 viewSize;
        float time;
    };
    
    struct VertexOut {
        float4 position [[position]];
        float2 texCoord;
        float4 color;
    };
    
    vertex VertexOut particleVertex(
        uint vertexID [[vertex_id]],
        uint instanceID [[instance_id]],
        constant float4* vertices [[buffer(0)]],
        constant InstanceData* instances [[buffer(1)]],
        constant Uniforms& uniforms [[buffer(2)]]
    ) {
        InstanceData instance = instances[instanceID];
        float4 vertex = vertices[vertexID];
        
        // Apply rotation
        float cosR = cos(instance.rotation);
        float sinR = sin(instance.rotation);
        float2 rotated = float2(
            vertex.x * cosR - vertex.y * sinR,
            vertex.x * sinR + vertex.y * cosR
        );
        
        // Apply scale and position
        float2 worldPos = rotated * instance.size + instance.position;
        
        // Convert to clip space
        float2 clipPos = (worldPos / uniforms.viewSize) * 2.0 - 1.0;
        clipPos.y = -clipPos.y;  // Flip Y for Metal coordinate system
        
        VertexOut out;
        out.position = float4(clipPos, 0.0, 1.0);
        out.texCoord = vertex.zw;
        out.color = instance.color;
        
        return out;
    }
    
    fragment float4 particleFragment(
        VertexOut in [[stage_in]],
        texture2d<float> shapeTexture [[texture(0)]]
    ) {
        constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
        float4 texColor = shapeTexture.sample(textureSampler, in.texCoord);
        return in.color * texColor.a;
    }
    """
}
