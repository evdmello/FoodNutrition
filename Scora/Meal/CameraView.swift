//
//  CameraView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var cameraManager = CameraManager()
    @State private var isAnalyzing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var mealAnalysisResponse: MealAnalysisResponse?
    @State private var showAnalysisResult = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: cameraManager.isAutoCaptureEnabled ? "eye.fill" : "hand.tap.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 16))

                        Text(cameraManager.isAutoCaptureEnabled ? "Auto Capture" : "Manual")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))

                        Toggle("", isOn: $cameraManager.isAutoCaptureEnabled)
                            .labelsHidden()
                            .tint(AppColors.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)

                ZStack {
                    CameraPreview(session: cameraManager.session)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)

                    if cameraManager.isAutoCaptureEnabled {
                        VStack {
                            Spacer()

                            if cameraManager.isFoodDetected {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)

                                    Text("Food Detected")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .semibold))

                                    Text(String(format: "%.0f%%", cameraManager.detectionConfidence * 100))
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.green.opacity(0.8))
                                .cornerRadius(20)
                                .padding(.bottom, 20)
                            } else {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)

                                    Text("Looking for food...")
                                        .foregroundColor(.white)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(20)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }

                VStack(spacing: 16) {
                    if cameraManager.isAutoCaptureEnabled {
                        Text("Point camera at food for automatic capture")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Tap the button to capture")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 14))
                    }

                    Button(action: {
                        cameraManager.capturePhoto()
                    }) {
                        Circle()
                            .stroke(cameraManager.isAutoCaptureEnabled ? Color.gray : AppColors.primary, lineWidth: 4)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .fill(cameraManager.isAutoCaptureEnabled ? Color.gray : AppColors.primary)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .disabled(cameraManager.isAutoCaptureEnabled)
                    .opacity(cameraManager.isAutoCaptureEnabled ? 0.5 : 1.0)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $cameraManager.isShowingCapturedImage, onDismiss: {
            if !isAnalyzing {
                cameraManager.capturedImage = nil
            }
        }) {
            if let image = cameraManager.capturedImage {
                ImagePreviewView(
                    image: image,
                    isAnalyzing: $isAnalyzing,
                    onConfirm: { description in
                        handleImageConfirmation(image: image, description: description)
                    },
                    onRetry: {
                        cameraManager.isShowingCapturedImage = false
                        cameraManager.resetCamera()
                    }
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .fullScreenCover(isPresented: $showAnalysisResult, onDismiss: {
            // Dismiss the camera view after the result view is dismissed
            dismiss()
        }) {
            if let response = mealAnalysisResponse {
                MealAnalysisResultView(response: response)
            }
        }
    }

    private func handleImageConfirmation(image: UIImage, description: String) {
        isAnalyzing = true

        MealAnalysisService.shared.analyzeImage(image: image, description: description) { result in
            Task { @MainActor in
                isAnalyzing = false

                switch result {
                case .success(let response):
                    // Store the response and show the result view
                    mealAnalysisResponse = response
                    cameraManager.isShowingCapturedImage = false
                    showAnalysisResult = true

                case .failure(let error):
                    errorMessage = "Failed to analyze image: \(error.localizedDescription)"
                    showError = true
                    cameraManager.isShowingCapturedImage = false
                }
            }
        }
    }
}

struct ImagePreviewView: View {
    let image: UIImage
    @Binding var isAnalyzing: Bool
    let onConfirm: (String) -> Void
    let onRetry: () -> Void

    @State private var description: String = ""
    @FocusState private var isDescriptionFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Description (optional)")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 14))

                    TextField("e.g., Chicken Burger with Fries", text: $description)
                        .focused($isDescriptionFocused)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.sentences)
                }
                .padding(.horizontal, 30)

                Spacer()

                HStack(spacing: 20) {
                    Button(action: onRetry) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(12)
                    }
                    .disabled(isAnalyzing)

                    Button(action: {
                        isDescriptionFocused = false
                        onConfirm(description.isEmpty ? "Large size" : description)
                    }) {
                        HStack {
                            if isAnalyzing {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                                Text("Analyzing...")
                            } else {
                                Image(systemName: "checkmark")
                                Text("Use Photo")
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 16)
                        .background(isAnalyzing ? AppColors.primary.opacity(0.6) : AppColors.primary)
                        .cornerRadius(12)
                    }
                    .disabled(isAnalyzing)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
