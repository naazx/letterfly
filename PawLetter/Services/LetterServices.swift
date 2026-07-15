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
    
    func sendLetter(authorID: String, subject: String, text: String, photoURL: String?, reference: DocumentReference) async throws {
        let letter = Letter(authorID: authorID, subject: subject, text: text, createdAt: .now, photoURL: photoURL)
        let encodedLetter = try Firestore.Encoder().encode(letter)

        try await reference.setData(encodedLetter)
    }
    func newLetterReference(pairID: String) -> DocumentReference {
        return db.collection("pairs").document(pairID).collection("letters").document()
    }
}
