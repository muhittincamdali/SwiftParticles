// SwiftParticlesTests.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import XCTest
@testable import SwiftParticles

final class SwiftParticlesTests: XCTestCase {
    
    // MARK: - Vector2D Tests
    
    func testVector2DInitialization() {
        let vector = Vector2D(x: 3, y: 4)
        XCTAssertEqual(vector.x, 3)
        XCTAssertEqual(vector.y, 4)
    }
    
    func testVector2DMagnitude() {
        let vector = Vector2D(x: 3, y: 4)
        XCTAssertEqual(vector.magnitude, 5, accuracy: 0.0001)
    }
    
    func testVector2DNormalized() {
        let vector = Vector2D(x: 3, y: 4)
        let normalized = vector.normalized
        XCTAssertEqual(normalized.magnitude, 1, accuracy: 0.0001)
    }
    
    func testVector2DAddition() {
        let a = Vector2D(x: 1, y: 2)
        let b = Vector2D(x: 3, y: 4)
        let result = a + b
        XCTAssertEqual(result.x, 4)
        XCTAssertEqual(result.y, 6)
    }
    
    func testVector2DSubtraction() {
        let a = Vector2D(x: 5, y: 7)
        let b = Vector2D(x: 2, y: 3)
        let result = a - b
        XCTAssertEqual(result.x, 3)
        XCTAssertEqual(result.y, 4)
    }
    
    func testVector2DScalarMultiplication() {
        let vector = Vector2D(x: 2, y: 3)
        let result = vector * 2
        XCTAssertEqual(result.x, 4)
        XCTAssertEqual(result.y, 6)
    }
    
    func testVector2DDotProduct() {
        let a = Vector2D(x: 1, y: 2)
        let b = Vector2D(x: 3, y: 4)
        XCTAssertEqual(a.dot(b), 11)
    }
    
    func testVector2DRotation() {
        let vector = Vector2D(x: 1, y: 0)
        let rotated = vector.rotated(by: .pi / 2)
        XCTAssertEqual(rotated.x, 0, accuracy: 0.0001)
        XCTAssertEqual(rotated.y, 1, accuracy: 0.0001)
    }
    
    func testVector2DLerp() {
        let a = Vector2D(x: 0, y: 0)
        let b = Vector2D(x: 10, y: 20)
        let result = a.lerp(to: b, t: 0.5)
        XCTAssertEqual(result.x, 5)
        XCTAssertEqual(result.y, 10)
    }
    
    func testVector2DDistance() {
        let a = Vector2D(x: 0, y: 0)
        let b = Vector2D(x: 3, y: 4)
        XCTAssertEqual(a.distance(to: b), 5, accuracy: 0.0001)
    }
    
    // MARK: - Particle Tests
    
    func testParticleInitialization() {
        let particle = Particle(
            position: Vector2D(x: 100, y: 200),
            velocity: Vector2D(x: 10, y: -20),
            lifetime: 2.0
        )
        
        XCTAssertEqual(particle.position.x, 100)
        XCTAssertEqual(particle.position.y, 200)
        XCTAssertEqual(particle.lifetime, 2.0)
        XCTAssertTrue(particle.isAlive)
    }
    
    func testParticleUpdate() {
        var particle = Particle(
            position: Vector2D(x: 0, y: 0),
            velocity: Vector2D(x: 100, y: 0),
            lifetime: 2.0
        )
        
        particle.update(deltaTime: 0.1)
        
        XCTAssertEqual(particle.position.x, 10, accuracy: 0.0001)
        XCTAssertEqual(particle.age, 0.1, accuracy: 0.0001)
    }
    
    func testParticleApplyForce() {
        var particle = Particle(
            position: .zero,
            velocity: .zero,
            mass: 1.0,
            lifetime: 2.0
        )
        
        particle.applyForce(Vector2D(x: 10, y: 0))
        
        XCTAssertEqual(particle.acceleration.x, 10)
    }
    
    func testParticleNormalizedAge() {
        var particle = Particle(lifetime: 2.0)
        particle.age = 1.0
        
        XCTAssertEqual(particle.normalizedAge, 0.5, accuracy: 0.0001)
    }
    
