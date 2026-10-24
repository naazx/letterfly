import Foundation
import Testing
@testable import Letterfly

@MainActor
struct AudioRecorderServiceTests {
    @Test func formattedDuration_formatsZero() {
        let service = AudioRecorderService()

        #expect(service.formattedDuration == "0:00")
    }

    @Test func formattedDuration_formatsMinutesAndSeconds() {
        let service = AudioRecorderService()
        service.recordingDuration = 125

        #expect(service.formattedDuration == "2:05")
    }

    @Test func formattedDuration_truncatesFractionalSeconds() {
        let service = AudioRecorderService()
        service.recordingDuration = 61.9

        #expect(service.formattedDuration == "1:01")
    }

    @Test func startPlaybackWithoutRecordingURLDoesNothing() {
        let service = AudioRecorderService()

        service.startPlayback()

        #expect(!service.isPlaying)
        #expect(service.errorMessage == nil)
    }

    @Test func deleteRecordingClearsURLAndPlaybackFlags() throws {
        let service = AudioRecorderService()
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("letterfly-test-\(UUID().uuidString).m4a")
        try Data([1, 2, 3]).write(to: url)
        service.recordingURL = url
        service.isRecording = true
        service.isPlaying = true

        service.deleteRecording()

        #expect(service.recordingURL == nil)
        #expect(!service.isRecording)
        #expect(!service.isPlaying)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func stopRecordingClearsRecordingFlag() {
        let service = AudioRecorderService()
        service.isRecording = true

        service.stopRecording()

        #expect(!service.isRecording)
    }
}
