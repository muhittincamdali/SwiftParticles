// ParticleEditorView.swift
// SwiftParticles
//
// Created by Muhittin Camdali on 2025.
// Copyright © 2025 Muhittin Camdali. All rights reserved.

#if os(iOS)
import SwiftUI
import UIKit

// MARK: - ParticleEditorView

/// A real-time particle system editor view.
@available(iOS 16.0, *)
public struct ParticleEditorView: View {
    
    @StateObject private var viewModel = ParticleEditorViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack {
                // Preview area
                ZStack {
                    Color.black
                    Text("Particle Preview")
                        .foregroundColor(.white)
                }
                .frame(height: 300)
                
                // Controls
                List {
                    Section("Emission") {
                        Slider(value: $viewModel.emissionRate, in: 1...500) {
                            Text("Rate: \(Int(viewModel.emissionRate))")
                        }
                        Slider(value: $viewModel.maxParticles, in: 10...2000) {
                            Text("Max: \(Int(viewModel.maxParticles))")
                        }
                    }
                    
                    Section("Physics") {
                        Slider(value: $viewModel.gravityY, in: -500...500) {
                            Text("Gravity Y: \(Int(viewModel.gravityY))")
                        }
                        Slider(value: $viewModel.drag, in: 0...0.2) {
                            Text("Drag: \(String(format: "%.2f", viewModel.drag))")
                        }
                    }
                }
            }
            .navigationTitle("Particle Editor")
        }
    }
}

// MARK: - View Model

@MainActor
final class ParticleEditorViewModel: ObservableObject {
    @Published var emissionRate: Double = 50
    @Published var maxParticles: Double = 500
    @Published var gravityY: Double = 98
    @Published var drag: Double = 0.02
}

#endif
