//
//  VoiceLogView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct VoiceLogView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isRecording = false

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
                    Text(isRecording ? "Listening..." : "Tap to start")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Button(action: { isRecording.toggle() }) {
                        ZStack {
                            Circle()
                                .fill(isRecording ? Color.red : AppColors.primary)
                                .frame(width: 100, height: 100)

                            Image(systemName: "mic.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                    }

                    Text(isRecording ? "Describe what you ate" : "Tap the microphone")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }
        }
    }
}
