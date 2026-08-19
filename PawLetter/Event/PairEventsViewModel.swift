//
//  PairEventsViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import Foundation
import FirebaseFirestore

@Observable
class PairEventsViewModel {
    var events: [PairEvent] = []
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    
    func startListening(pairID: String) {
       listener = db.collection("pairs").document(pairID).collection("events")
            .addSnapshotListener { [weak self] snapshot, error in
                guard  error == nil else {
                    print("ERROR: \(error!.localizedDescription)")
                    return
                }
                guard let snapshot else {
                    return
                }
                
                self?.events = snapshot.documents.compactMap{
                    try? $0.data(as: PairEvent.self)
                }.sorted(by: { $0.date < $1.date })
            }
    }
    
    func stopListening() {
        listener?.remove()
    }
}
