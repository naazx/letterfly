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
class Solution {
    func searchMatrix(_ matrix: [[Int]], _ target: Int) -> Bool {
        guard !matrix.isEmpty else { return false}

        let m = matrix.count
        let n = matrix[0].count

        var low = 0
        var high = m * n - 1

        while low <= high {
            let mid = low + (high - low) / 2

            let row = mid / n
            let col = mid % m

            let midValue = matrix[row][col]

            if midValue == target {
                return true
            } else if midValue < target {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }

        return false
    }
}
