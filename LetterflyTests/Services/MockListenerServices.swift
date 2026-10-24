import FirebaseFirestore
import Foundation
@testable import Letterfly

final class MockListenerRegistration: NSObject, ListenerRegistration {
    private(set) var removeCalled = false

    func remove() {
        removeCalled = true
    }
}

final class MockLetterListenerService: LetterListenerServiceProtocol {
    private(set) var requestedPairIDs: [String] = []
    private(set) var registrations: [MockListenerRegistration] = []
    private var onChange: (([Letter]) -> Void)?
    private var onError: ((Error) -> Void)?

    func listen(pairID: String, onChange: @escaping ([Letter]) -> Void, onError: @escaping (Error) -> Void) -> ListenerRegistration {
        requestedPairIDs.append(pairID)
        self.onChange = onChange
        self.onError = onError
        let registration = MockListenerRegistration()
        registrations.append(registration)
        return registration
    }

    func emit(_ letters: [Letter]) { onChange?(letters) }
    func fail(_ error: Error) { onError?(error) }
}

final class MockPairEventListenerService: PairEventListenerServiceProtocol {
    private(set) var requestedPairIDs: [String] = []
    private(set) var registrations: [MockListenerRegistration] = []
    private var onChange: (([PairEvent]) -> Void)?
    private var onError: ((Error) -> Void)?

    func listen(pairID: String, onChange: @escaping ([PairEvent]) -> Void, onError: @escaping (Error) -> Void) -> ListenerRegistration {
        requestedPairIDs.append(pairID)
        self.onChange = onChange
        self.onError = onError
        let registration = MockListenerRegistration()
        registrations.append(registration)
        return registration
    }

    func emit(_ events: [PairEvent]) { onChange?(events) }
    func fail(_ error: Error) { onError?(error) }
}
