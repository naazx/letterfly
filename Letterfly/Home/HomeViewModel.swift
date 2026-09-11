//
//  HomeViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import Foundation
import FirebaseFirestore

@Observable
class HomeViewModel {
    var letters: [Letter] = []
    let db = Firestore.firestore()
    var listener: ListenerRegistration?
    
    func startListening(pairID: String) {
       listener = db.collection("pairs").document(pairID).collection("letters")
            .addSnapshotListener { [weak self] snapshot, error in
                guard  error == nil else {
                    print("ERROR: \(error!.localizedDescription)")
                    return
                }
                guard let snapshot else {
                    return
                }
                
                self?.letters = snapshot.documents.compactMap{
                    try? $0.data(as: Letter.self)
                }
            }
    }
    func stopListening() {
        listener?.remove()
    }
}
