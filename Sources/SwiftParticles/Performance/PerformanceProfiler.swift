// PerformanceProfiler.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

import Foundation
import Combine
import QuartzCore

// MARK: - PerformanceProfiler

/// Monitors and reports particle system performance metrics.
///
/// Tracks frame timing, particle counts, memory usage, and provides
/// optimization suggestions. Useful for debugging and optimization.
///
/// ## Features
/// - Real-time FPS tracking
/// - CPU/GPU timing
/// - Memory monitoring
/// - Automatic optimization hints
/// - Performance logging
///
/// ## Usage
/// ```swift
/// let profiler = PerformanceProfiler()
/// profiler.attach(to: particleSystem)
/// profiler.onWarning = { message in
///     print("Performance warning: \(message)")
/// }
/// ```
@MainActor
public final class PerformanceProfiler: ObservableObject {
    
    // MARK: - Published Metrics
    
    /// Current frames per second.
    @Published public private(set) var fps: Double = 60
    
    /// Frame time in milliseconds.
    @Published public private(set) var frameTimeMs: Double = 16.67
    
    /// Current particle count.
    @Published public private(set) var particleCount: Int = 0
    
    /// Peak particle count this session.
    @Published public private(set) var peakParticleCount: Int = 0
    
    /// Estimated memory usage in MB.
    @Published public private(set) var memoryUsageMB: Double = 0
    
    /// Update time (CPU) in milliseconds.
    @Published public private(set) var updateTimeMs: Double = 0
    
    /// Render time (GPU) in milliseconds.
    @Published public private(set) var renderTimeMs: Double = 0
    
    /// Overall performance grade (A-F).
    @Published public private(set) var performanceGrade: String = "A"
    
    /// Active warnings.
    @Published public private(set) var warnings: [PerformanceWarning] = []
    
    /// Historical frame times (last 60 frames).
    @Published public private(set) var frameTimeHistory: [Double] = []
    
    // MARK: - Configuration
    
    /// Target FPS.
    public var targetFPS: Double = 60
    
    /// Warning threshold for particle count.
    public var particleCountWarningThreshold: Int = 1000
    
    /// Warning threshold for frame time (ms).
    public var frameTimeWarningThreshold: Double = 20
    
    /// Enable automatic optimization suggestions.
    public var autoOptimize: Bool = true
    
    /// Callback for performance warnings.
    public var onWarning: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private var frameTimestamps: [CFTimeInterval] = []
    private var lastUpdateTime: CFTimeInterval = 0
    private var sampleCount = 0
    private let maxHistorySize = 60
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Attachment
    