    func testParticleIsAlive() {
        var particle = Particle(lifetime: 1.0)
        
        XCTAssertTrue(particle.isAlive)
        
        particle.age = 1.5
        XCTAssertFalse(particle.isAlive)
    }
    
    // MARK: - ParticleColor Tests
    
    func testParticleColorInitialization() {
        let color = ParticleColor(red: 1.0, green: 0.5, blue: 0.25, alpha: 0.8)
        
        XCTAssertEqual(color.red, 1.0)
        XCTAssertEqual(color.green, 0.5)
        XCTAssertEqual(color.blue, 0.25)
        XCTAssertEqual(color.alpha, 0.8)
    }
    
    func testParticleColorLerp() {
        let a = ParticleColor(red: 0, green: 0, blue: 0)
        let b = ParticleColor(red: 1, green: 1, blue: 1)
        let result = a.lerp(to: b, t: 0.5)
        
        XCTAssertEqual(result.red, 0.5, accuracy: 0.0001)
        XCTAssertEqual(result.green, 0.5, accuracy: 0.0001)
        XCTAssertEqual(result.blue, 0.5, accuracy: 0.0001)
    }
    
    func testParticleColorHexInitialization() {
        let color = ParticleColor(hex: "#FF5500")
        
        XCTAssertEqual(color.red, 1.0, accuracy: 0.01)
        XCTAssertEqual(color.green, 0.333, accuracy: 0.01)
        XCTAssertEqual(color.blue, 0.0, accuracy: 0.01)
    }
    
    // MARK: - ParticleConfiguration Tests
    
    func testParticleConfigurationDefaults() {
        let config = ParticleConfiguration()
        
        XCTAssertEqual(config.emissionRate, 50)
        XCTAssertEqual(config.maxParticles, 1000)
        XCTAssertEqual(config.duration, .infinity)
    }
    
    func testParticleConfigurationBuilder() {
        let config = ParticleConfiguration()
            .withEmissionRate(100)
            .withGravity(Vector2D(x: 0, y: 200))
            .withColors([.red, .blue])
        
        XCTAssertEqual(config.emissionRate, 100)
        XCTAssertEqual(config.gravity.y, 200)
        XCTAssertEqual(config.colorPalette.count, 2)
    }
    
    // MARK: - ParticleEmitter Tests
    
    func testParticleEmitterInitialization() {
        let emitter = ParticleEmitter(position: Vector2D(x: 100, y: 200))
        
        XCTAssertEqual(emitter.position.x, 100)
        XCTAssertEqual(emitter.position.y, 200)
        XCTAssertFalse(emitter.isActive)
    }
    
    func testParticleEmitterStart() {
        let emitter = ParticleEmitter()
        emitter.start()
        
        XCTAssertTrue(emitter.isActive)
    }
    
    func testParticleEmitterStop() {
        let emitter = ParticleEmitter()
        emitter.start()
        emitter.stop()
        
        XCTAssertFalse(emitter.isActive)
    }
    
    func testParticleEmitterBurst() {
        let emitter = ParticleEmitter()
        emitter.configuration.burstCount = 10
        
        let particles = emitter.burst()
        
        XCTAssertEqual(particles.count, 10)
    }
    
    // MARK: - ParticlePool Tests
    
    func testParticlePoolAcquire() {
        let pool = ParticlePool(capacity: 100)
        let particle = pool.acquire()
        
        XCTAssertNotNil(particle)
        XCTAssertEqual(pool.activeCount, 1)
    }
    
    func testParticlePoolRelease() {
        let pool = ParticlePool(capacity: 100)
        guard let particle = pool.acquire() else {
            XCTFail("Failed to acquire particle")
            return
        }
        
        pool.release(particle)
        
        XCTAssertEqual(pool.activeCount, 0)
        XCTAssertEqual(pool.availableCount, 1)
    }
    
    func testParticlePoolCapacity() {
        let pool = ParticlePool(capacity: 5)
        
        for _ in 0..<5 {
            _ = pool.acquire()
        }
        
        let overflow = pool.acquire()
        XCTAssertNil(overflow)
    }
    
    // MARK: - Force Tests
    
