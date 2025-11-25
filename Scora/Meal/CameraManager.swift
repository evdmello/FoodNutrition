//
//  CameraManager.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import AVFoundation
import SwiftUI
import Vision

class CameraManager: NSObject, ObservableObject {
    @Published var isAutoCaptureEnabled = true
    @Published var capturedImage: UIImage?
    @Published var isFoodDetected = false
    @Published var detectionConfidence: Float = 0.0

    let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    private var currentSampleBuffer: CMSampleBuffer?
    private var foodDetectionRequest: VNRequest?
    private var detectionTimer: Timer?
    private var consecutiveDetections = 0
    private let requiredDetections = 3 // Require 3 consecutive detections before auto-capture
    private var isCapturing = false // Flag to prevent detection after capture

    override init() {
        super.init()
        setupCamera()
        setupVision()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Add camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        // Add video output for preview and detection
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        }

        // Add photo output for capturing
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }

    private func setupVision() {
        // We'll use Vision's built-in image classification
        // For more accurate food detection, you would integrate a custom CoreML model
        let request = VNClassifyImageRequest { [weak self] request, error in
            self?.handleDetectionResults(request: request, error: error)
        }
        self.foodDetectionRequest = request
    }

    private func handleDetectionResults(request: VNRequest, error: Error?) {
        // Don't process detection results if we've already captured
        guard !isCapturing else { return }

        guard let results = request.results as? [VNClassificationObservation] else { return }

        // Check if any food-related items are detected
        let foodKeywords = ["food", "meal", "dish", "plate", "pizza", "burger", "salad", "fruit",
                           "vegetable", "sandwich", "pasta", "rice", "bread", "meat", "chicken",
                           "dessert", "cake", "cookie", "breakfast", "lunch", "dinner"]

        var maxConfidence: Float = 0.0
        var foodFound = false

        for observation in results.prefix(10) {
            let identifier = observation.identifier.lowercased()

            for keyword in foodKeywords {
                if identifier.contains(keyword) {
                    foodFound = true
                    maxConfidence = max(maxConfidence, observation.confidence)
                    break
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Don't update UI if we've already captured
            guard !self.isCapturing else { return }

            self.isFoodDetected = foodFound && maxConfidence > 0.5
            self.detectionConfidence = maxConfidence

            if self.isFoodDetected && self.isAutoCaptureEnabled {
                self.consecutiveDetections += 1

                if self.consecutiveDetections >= self.requiredDetections {
                    self.capturePhoto()
                    self.consecutiveDetections = 0
                }
            } else {
                self.consecutiveDetections = 0
            }
        }
    }

    func startSession() {
        sessionQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func resetCamera() {
        isCapturing = false
        capturedImage = nil
        isFoodDetected = false
        detectionConfidence = 0.0
        consecutiveDetections = 0
        startSession()
    }

    func capturePhoto() {
        // Set capturing flag to stop detection
        isCapturing = true

        let settings = AVCapturePhotoSettings()

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
            // Stop the session after capturing
            self.session.stopRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        currentSampleBuffer = sampleBuffer

        // Skip detection if we've already captured or auto-capture is disabled
        guard isAutoCaptureEnabled && !isCapturing else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let request = foodDetectionRequest else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.capturedImage = image
        }
    }
}
