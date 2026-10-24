import Foundation
import Testing
@testable import Letterfly

@MainActor
struct PairEventsViewModelTests {
    @Test func startListeningSubscribesToRequestedPair() {
        let service = MockPairEventListenerService()
        let viewModel = PairEventsViewModel(listenerService: service)

        viewModel.startListening(pairID: "pair-7")

        #expect(service.requestedPairIDs == ["pair-7"])
    }

    @Test func listenerSortsEventsByDateAscending() {
        let service = MockPairEventListenerService()
        let viewModel = PairEventsViewModel(listenerService: service)
        let later = PairEvent(title: "Later", date: Date(timeIntervalSince1970: 200), isRecurring: false, createdBy: "me")
        let earlier = PairEvent(title: "Earlier", date: Date(timeIntervalSince1970: 100), isRecurring: false, createdBy: "partner")
        viewModel.startListening(pairID: "pair-7")

        service.emit([later, earlier])

        #expect(viewModel.events.map(\.title) == ["Earlier", "Later"])
    }

    @Test func stopListeningRemovesListener() {
        let service = MockPairEventListenerService()
        let viewModel = PairEventsViewModel(listenerService: service)
        viewModel.startListening(pairID: "pair-7")

        viewModel.stopListening()

        #expect(service.registrations.first?.removeCalled == true)
        #expect(viewModel.listener == nil)
    }

    @Test func startingAgainRemovesPreviousListener() {
        let service = MockPairEventListenerService()
        let viewModel = PairEventsViewModel(listenerService: service)
        viewModel.startListening(pairID: "pair-1")

        viewModel.startListening(pairID: "pair-2")

        #expect(service.registrations.first?.removeCalled == true)
        #expect(service.requestedPairIDs == ["pair-1", "pair-2"])
    }
}
