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
    
    var loadedImages: [String: UIImage] = [:]
    
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
    func loadImageIfNeeded(for letter: Letter) async {
        guard let id = letter.id, loadedImages[id] == nil else { return }
        guard let photoURLString = letter.photoURL, let url = URL(string: photoURLString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return }
            loadedImages[id] = image
        } catch {}
    }
}
