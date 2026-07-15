//
//  LetterServices.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//

import Foundation
import FirebaseFirestore

class LetterServices{
    let db = Firestore.firestore()
    
    func sendLetter(pairID: String, authorID: String, text: String) async throws {
        let letter = Letter(authorID: authorID, text: text, createdAt: Date())
        let encodedLetter = try Firestore.Encoder().encode(letter)

        try await db.collection("pairs").document(pairID).collection("letters")
            .document()
            .setData(encodedLetter)
    }
}
