//
//  PairEventsViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import Foundation
import FirebaseFirestore

protocol PairEventListenerServiceProtocol {
    func listen(
        pairID: String,
        onChange: @escaping ([PairEvent]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration
}

final class FirestorePairEventListenerService: PairEventListenerServiceProtocol {
    private let db = Firestore.firestore()

    func listen(
        pairID: String,
        onChange: @escaping ([PairEvent]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        db.collection("pairs").document(pairID).collection("events")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onError(error)
                    return
                }
                guard let snapshot else { return }
                onChange(snapshot.documents.compactMap { try? $0.data(as: PairEvent.self) })
            }
    }
}

@Observable
class PairEventsViewModel {
    var events: [PairEvent] = []
    private let listenerService: PairEventListenerServiceProtocol
    var listener: ListenerRegistration?

    init(listenerService: PairEventListenerServiceProtocol = FirestorePairEventListenerService()) {
        self.listenerService = listenerService
    }
    
    func startListening(pairID: String) {
        stopListening()
        listener = listenerService.listen(
            pairID: pairID,
            onChange: { [weak self] events in
                self?.events = events.sorted { $0.date < $1.date }
            },
            onError: { print("ERROR: \($0.localizedDescription)") }
        )
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
