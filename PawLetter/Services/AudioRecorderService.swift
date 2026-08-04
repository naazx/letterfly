//
//  AudioRecorderService.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 04.08.2026.
//

import Foundation
import AVFoundation

@Observable
class AudioRecorderService: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var isRecording: Bool = false
    var recordingURL: URL?
    var errorMessage: String?
    
    private var recorder: AVAudioRecorder?
    
    var isPlaying: Bool = false
    private var player: AVAudioPlayer?
    
    var recordingDuration: TimeInterval = 0
    private var timer: Timer?
    
    var formattedDuration: String {
        String(format: "%d:%02d", Int(recordingDuration) / 60, Int(recordingDuration) % 60)
    }
    
    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
        } catch {
            errorMessage = "Could not start recording session"
            return
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent(UUID().uuidString + ".m4a")
        recordingURL = url
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.delegate = self
            recorder?.record()
            isRecording = true
            
            recordingDuration = 0
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.recordingDuration += 1
            }
        } catch {
            errorMessage = "Could not create recorder"
            recordingURL = nil
        }
    }
    
    func startPlayback() {
        guard let url = recordingURL else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
            isPlaying = true
        } catch {
            errorMessage = "Could not create player"
        }
    }
    func stopPlayback() {
        player?.stop()
        isPlaying = false
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    func deleteRecording() {
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        recordingURL = nil
        isRecording = false
        isPlaying = false
    }
    
    func stopRecording() {
        recorder?.stop()
        isRecording = false
        
        timer?.invalidate()
        timer = nil
    }
    func loadRemoteRecording(from urlString: String) async {
        guard let remoteURL = URL(string: urlString) else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".m4a")
            try data.write(to: localURL)
            recordingURL = localURL
        } catch {
            errorMessage = "Could not load existing recording"
        }
    }
}