    /// Attaches the profiler to a particle system.
    public func attach(to system: ParticleSystem) {
        system.$particles
            .receive(on: DispatchQueue.main)
            .sink { [weak self] particles in
                self?.updateMetrics(particleCount: particles.count)
            }
            .store(in: &cancellables)
        
        system.$statistics
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stats in
                self?.updateFromStats(stats)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Frame Timing
    
    /// Call at the beginning of a frame.
    public func beginFrame() {
        lastUpdateTime = CACurrentMediaTime()
    }
    
    /// Call at the end of a frame.
    public func endFrame() {
        let currentTime = CACurrentMediaTime()
        let frameTime = (currentTime - lastUpdateTime) * 1000  // Convert to ms
        
        frameTimeMs = frameTime
        
        // Update history
        frameTimeHistory.append(frameTime)
        if frameTimeHistory.count > maxHistorySize {
            frameTimeHistory.removeFirst()
        }
        
        // Calculate FPS
        frameTimestamps.append(currentTime)
        frameTimestamps = frameTimestamps.filter { currentTime - $0 < 1.0 }
        fps = Double(frameTimestamps.count)
        
        // Check for issues
        checkPerformance()
    }
    
    /// Records update phase timing.
    public func recordUpdateTime(_ time: Double) {
        updateTimeMs = time * 1000
    }
    
    /// Records render phase timing.
    public func recordRenderTime(_ time: Double) {
        renderTimeMs = time * 1000
    }
    
    // MARK: - Metrics
    
    private func updateMetrics(particleCount: Int) {
        self.particleCount = particleCount
        if particleCount > peakParticleCount {
            peakParticleCount = particleCount
        }
        
        // Estimate memory (rough estimate: ~100 bytes per particle)
        memoryUsageMB = Double(particleCount * 100) / (1024 * 1024)
    }
    
    private func updateFromStats(_ stats: ParticleStatistics) {
        // Update from system statistics if available
    }
    
    // MARK: - Performance Checking
    
    private func checkPerformance() {
        warnings.removeAll()
        
        // Check FPS
        if fps < targetFPS * 0.8 {
            addWarning(.lowFPS, message: "FPS dropped to \(Int(fps))")
        }
        
        // Check frame time
        if frameTimeMs > frameTimeWarningThreshold {
            addWarning(.highFrameTime, message: "Frame time: \(String(format: "%.1f", frameTimeMs))ms")
        }
        
        // Check particle count
        if particleCount > particleCountWarningThreshold {
            addWarning(.highParticleCount, message: "\(particleCount) particles active")
        }
        
        // Check for frame spikes
        if frameTimeHistory.count >= 10 {
            let recentAverage = frameTimeHistory.suffix(10).reduce(0, +) / 10
            if frameTimeMs > recentAverage * 2 {
                addWarning(.frameSpike, message: "Frame spike detected")
            }
        }
        
        // Calculate grade
        performanceGrade = calculateGrade()
    }
    
    private func addWarning(_ type: WarningType, message: String) {
        let warning = PerformanceWarning(type: type, message: message, timestamp: Date())
        warnings.append(warning)
        onWarning?(message)
    }
    
    private func calculateGrade() -> String {
        let fpsScore = min(100, fps / targetFPS * 100)
        let frameTimeScore = max(0, 100 - (frameTimeMs - 16.67) * 5)
        let particleScore = max(0, 100 - Double(particleCount) / Double(particleCountWarningThreshold) * 50)
        
        let overall = (fpsScore + frameTimeScore + particleScore) / 3
        
        switch overall {
        case 90...100: return "A"
        case 80..<90: return "B"
        case 70..<80: return "C"
        case 60..<70: return "D"
        default: return "F"
        }
    }
    
    // MARK: - Optimization Suggestions
    
    /// Returns optimization suggestions based on current metrics.
    public func getOptimizationSuggestions() -> [OptimizationSuggestion] {
        var suggestions: [OptimizationSuggestion] = []
        
        if particleCount > particleCountWarningThreshold {
            suggestions.append(OptimizationSuggestion(
                priority: .high,
                title: "Reduce particle count",
                description: "Consider lowering maxParticles or emission rate",
                estimatedImprovement: "30-50% FPS improvement"
            ))
        }
        
        if frameTimeMs > 20 {
            suggestions.append(OptimizationSuggestion(
                priority: .high,
                title: "Enable GPU rendering",
                description: "Switch to Metal renderer for better performance",
                estimatedImprovement: "2-5x faster rendering"
            ))
        }
        
        if updateTimeMs > 5 {
            suggestions.append(OptimizationSuggestion(
                priority: .medium,
                title: "Reduce physics complexity",
                description: "Disable turbulence or reduce forces",
                estimatedImprovement: "20-30% CPU improvement"
            ))
        }
        
        if peakParticleCount > Int(Double(particleCount) * 1.5) {
            suggestions.append(OptimizationSuggestion(
                priority: .low,
                title: "Tune particle lifetime",
                description: "Shorter lifetimes reduce particle buildup",
                estimatedImprovement: "Steadier performance"
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Reporting
    
    /// Generates a performance report.
    public func generateReport() -> PerformanceReport {
        PerformanceReport(
            timestamp: Date(),
            averageFPS: fps,
            averageFrameTime: frameTimeMs,
            peakParticleCount: peakParticleCount,
            currentParticleCount: particleCount,
            memoryUsageMB: memoryUsageMB,
            grade: performanceGrade,
            warnings: warnings,
            suggestions: getOptimizationSuggestions()
        )
    }
    
    /// Resets all metrics.
    public func reset() {
        fps = 60
        frameTimeMs = 16.67
        particleCount = 0
        peakParticleCount = 0
        memoryUsageMB = 0
        updateTimeMs = 0
        renderTimeMs = 0
        performanceGrade = "A"
        warnings.removeAll()
        frameTimeHistory.removeAll()
        frameTimestamps.removeAll()
    }
}

// MARK: - Supporting Types

/// Types of performance warnings.
public enum WarningType: String, Codable, Sendable {
    case lowFPS
    case highFrameTime
    case highParticleCount
    case frameSpike
    case memoryPressure
}

/// A performance warning.
public struct PerformanceWarning: Identifiable, Codable, Sendable {
    public let id = UUID()
    public let type: WarningType
    public let message: String
    public let timestamp: Date
}

/// An optimization suggestion.
public struct OptimizationSuggestion: Identifiable, Sendable {
    public let id = UUID()
    public let priority: Priority
    public let title: String
    public let description: String
    public let estimatedImprovement: String
    
    public enum Priority: String, Sendable {
        case high, medium, low
    }
}

/// A performance report.
public struct PerformanceReport: Codable, Sendable {
    public let timestamp: Date
    public let averageFPS: Double
    public let averageFrameTime: Double
    public let peakParticleCount: Int
    public let currentParticleCount: Int
    public let memoryUsageMB: Double
    public let grade: String
    public let warnings: [PerformanceWarning]
    public let suggestions: [OptimizationSuggestion]
}

extension OptimizationSuggestion: Codable {
    enum CodingKeys: String, CodingKey {
        case priority, title, description, estimatedImprovement
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(priority.rawValue, forKey: .priority)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(estimatedImprovement, forKey: .estimatedImprovement)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let priorityString = try container.decode(String.self, forKey: .priority)
        priority = Priority(rawValue: priorityString) ?? .medium
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        estimatedImprovement = try container.decode(String.self, forKey: .estimatedImprovement)
    }
}

// MARK: - PerformanceOverlayView

/// A debug overlay showing performance metrics.
public struct PerformanceOverlayView: View {
    @ObservedObject var profiler: PerformanceProfiler
    
    public init(profiler: PerformanceProfiler) {
        self.profiler = profiler
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("FPS:")
                Text("\(Int(profiler.fps))")
                    .foregroundColor(profiler.fps >= 55 ? .green : profiler.fps >= 30 ? .yellow : .red)
                    .bold()
                
                Text("|\(profiler.performanceGrade)")
                    .foregroundColor(gradeColor)
                    .bold()
            }
            
            Text("Particles: \(profiler.particleCount)")
            Text("Frame: \(String(format: "%.1f", profiler.frameTimeMs))ms")
            
            if !profiler.warnings.isEmpty {
                ForEach(profiler.warnings) { warning in
                    Text("⚠️ \(warning.message)")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
        }
        .font(.system(.caption, design: .monospaced))
        .padding(8)
        .background(Color.black.opacity(0.7))
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    private var gradeColor: Color {
        switch profiler.performanceGrade {
        case "A": return .green
        case "B": return .mint
        case "C": return .yellow
        case "D": return .orange
        default: return .red
        }
    }
}
