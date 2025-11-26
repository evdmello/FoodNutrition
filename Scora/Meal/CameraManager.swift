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
    @Published var isShowingCapturedImage: Bool = false

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
        print("🎥 CameraManager initialized")
    }

    deinit {
        print("🎥 CameraManager deallocated")
        session.stopRunning()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Add camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            print("Failed to setup camera input")
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        // Add video output for preview and detection
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            print("Video output added successfully")
        }

        // Add photo output for capturing
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)

            // Configure photo output settings
            photoOutput.isHighResolutionCaptureEnabled = true
            if photoOutput.isDepthDataDeliverySupported {
                photoOutput.isDepthDataDeliveryEnabled = false
            }

            print("Photo output added successfully")
        } else {
            print("Failed to add photo output")
        }

        session.commitConfiguration()
        print("Camera session configuration completed")
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
        print("capturePhoto() called")

        // Set capturing flag to stop detection
        isCapturing = true

        sessionQueue.async { [weak self] in
            guard let self = self else {
                print("Self is nil in capturePhoto")
                return
            }

            print("Session is running: \(self.session.isRunning)")

            // Verify the session is running
            guard self.session.isRunning else {
                print("Session is not running, cannot capture photo")
                DispatchQueue.main.async {
                    self.isCapturing = false
                }
                return
            }

            // Verify photo output connection
            guard let connection = self.photoOutput.connection(with: .video) else {
                print("No video connection available for photo output")
                DispatchQueue.main.async {
                    self.isCapturing = false
                }
                return
            }

            print("Photo output connection established: \(connection)")

            // Configure photo settings
            let settings = AVCapturePhotoSettings()

            self.photoOutput.capturePhoto(with: settings, delegate: self)
            print("capturePhoto called on photoOutput")
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
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 DELEGATE: willBeginCaptureFor called")
    }

    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("📸 DELEGATE: willCapturePhotoFor called")
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: (any Error)?) {
        print("📸 DELEGATE: didFinishCaptureFor called")
        if let error = error {
            print("📸 DELEGATE: Error in didFinishCaptureFor: \(error.localizedDescription)")
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCapturingDeferredPhotoProxy deferredPhotoProxy: AVCaptureDeferredPhotoProxy?, error: (any Error)?) {
        print("📸 DELEGATE: didFinishCapturingDeferredPhotoProxy called")
        if let error = error {
            print("📸 DELEGATE: Error in didFinishCapturingDeferredPhotoProxy: \(error.localizedDescription)")
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("📸 DELEGATE: didFinishProcessingPhoto called")

        if let error = error {
            print("📸 DELEGATE: Error capturing photo: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            print("📸 DELEGATE: Failed to get photo data representation")
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }

        print("📸 DELEGATE: Got image data, size: \(imageData.count) bytes")

        guard let image = UIImage(data: imageData) else {
            print("📸 DELEGATE: Failed to create UIImage from data")
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }

        print("📸 DELEGATE: Photo captured successfully, size: \(image.size)")
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.capturedImage = image
            self.isShowingCapturedImage = true
            print("📸 DELEGATE: Set capturedImage and isShowingCapturedImage on main thread")
        }
    }
}
