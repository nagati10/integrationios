//
//  CallAudioPlaybackManager.swift
//  Taleb_5edma
//
//  Plays received audio from Base64 (for video calls)
//

import AVFoundation
import Foundation

class CallAudioPlaybackManager {
    
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioFormat: AVAudioFormat?
    
    func setup() {
        do {
            // Configure audio session first
            let audioSession = AVAudioSession.sharedInstance()
            // Use loud speaker for calls with 4x amplification
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
            
            audioEngine = AVAudioEngine()
            playerNode = AVAudioPlayerNode()
            audioEngine	
            guard let engine = audioEngine, let player = playerNode else { 
                print("❌ Failed to create audio engine or player node")
                return 
            }
            
            engine.attach(player)
            
            // Connect using nil format - let the engine choose compatible format
            // We'll convert received audio to match the engine's format
            engine.connect(player, to: engine.mainMixerNode, format: nil)
            
            // Store the format the engine is actually using
            audioFormat = player.outputFormat(forBus: 0)
            
            print("✅ Audio playback format: \(audioFormat?.sampleRate ?? 0)Hz, \(audioFormat?.channelCount ?? 0) ch")
            
            // Boost volume for louder playback
            player.volume = 1.0  // Maximum volume
            engine.mainMixerNode.outputVolume = 1.0  // Max mixer volume
            
            engine.prepare()
            try engine.start()
            player.play()
            
            print("✅ Audio playback ready (Volume: MAX)")
            
        } catch let error as NSError {
            print("❌ Audio playback setup error: \(error.localizedDescription) (Code: \(error.code))")
            
            // Clean up on error
            audioEngine?.stop()
            audioEngine = nil
            playerNode = nil
            audioFormat = nil
        }
    }
    
    func playAudioData(_ base64String: String) {
        guard let data = Data(base64Encoded: base64String),
              let outputFormat = audioFormat,
              let player = playerNode else {
            return
        }
        
        // Incoming audio is 16kHz mono Int16 from Android
        let inputSampleRate = 16000.0
        let outputSampleRate = outputFormat.sampleRate
        let outputChannels = Int(outputFormat.channelCount)
        
        // Decode Int16 samples from data
        let int16Count = data.count / MemoryLayout<Int16>.size
        var int16Samples = [Int16](repeating: 0, count: int16Count)
        data.withUnsafeBytes { bytes in
            let int16Ptr = bytes.bindMemory(to: Int16.self)
            int16Samples = Array(int16Ptr)
        }
        
        // Convert Int16 to Float
        var floatSamples = int16Samples.map { Float($0) / 32767.0 }
        
        // Apply 4x gain amplification
        floatSamples = floatSamples.map { $0 * 4.0 }
        
        // Resample if needed
        if inputSampleRate != outputSampleRate {
            floatSamples = resample(floatSamples, from: inputSampleRate, to: outputSampleRate)
        }
        
        // Convert mono to stereo if needed
        if outputChannels == 2 {
            var stereoSamples = [Float]()
            stereoSamples.reserveCapacity(floatSamples.count * 2)
            for sample in floatSamples {
                stereoSamples.append(sample) // Left channel
                stereoSamples.append(sample) // Right channel (duplicate)
            }
            floatSamples = stereoSamples
        }
        
        // Create buffer with correct format
        let frameCount = UInt32(floatSamples.count / outputChannels)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: frameCount) else {
            print("❌ Failed to create audio buffer")
            return
        }
        
        buffer.frameLength = frameCount
        
        // Copy float samples to buffer
        if let channelData = buffer.floatChannelData {
            if outputChannels == 1 {
                // Mono
                for i in 0..<Int(frameCount) {
                    channelData[0][i] = floatSamples[i]
                }
            } else if outputChannels == 2 {
                // Stereo (non-interleaved)
                for i in 0..<Int(frameCount) {
                    channelData[0][i] = floatSamples[i * 2]     // Left
                    channelData[1][i] = floatSamples[i * 2 + 1] // Right
                }
            }
        }
        
        // Schedule and play
        player.scheduleBuffer(buffer, completionHandler: nil)
    }
    
    // Simple linear resampling
    private func resample(_ samples: [Float], from inputRate: Double, to outputRate: Double) -> [Float] {
        if inputRate == outputRate { return samples }
        
        let ratio = inputRate / outputRate
        let outputLength = Int(Double(samples.count) / ratio)
        var resampled = [Float]()
        resampled.reserveCapacity(outputLength)
        
        for i in 0..<outputLength {
            let sourceIndex = Double(i) * ratio
            let lower = Int(sourceIndex)
            let upper = min(lower + 1, samples.count - 1)
            let fraction = Float(sourceIndex - Double(lower))
            
            // Linear interpolation
            let interpolated = samples[lower] * (1.0 - fraction) + samples[upper] * fraction
            resampled.append(interpolated)
        }
        
        return resampled
    }
    
    func stop() {
        playerNode?.stop()
        audioEngine?.stop()
        audioEngine = nil
        playerNode = nil
        audioFormat = nil
    }
}
