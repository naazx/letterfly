import Foundation
import Testing
@testable import Letterfly

@MainActor
struct HomeViewModelListenerTests {
    @Test func startListeningSubscribesToRequestedPair() {
        let service = MockLetterListenerService()
        let viewModel = HomeViewModel(listenerService: service)

        viewModel.startListening(pairID: "pair-1")

        #expect(service.requestedPairIDs == ["pair-1"])
    }

    @Test func listenerUpdatesDisplayedLetters() {
        let service = MockLetterListenerService()
        let viewModel = HomeViewModel(listenerService: service)
        let letter = Letter(authorID: "partner", subject: "Live update", createdAt: .now)
        viewModel.startListening(pairID: "pair-1")

        service.emit([letter])

        #expect(viewModel.letters == [letter])
    }

    @Test func stopListeningRemovesListener() {
        let service = MockLetterListenerService()
        let viewModel = HomeViewModel(listenerService: service)
        viewModel.startListening(pairID: "pair-1")

        viewModel.stopListening()

        #expect(service.registrations.first?.removeCalled == true)
        #expect(viewModel.listener == nil)
    }

    @Test func startingAgainRemovesPreviousListener() {
        let service = MockLetterListenerService()
        let viewModel = HomeViewModel(listenerService: service)
        viewModel.startListening(pairID: "pair-1")

        viewModel.startListening(pairID: "pair-2")

        #expect(service.registrations.first?.removeCalled == true)
        #expect(service.requestedPairIDs == ["pair-1", "pair-2"])
    }
}
