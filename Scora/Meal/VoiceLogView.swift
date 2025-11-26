//
//  VoiceLogView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct VoiceLogView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = VoiceLogViewModel()
    @State private var showSettingsAlert = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 40) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.system(size: 20))
                            .padding()
                    }

                    Spacer()
                }

                Spacer()

                VStack(spacing: 24) {
                    Text(viewModel.state.statusText)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    WaveformView(levels: viewModel.waveformLevels)
                        .frame(height: 80)
                        .padding(.horizontal)
                        .opacity(viewModel.isRecording ? 1 : 0.4)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.isRecording)

                    Button(action: { viewModel.toggleRecording() }) {
                        ZStack {
                            Circle()
                                .fill(viewModel.isRecording ? Color.red : AppColors.primary)
                                .frame(width: 100, height: 100)

                            Image(systemName: "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(!viewModel.state.canRecord)
                    .scaleEffect(viewModel.isRecording ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isRecording)

                    Text(viewModel.state.helperText)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)

                    if viewModel.isRecording {
                        Text(viewModel.elapsedTimeText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()
            }
        }
        .onAppear { viewModel.requestPermissionIfNeeded() }
        .alert("Microphone Access", isPresented: $showSettingsAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
        } message: {
            Text("Please enable microphone access in Settings to log meals with your voice.")
        }
        .onChange(of: viewModel.showSettingsPrompt) { _, newValue in
            showSettingsAlert = newValue
        }
    }

    private struct WaveformView: View {
        let levels: [CGFloat]

        var body: some View {
            GeometryReader { geometry in
                let barWidth = max(2, (geometry.size.width / CGFloat(max(1, levels.count))) - 4)

                HStack(alignment: .center, spacing: 4) {
                    ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                        Capsule()
                            .fill(AppColors.primary.opacity(0.9))
                            .frame(
                                width: barWidth,
                                height: max(8, geometry.size.height * level)
                            )
                            .animation(.linear(duration: 0.1), value: levels)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
