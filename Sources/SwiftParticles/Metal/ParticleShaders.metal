// ParticleShaders.metal
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

#include <metal_stdlib>
using namespace metal;

// MARK: - Data Structures

struct GPUParticle {
    float2 position;
    float2 velocity;
    float4 color;
    float size;
    float rotation;
    float lifetime;
    float age;
    uint flags;
};

struct RenderUniforms {
    float2 viewportSize;
    float time;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 texCoord;
    float pointSize [[point_size]];
};

// MARK: - Vertex Shader

vertex VertexOut particleVertex(uint vertexID [[vertex_id]],
                                 uint instanceID [[instance_id]],
                                 constant GPUParticle *particles [[buffer(0)]],
                                 constant RenderUniforms &uniforms [[buffer(1)]]) {
    
    GPUParticle particle = particles[instanceID];
    
    // Quad vertices (triangle strip)
    float2 quadVertices[4] = {
        float2(-1, -1),
        float2( 1, -1),
        float2(-1,  1),
        float2( 1,  1)
    };
    
    float2 texCoords[4] = {
        float2(0, 1),
        float2(1, 1),
        float2(0, 0),
        float2(1, 0)
    };
    
    float2 vertex = quadVertices[vertexID];
    
    // Apply rotation
    float cosR = cos(particle.rotation);
    float sinR = sin(particle.rotation);
    float2 rotated = float2(
        vertex.x * cosR - vertex.y * sinR,
        vertex.x * sinR + vertex.y * cosR
    );
    
    // Scale and position
    float2 scaled = rotated * particle.size;
    float2 worldPos = particle.position + scaled;
    
    // Convert to clip space
    float2 clipPos = (worldPos / uniforms.viewportSize) * 2.0 - 1.0;
    clipPos.y = -clipPos.y; // Flip Y for Metal coordinate system
    
    // Calculate age ratio for fading
    float ageRatio = particle.age / particle.lifetime;
    float4 color = particle.color;
    color.a *= 1.0 - ageRatio; // Fade out over lifetime
    
    VertexOut out;
    out.position = float4(clipPos, 0.0, 1.0);
    out.color = color;
    out.texCoord = texCoords[vertexID];
    out.pointSize = particle.size;
    
    return out;
}

// MARK: - Fragment Shader

fragment float4 particleFragment(VertexOut in [[stage_in]]) {
    // Circular soft particle
    float2 center = in.texCoord - 0.5;
    float dist = length(center) * 2.0;
    float alpha = 1.0 - smoothstep(0.8, 1.0, dist);
    
    return float4(in.color.rgb, in.color.a * alpha);
}

// Additive blend fragment shader
fragment float4 particleFragmentAdditive(VertexOut in [[stage_in]]) {
    float2 center = in.texCoord - 0.5;
    float dist = length(center) * 2.0;
    float alpha = 1.0 - smoothstep(0.6, 1.0, dist);
    
    // Pre-multiply alpha for additive blending
    return float4(in.color.rgb * in.color.a * alpha, alpha);
}

// Star-shaped particle fragment shader
fragment float4 particleFragmentStar(VertexOut in [[stage_in]]) {
    float2 uv = in.texCoord * 2.0 - 1.0;
    float angle = atan2(uv.y, uv.x);
    float radius = length(uv);
    
    // 4-point star pattern
    float star = abs(cos(angle * 2.0)) * 0.5 + 0.5;
    float alpha = 1.0 - smoothstep(star * 0.7, star, radius);
    
    return float4(in.color.rgb, in.color.a * alpha);
}

// MARK: - Compute Shader (Physics Update)

kernel void updateParticles(device GPUParticle *particles [[buffer(0)]],
                            constant float &deltaTime [[buffer(1)]],
                            uint id [[thread_position_in_grid]]) {
    
    GPUParticle particle = particles[id];
    
    // Skip dead particles
    if (particle.age >= particle.lifetime) {
        return;
    }
    
    // Update age
    particle.age += deltaTime;
    
    // Apply gravity (configurable via flags)
    float2 gravity = float2(0, 98.0); // Default gravity
    particle.velocity += gravity * deltaTime;
    
    // Apply drag
    particle.velocity *= 0.99;
    
    // Update position
    particle.position += particle.velocity * deltaTime;
    
    // Apply turbulence
    float turbulence = 20.0;
    float noiseX = sin(particle.position.x * 0.1 + particle.age * 2.0) * turbulence;
    float noiseY = cos(particle.position.y * 0.1 + particle.age * 2.0) * turbulence;
    particle.position += float2(noiseX, noiseY) * deltaTime;
    
    // Write back
    particles[id] = particle;
}

// Advanced physics kernel with forces
kernel void updateParticlesAdvanced(device GPUParticle *particles [[buffer(0)]],
                                    constant float &deltaTime [[buffer(1)]],
                                    constant float2 &attractorPos [[buffer(2)]],
                                    constant float &attractorStrength [[buffer(3)]],
                                    uint id [[thread_position_in_grid]]) {
    
    GPUParticle particle = particles[id];
    
    if (particle.age >= particle.lifetime) {
        return;
    }
    
    particle.age += deltaTime;
    
    // Attractor force
    float2 toAttractor = attractorPos - particle.position;
    float distance = length(toAttractor);
    if (distance > 1.0) {
        float2 attractForce = normalize(toAttractor) * attractorStrength / (distance * distance);
        particle.velocity += attractForce * deltaTime;
    }
    
    // Gravity
    particle.velocity += float2(0, 98.0) * deltaTime;
    
    // Drag
    particle.velocity *= 0.995;
    
    // Update position
    particle.position += particle.velocity * deltaTime;
    
    particles[id] = particle;
}

// Collision detection kernel
kernel void detectCollisions(device GPUParticle *particles [[buffer(0)]],
                             constant float4 &bounds [[buffer(1)]],  // minX, minY, maxX, maxY
                             constant float &bounceFactor [[buffer(2)]],
                             uint id [[thread_position_in_grid]]) {
    
    GPUParticle particle = particles[id];
    
    // Ground collision
    if (particle.position.y > bounds.w) {
        particle.position.y = bounds.w;
        particle.velocity.y = -particle.velocity.y * bounceFactor;
    }
    
    // Ceiling collision
    if (particle.position.y < bounds.y) {
        particle.position.y = bounds.y;
        particle.velocity.y = -particle.velocity.y * bounceFactor;
    }
    
    // Wall collisions
    if (particle.position.x < bounds.x) {
        particle.position.x = bounds.x;
        particle.velocity.x = -particle.velocity.x * bounceFactor;
    }
    if (particle.position.x > bounds.z) {
        particle.position.x = bounds.z;
        particle.velocity.x = -particle.velocity.x * bounceFactor;
    }
    
    particles[id] = particle;
}
