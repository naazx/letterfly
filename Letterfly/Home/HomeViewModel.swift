//
//  HomeViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import Foundation
import FirebaseFirestore

protocol LetterListenerServiceProtocol {
    func listen(
        pairID: String,
        onChange: @escaping ([Letter]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration
}

final class FirestoreLetterListenerService: LetterListenerServiceProtocol {
    private let db = Firestore.firestore()

    func listen(
        pairID: String,
        onChange: @escaping ([Letter]) -> Void,
        onError: @escaping (Error) -> Void
    ) -> ListenerRegistration {
        db.collection("pairs").document(pairID).collection("letters")
            .addSnapshotListener { snapshot, error in
                if let error {
                    onError(error)
                    return
                }
                guard let snapshot else { return }
                onChange(snapshot.documents.compactMap { try? $0.data(as: Letter.self) })
            }
    }
}

@Observable
class HomeViewModel {
    var letters: [Letter] = []
    private let listenerService: LetterListenerServiceProtocol
    var listener: ListenerRegistration?

    init(listenerService: LetterListenerServiceProtocol = FirestoreLetterListenerService()) {
        self.listenerService = listenerService
    }

    func unlockedLetters(for currentUserID: String?) -> [Letter] {
        letters.filter { !$0.isLocked(for: currentUserID) }
    }

    func lockedLetters(for currentUserID: String?) -> [Letter] {
        letters.filter { $0.isLocked(for: currentUserID) }
    }

    func displayedLetters(searchText: String, sortOption: SortOption, currentUserID: String?) -> [Letter] {
        let unlocked = unlockedLetters(for: currentUserID)
        let sorted: [Letter]

        switch sortOption {
        case .dateSent:
            sorted = unlocked.sorted { $0.createdAt > $1.createdAt }
        case .name:
            sorted = unlocked.sorted {
                $0.subject.localizedCaseInsensitiveCompare($1.subject) == .orderedAscending
            }
        }

        guard !searchText.isEmpty else { return sorted }
        return sorted.filter { $0.subject.localizedCaseInsensitiveContains(searchText) }
    }
    
    func startListening(pairID: String) {
        stopListening()
        listener = listenerService.listen(
            pairID: pairID,
            onChange: { [weak self] letters in self?.letters = letters },
            onError: { print("ERROR: \($0.localizedDescription)") }
        )
    }
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
