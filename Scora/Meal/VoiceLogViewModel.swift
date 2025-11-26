//
//  VoiceLogViewModel.swift
//  Scora
//
//  Created by GitHub Copilot on 11/27/25.
//

import AVFoundation
import CoreGraphics
import Foundation

final class VoiceLogViewModel: NSObject, ObservableObject {
    enum RecordingState {
        case idle
        case requestingPermission
        case recording
        case permissionDenied
        case failed(String)

        var statusText: String {
            switch self {
            case .idle:
                return "Tap to start"
            case .requestingPermission:
                return "Requesting access..."
            case .recording:
                return "Listening..."
            case .permissionDenied:
                return "Enable microphone access"
            case .failed:
                return "Unable to record"
            }
        }

        var helperText: String {
            switch self {
            case .idle:
                return "Describe what you ate"
            case .requestingPermission:
                return "Hang tight"
            case .recording:
                return "Describe what you ate"
            case .permissionDenied:
                return "Open Settings to allow mic"
            case .failed(let message):
                return message
            }
        }

        var canRecord: Bool {
            switch self {
            case .idle, .recording:
                return true
            case .requestingPermission, .permissionDenied, .failed:
                return false
            }
        }
    }

    @Published private(set) var state: RecordingState = .idle
    @Published private(set) var isRecording = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var waveformLevels: [CGFloat]
    @Published var showSettingsPrompt = false

    var elapsedTimeText: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var onFinishRecording: ((URL) -> Void)?

    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var meteringTimer: Timer?
    private var recordedFileURL: URL?
    private let waveformBarCount = 48
    private let minimumLevel: CGFloat = 0.08
    private let smoothingFactor: CGFloat = 0.7

    override init() {
        waveformLevels = Array(repeating: minimumLevel, count: waveformBarCount)
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
        stopMetering()
    }

    func requestPermissionIfNeeded() {
        switch audioSession.recordPermission {
        case .undetermined:
            state = .requestingPermission
            audioSession.requestRecordPermission { [weak self] granted in
                DispatchQueue.main.async {
                    self?.state = granted ? .idle : .permissionDenied
                    if !granted {
                        self?.showSettingsPrompt = true
                    }
                }
            }
        case .denied:
            state = .permissionDenied
            showSettingsPrompt = true
        case .granted:
            state = .idle
        @unknown default:
            state = .failed("Unknown permission state")
        }
    }

    func toggleRecording() {
        isRecording ? stopRecording(save: true) : startRecording()
    }

    func startRecording() {
        guard audioSession.recordPermission == .granted else {
            requestPermissionIfNeeded()
            return
        }

        guard !isRecording else { return }

        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            state = .failed("Audio session error")
            return
        }

        guard let fileURL = prepareRecordingURL() else {
            state = .failed("Unable to create file")
            return
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            recordedFileURL = fileURL
            isRecording = true
            elapsedTime = 0
            state = .recording
            startTimer()
            startMetering()
        } catch {
            state = .failed("Could not start recording")
        }
    }

    func stopRecording(save: Bool) {
        guard isRecording else { return }

        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
        stopMetering()
        isRecording = false
        state = .idle
        resetWaveform()

        guard save, let recordedFileURL else { return }
        onFinishRecording?(recordedFileURL)
    }

    func cancelRecording() {
        stopRecording(save: false)
        if let recordedFileURL {
            try? FileManager.default.removeItem(at: recordedFileURL)
        }
        recordedFileURL = nil
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startMetering() {
        stopMetering()
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self, let recorder = self.audioRecorder, recorder.isRecording else { return }
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            let normalized = self.normalizedPower(power)
            DispatchQueue.main.async {
                self.shiftWaveform(with: normalized)
            }
        }
    }

    private func stopMetering() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }

    private func resetWaveform() {
        waveformLevels = Array(repeating: minimumLevel, count: waveformBarCount)
    }

    private func shiftWaveform(with newValue: CGFloat) {
        waveformLevels.append(newValue)
        if waveformLevels.count > waveformBarCount {
            waveformLevels.removeFirst(waveformLevels.count - waveformBarCount)
        }
    }

    private func normalizedPower(_ power: Float) -> CGFloat {
        let clamped = max(-60, power)
        let scaled = (60 + clamped) / 60
        let eased = scaled * (2 - scaled)
        let smooth = (smoothingFactor * (waveformLevels.last ?? minimumLevel)) + ((1 - smoothingFactor) * CGFloat(eased))
        return max(minimumLevel, min(1, smooth))
    }

    private func prepareRecordingURL() -> URL? {
        let directory = FileManager.default.temporaryDirectory
        let fileName = "voice-log-\(UUID().uuidString).m4a"
        return directory.appendingPathComponent(fileName)
    }

    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue)
        else { return }

        if type == .began {
            stopRecording(save: true)
        }
    }
}

extension VoiceLogViewModel: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        state = .failed("Encoding error")
        cancelRecording()
    }
}