    func testGravityForce() {
        let gravity = GravityForce(strength: 100)
        let particle = Particle(position: .zero, velocity: .zero, mass: 1.0, lifetime: 2.0)
        
        let force = gravity.calculateForce(for: particle, deltaTime: 0.016)
        
        XCTAssertEqual(force.y, 100, accuracy: 0.01)
    }
    
    func testWindForce() {
        let wind = WindForce(direction: Vector2D(x: 1, y: 0), strength: 50)
        let particle = Particle(position: .zero, velocity: .zero, lifetime: 2.0)
        
        let force = wind.calculateForce(for: particle, deltaTime: 0.016)
        
        XCTAssertGreaterThan(force.x, 0)
    }
    
    func testAttractorForce() {
        let attractor = AttractorForce(
            position: Vector2D(x: 100, y: 100),
            strength: 500,
            radius: 200
        )
        
        let particle = Particle(position: Vector2D(x: 50, y: 50), velocity: .zero, lifetime: 2.0)
        let force = attractor.calculateForce(for: particle, deltaTime: 0.016)
        
        // Force should point toward attractor
        XCTAssertGreaterThan(force.x, 0)
        XCTAssertGreaterThan(force.y, 0)
    }
    
    // MARK: - Behavior Tests
    
    func testFadeOutBehavior() {
        let fade = FadeOutBehavior(startOpacity: 1.0, endOpacity: 0.0)
        var particle = Particle(lifetime: 1.0)
        particle.age = 0.5
        particle.opacity = 1.0
        
        fade.apply(to: &particle, deltaTime: 0.016)
        
        XCTAssertLessThan(particle.opacity, 1.0)
    }
    
    func testScaleBehavior() {
        let scale = ScaleBehavior(startScale: 1.0, endScale: 0.0)
        var particle = Particle(lifetime: 1.0)
        particle.age = 0.5
        particle.scale = 1.0
        
        scale.apply(to: &particle, deltaTime: 0.016)
        
        XCTAssertLessThan(particle.scale, 1.0)
    }
    
    // MARK: - Preset Tests
    
    func testConfettiPreset() {
        let config = ParticlePreset.confetti.configuration
        
        XCTAssertGreaterThan(config.emissionRate, 0)
        XCTAssertFalse(config.colorPalette.isEmpty)
    }
    
    func testSnowPreset() {
        let config = ParticlePreset.snow.configuration
        
        XCTAssertGreaterThan(config.lifetimeRange.lowerBound, 0)
        XCTAssertEqual(config.shape, .circle)
    }
    
    func testFirePreset() {
        let config = ParticlePreset.fire.configuration
        
        XCTAssertEqual(config.blendMode, .additive)
        XCTAssertLessThan(config.gravity.y, 0)  // Fire rises
    }
    
    // MARK: - Animation Tests
    
    func testLerp() {
        let result = ParticleAnimation.lerp(0, 100, t: 0.5)
        XCTAssertEqual(result, 50)
    }
    
    func testSmoothStep() {
        let result = ParticleAnimation.smoothStep(0, 100, t: 0.5)
        XCTAssertEqual(result, 50, accuracy: 0.01)
    }
    
    func testClamp() {
        XCTAssertEqual(ParticleAnimation.clamp(1.5, min: 0, max: 1), 1.0)
        XCTAssertEqual(ParticleAnimation.clamp(-0.5, min: 0, max: 1), 0.0)
        XCTAssertEqual(ParticleAnimation.clamp(0.5, min: 0, max: 1), 0.5)
    }
    
    func testPingPong() {
        XCTAssertEqual(ParticleAnimation.pingPong(0.5), 0.5, accuracy: 0.01)
        XCTAssertEqual(ParticleAnimation.pingPong(1.5), 0.5, accuracy: 0.01)
    }
    
    // MARK: - Easing Tests
    
    func testEasingLinear() {
        let result = EasingFunction.linear.apply(0.5)
        XCTAssertEqual(result, 0.5)
    }
    
    func testEasingEaseIn() {
        let result = EasingFunction.easeIn.apply(0.5)
        XCTAssertLessThan(result, 0.5)
    }
    
    func testEasingEaseOut() {
        let result = EasingFunction.easeOut.apply(0.5)
        XCTAssertGreaterThan(result, 0.5)
    }
}
