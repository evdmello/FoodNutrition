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
    private let requiredDetections = 3
    private var isCapturing = false

    override init() {
        super.init()
        setupCamera()
        setupVision()
    }

    deinit {
        session.stopRunning()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }

        session.addInput(input)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)

            photoOutput.isHighResolutionCaptureEnabled = true
            if photoOutput.isDepthDataDeliverySupported {
                photoOutput.isDepthDataDeliveryEnabled = false
            }
        }
        session.commitConfiguration()
    }

    private func setupVision() {
        let request = VNClassifyImageRequest { [weak self] request, error in
            self?.handleDetectionResults(request: request, error: error)
        }
        self.foodDetectionRequest = request
    }

    private func handleDetectionResults(request: VNRequest, error: Error?) {
        guard !isCapturing else { return }

        guard let results = request.results as? [VNClassificationObservation] else { return }

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
        isCapturing = true

        sessionQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            guard self.session.isRunning else {
                DispatchQueue.main.async {
                    self.isCapturing = false
                }
                return
            }

            guard let connection = self.photoOutput.connection(with: .video) else {
                DispatchQueue.main.async {
                    self.isCapturing = false
                }
                return
            }

            let settings = AVCapturePhotoSettings()

            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        currentSampleBuffer = sampleBuffer

        guard isAutoCaptureEnabled && !isCapturing else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let request = foodDetectionRequest else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }

        guard let image = UIImage(data: imageData) else {
            DispatchQueue.main.async { [weak self] in
                self?.isCapturing = false
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.capturedImage = image
            self.isShowingCapturedImage = true
        }
    }
}
