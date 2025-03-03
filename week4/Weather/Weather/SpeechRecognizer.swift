//
//  SpeechRecognizer.swift
//  Weather
//
//  Created by Ryan A Snell on 2/26/25.
//

import Foundation
import Speech
import AVFoundation

class SpeechRecognizer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var recognitionTimeout: DispatchWorkItem?
    
    // Configuration options
    private let timeoutDuration: TimeInterval = 10.0
    
    deinit {
        stopRecording()
    }
    
    func prepare(completion: @escaping (Bool) -> Void) {
        // Request permissions when the view appears
        requestPermission(completion: completion)
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        // First check and request audio permission
        AVAudioApplication.requestRecordPermission { audioGranted in
            guard audioGranted else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // Then check speech recognition permission
            SFSpeechRecognizer.requestAuthorization { status in
                var isAuthorized = false
                
                switch status {
                case .authorized:
                    isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    isAuthorized = false
                @unknown default:
                    isAuthorized = false
                }
                
                DispatchQueue.main.async {
                    completion(isAuthorized)
                }
            }
        }
    }
    
    func startRecording(completion: @escaping (String?) -> Void) {
        recognitionTimeout?.cancel()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            return
        }
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
            completion(nil)
            return
        }
        
        // Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest,
              let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            completion(nil)
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create a variable to track if we've already called the completion handler
        var completionCalled = false
        
        // Start the recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                if result.isFinal {
                    if !completionCalled {
                        completionCalled = true
                        self.recognitionTimeout?.cancel()
                        self.cleanupAudioSession()
                        
                        DispatchQueue.main.async {
                            completion(result.bestTranscription.formattedString)
                        }
                    }
                    isFinal = true
                }
            }
            
            if error != nil || isFinal {
                self.cleanupAudioSession()
                
                if error != nil && !completionCalled {
                    completionCalled = true
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        
        // Configure the audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start the audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
            if !completionCalled {
                completionCalled = true
                completion(nil)
            }
            return
        }
        
        // Set a timeout for speech recognition
        let timeout = DispatchWorkItem { [weak self] in
            if !completionCalled {
                completionCalled = true
                self?.stopRecording()
                
                // Return the partial result if available
                // Set a timeout for speech recognition
                _ = DispatchWorkItem { [weak self] in
                    if !completionCalled {
                        completionCalled = true
                        
                        // We can't directly access partial results from the task
                        // Just stop the recording and report timeout
                        self?.stopRecording()
                        
                        DispatchQueue.main.async {
                            // No direct way to get partial results after timeout
                            // Just return nil to indicate timeout
                            completion(nil)
                        }
                    }
                }
            }
        }
        
        recognitionTimeout = timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutDuration, execute: timeout)
    }
    
    func stopRecording() {
        recognitionTimeout?.cancel()
        recognitionTimeout = nil
        cleanupAudioSession()
    }
    
    private func cleanupAudioSession() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        recognitionRequest = nil
        recognitionTask = nil
    }
}
