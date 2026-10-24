import Foundation
import Testing
@testable import Letterfly

@MainActor
struct NewLetterViewModelBehaviorTests {
    @Test func initWithoutExistingLetterStartsInTextMode() {
        let viewModel = NewLetterViewModel(storageService: MockStorageService(), letterServices: MockLetterServices())

        #expect(viewModel.subject.isEmpty)
        #expect(viewModel.text == "")
        #expect(viewModel.inputMode == .text)
        #expect(viewModel.existingLetter == nil)
    }

    @Test func initWithExistingLetterRestoresEditableFields() {
        var existing = makeLetter()
        existing.mood = .thankful
        existing.surprise = .coffee
        existing.unlockDate = Date(timeIntervalSince1970: 1_800_000_000)
        existing.linkedEventID = "event-1"
        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: MockStorageService(), letterServices: MockLetterServices())

        #expect(viewModel.subject == existing.subject)
        #expect(viewModel.text == existing.text)
        #expect(viewModel.mood == .thankful)
        #expect(viewModel.surprise == .coffee)
        #expect(viewModel.unlockDate == existing.unlockDate)
        #expect(viewModel.linkedEventID == "event-1")
        #expect(viewModel.inputMode == .text)
    }

    @Test func initWithVoiceLetterSelectsVoiceMode() {
        var existing = makeLetter()
        existing.audioURL = "https://example.com/audio.m4a"

        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: MockStorageService(), letterServices: MockLetterServices())

        #expect(viewModel.inputMode == .voice)
    }

    @Test func surpriseOptionsAreUniqueAndKeepExistingSurpriseVisible() {
        var existing = makeLetter()
        existing.surprise = .coffee

        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: MockStorageService(), letterServices: MockLetterServices())

        #expect(viewModel.surpriseOptions.count == 4)
        #expect(Set(viewModel.surpriseOptions).count == 4)
        #expect(viewModel.surpriseOptions.first == .coffee)
    }

    @Test func sendBlockedSubjectDoesNotCallLetterService() async {
        let letterService = MockLetterServices()
        let viewModel = NewLetterViewModel(storageService: MockStorageService(), letterServices: letterService)
        viewModel.subject = "This is shit"

        await viewModel.send(pairID: "pair", authorID: "author", recordingURL: nil, location: nil)

        #expect(!letterService.sendLetterCalled)
        #expect(viewModel.showError)
        #expect(!viewModel.isSuccess)
        #expect(!viewModel.isLoading)
    }

    @Test func sendBlockedBodyDoesNotCallLetterService() async {
        let letterService = MockLetterServices()
        let viewModel = NewLetterViewModel(storageService: MockStorageService(), letterServices: letterService)
        viewModel.text = "kill yourself"

        await viewModel.send(pairID: "pair", authorID: "author", recordingURL: nil, location: nil)

        #expect(!letterService.sendLetterCalled)
        #expect(viewModel.showError)
    }

    @Test func sendNewLetterUploadsSelectedPhotoAndPassesURL() async {
        let storage = MockStorageService()
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(storageService: storage, letterServices: letters)
        viewModel.subject = "Photo letter"
        viewModel.selectedImageData = Data([1, 2, 3])

        await viewModel.send(pairID: "pair-1", authorID: "me", recordingURL: nil, location: nil)

        #expect(letters.sendLetterCalled)
        #expect(letters.sendLetterPhotoURL?.contains("letterPhotos/pair-1/") == true)
        #expect(storage.uploadedPaths.count == 1)
        #expect(storage.uploadedPaths[0].hasPrefix("letterPhotos/pair-1/"))
        #expect(viewModel.isSuccess)
    }

    @Test func sendNewVoiceLetterUploadsAudioAndOmitsText() async throws {
        let storage = MockStorageService()
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(storageService: storage, letterServices: letters)
        viewModel.subject = "Voice"
        viewModel.text = "not part of a voice letter"
        viewModel.inputMode = .voice
        let audioURL = try makeTemporaryAudioFile()
        defer { try? FileManager.default.removeItem(at: audioURL) }

        await viewModel.send(pairID: "pair-1", authorID: "me", recordingURL: audioURL, location: nil)

        #expect(letters.sendLetterCalled)
        #expect(letters.sendLetterText == nil)
        #expect(letters.sendLetterAudioURL?.contains("letterAudio/pair-1/") == true)
        #expect(storage.uploadedPaths.first?.hasPrefix("letterAudio/pair-1/") == true)
        #expect(viewModel.isSuccess)
    }

    @Test func sendNewLetterPassesLocationAndSchedulingMetadata() async {
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(storageService: MockStorageService(), letterServices: letters)
        let location = Letter.LetterLocation(placeName: "Lviv", latitude: 49.8397, longitude: 24.0297)
        let unlockDate = Date(timeIntervalSince1970: 1_800_000_000)
        viewModel.mood = .love
        viewModel.surprise = .book
        viewModel.unlockDate = unlockDate
        viewModel.linkedEventID = "event-7"

        await viewModel.send(pairID: "pair", authorID: "me", recordingURL: nil, location: location)

        #expect(letters.sendLetterMood == .love)
        #expect(letters.sendLetterSurprise == .book)
        #expect(letters.sendLetterLocation == location)
        #expect(letters.sendLetterUnlockDate == unlockDate)
        #expect(letters.sendLetterLinkedEventID == "event-7")
    }

    @Test func sendServiceFailureDoesNotReportSuccessAndRestoresLoadingState() async {
        let letters = MockLetterServices()
        letters.errorToThrow = NSError(domain: "test", code: 1)
        let viewModel = NewLetterViewModel(storageService: MockStorageService(), letterServices: letters)

        await viewModel.send(pairID: "pair", authorID: "me", recordingURL: nil, location: nil)

        #expect(letters.sendLetterCalled)
        #expect(!viewModel.isSuccess)
        #expect(!viewModel.isLoading)
        #expect(viewModel.showError)
        #expect(viewModel.errorMessage == "Something went wrong")
    }

    @Test func sendEditWithNoChangesReportsSuccessWithoutUpdating() async {
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: makeLetter(), storageService: MockStorageService(), letterServices: letters)

        await viewModel.send(pairID: "pair", authorID: "me", recordingURL: nil, location: nil)

        #expect(letters.updateLetterCallCount == 0)
        #expect(viewModel.isSuccess)
    }

    @Test func sendEditPersistsChangesToMoodLocationAndSchedule() async {
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: makeLetter(), storageService: MockStorageService(), letterServices: letters)
        let location = Letter.LetterLocation(placeName: "Kyiv", latitude: 50.4501, longitude: 30.5234)
        let unlockDate = Date(timeIntervalSince1970: 1_800_000_000)
        viewModel.mood = .happy
        viewModel.surprise = .coffee
        viewModel.unlockDate = unlockDate
        viewModel.linkedEventID = "event-2"

        await viewModel.send(pairID: "pair", authorID: "me", recordingURL: nil, location: location)

        #expect(letters.updateLetterCallCount == 1)
        #expect(letters.updatedLetterID == "letter-1")
        #expect(letters.updateLetterMood == .happy)
        #expect(letters.updateLetterSurprise == .coffee)
        #expect(letters.updateLetterLocation == location)
        #expect(letters.updateLetterUnlockDate == unlockDate)
        #expect(letters.updateLetterLinkedEventID == "event-2")
    }

    @Test func sendEditRemovingPhotoDeletesStoredFileAndClearsURL() async {
        var existing = makeLetter()
        existing.photoURL = "https://example.com/letter.jpg"
        let storage = MockStorageService()
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: storage, letterServices: letters)
        viewModel.didRemovePhoto = true

        await viewModel.send(pairID: "pair-1", authorID: "me", recordingURL: nil, location: nil)

        #expect(storage.deletedPaths == ["letterPhotos/pair-1/letter-1.jpg"])
        #expect(letters.updateLetterPhotoURL == nil)
        #expect(letters.updateLetterCallCount == 1)
    }

    @Test func sendEditPhotoDeletionFailurePreventsFirestoreUpdate() async {
        var existing = makeLetter()
        existing.photoURL = "https://example.com/letter.jpg"
        let storage = MockStorageService()
        storage.deleteErrorToThrow = StorageError.deletionFailed
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: storage, letterServices: letters)
        viewModel.didRemovePhoto = true

        await viewModel.send(pairID: "pair-1", authorID: "me", recordingURL: nil, location: nil)

        #expect(letters.updateLetterCallCount == 0)
        #expect(viewModel.showError)
        #expect(viewModel.errorMessage == "Could not delete photo")
        #expect(!viewModel.isSuccess)
    }

    @Test func sendEditSwitchingVoiceToTextDeletesAudioAndClearsURL() async {
        var existing = makeLetter()
        existing.audioURL = "https://example.com/old.m4a"
        let storage = MockStorageService()
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: storage, letterServices: letters)
        viewModel.inputMode = .text

        await viewModel.send(pairID: "pair-1", authorID: "me", recordingURL: nil, location: nil)

        #expect(storage.deletedPaths == ["letterAudio/pair-1/letter-1.m4a"])
        #expect(letters.updateLetterAudioURL == nil)
        #expect(letters.updateLetterCallCount == 1)
    }

    @Test func sendEditReplacingVoiceDeletesOldFileAndUploadsNewOne() async throws {
        var existing = makeLetter()
        existing.audioURL = "https://example.com/old.m4a"
        let storage = MockStorageService()
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: storage, letterServices: letters)
        viewModel.inputMode = .voice
        let audioURL = try makeTemporaryAudioFile()
        defer { try? FileManager.default.removeItem(at: audioURL) }

        await viewModel.send(pairID: "pair-1", authorID: "me", recordingURL: audioURL, location: nil)

        #expect(storage.deletedPaths == ["letterAudio/pair-1/letter-1.m4a"])
        #expect(storage.uploadedPaths == ["letterAudio/pair-1/letter-1.m4a"])
        #expect(letters.updateLetterAudioURL?.contains("letterAudio/pair-1/letter-1.m4a") == true)
    }

    @Test func sendEditWithoutDocumentIDDoesNotUpdateOrSucceed() async {
        let existing = Letter(authorID: "me", subject: "Hello", text: "World", createdAt: .now)
        let letters = MockLetterServices()
        let viewModel = NewLetterViewModel(existingLetter: existing, storageService: MockStorageService(), letterServices: letters)
        viewModel.subject = "Changed"

        await viewModel.send(pairID: "pair", authorID: "me", recordingURL: nil, location: nil)

        #expect(letters.updateLetterCallCount == 0)
        #expect(!viewModel.isSuccess)
        #expect(!viewModel.isLoading)
    }

    @Test func uploadPhotoUsesPairAndLetterInStoragePath() async throws {
        let storage = MockStorageService()
        let viewModel = NewLetterViewModel(storageService: storage, letterServices: MockLetterServices())

        let result = try await viewModel.uploadPhoto(data: Data([1, 2]), pairID: "pair", letterID: "letter")

        #expect(storage.uploadedPaths == ["letterPhotos/pair/letter.jpg"])
        #expect(result == "https://fake.com/letterPhotos/pair/letter.jpg")
        #expect(!viewModel.isLoading)
    }

    @Test func uploadAudioUsesPairAndLetterInStoragePath() async throws {
        let storage = MockStorageService()
        let viewModel = NewLetterViewModel(storageService: storage, letterServices: MockLetterServices())
        let audioURL = try makeTemporaryAudioFile()
        defer { try? FileManager.default.removeItem(at: audioURL) }

        let result = try await viewModel.uploadAudio(url: audioURL, pairID: "pair", letterID: "letter")

        #expect(storage.uploadedPaths == ["letterAudio/pair/letter.m4a"])
        #expect(result == "https://fake.com/letterAudio/pair/letter.m4a")
        #expect(!viewModel.isLoading)
    }

    private func makeLetter() -> Letter {
        Letter(id: "letter-1", authorID: "me", subject: "Hello", text: "World", createdAt: .now)
    }

    private func makeTemporaryAudioFile() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("letterfly-\(UUID().uuidString).m4a")
        try Data([0, 1, 2, 3]).write(to: url)
        return url
    }
}
