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
    let storageService = StorageService()
    
    func sendLetter(authorID: String, subject: String, text: String, photoURL: String?, reference: DocumentReference) async throws {
        let letter = Letter(authorID: authorID, subject: subject, text: text, createdAt: .now, photoURL: photoURL)
        let encodedLetter = try Firestore.Encoder().encode(letter)

        try await reference.setData(encodedLetter)
    }
    func newLetterReference(pairID: String) -> DocumentReference {
        return db.collection("pairs").document(pairID).collection("letters").document()
    }
    func markAsRead(pairID: String, letterID: String ) async throws {
        try await db.collection("pairs").document(pairID).collection("letters").document(letterID).updateData([
            "isRead": true
        ])
    }
    
    func deleteLetter(pairID: String, letterID: String, photoURL: String? ) async throws {
        if photoURL != nil{
            try await storageService.deleteImage(path: "letterPhotos/\(pairID)/\(letterID).jpg")
        }
        try await db.collection("pairs").document(pairID).collection("letters").document(letterID).delete()
    }
    func updateLetter(pairID: String, letterID: String, subject: String, text: String, photoURL: String?) async throws {
        try await db.collection("pairs").document(pairID).collection("letters")
            .document(letterID)
            .updateData([
                "subject": subject,
                "text": text,
                "photoURL": photoURL as Any,
                "editedAt": Date()
            ])
    }
}
