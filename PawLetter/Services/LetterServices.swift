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
    
    func sendLetter(authorID: String, subject: String, text: String?, photoURL: String?, audioURL: String?, reference: DocumentReference, mood: MoodType?, surprise: SurpriseType?, location: Letter.LetterLocation?) async throws {
        let letter = Letter(authorID: authorID, subject: subject, text: text, createdAt: .now, photoURL: photoURL, mood: mood, surprise: surprise, audioURL: audioURL, location: location)
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
    func setReaction(pairID: String, letterID: String, reaction: ReactionType?, previousReaction: ReactionType?) async throws {
        var data: [String: Any] = ["reaction": reaction?.rawValue as Any]
        
        if reaction == nil {
            data["reactedAt"] = NSNull()
            data["reactionEditedAt"] = NSNull()
        } else if previousReaction == nil {
            data["reactedAt"] = Date()
            data["reactionEditedAt"] = NSNull()
        } else {
            data["reactionEditedAt"] = Date()
        }
        
        try await db.collection("pairs").document(pairID).collection("letters").document(letterID).updateData(data)
    }
    func deleteLetter(pairID: String, letterID: String, photoURL: String?, audioURL: String?) async throws {
        if photoURL != nil{
            try await storageService.deleteFile(path: "letterPhotos/\(pairID)/\(letterID).jpg")
        }
        if audioURL != nil{
            try await storageService.deleteFile(path: "letterAudio/\(pairID)/\(letterID).m4a")
        }
        try await db.collection("pairs").document(pairID).collection("letters").document(letterID).delete()
    }
    func updateLetter(pairID: String, letterID: String, subject: String, text: String?, photoURL: String?, audioURL: String?, mood: MoodType?, surprise: SurpriseType?, location: Letter.LetterLocation?) async throws {
        try await db.collection("pairs").document(pairID).collection("letters")
            .document(letterID)
            .updateData([
                "subject": subject,
                "text": text as Any,
                "photoURL": photoURL as Any,
                "audioURL" : audioURL as Any,
                "editedAt": Date(),
                "mood": mood?.rawValue as Any,
                "surprise": surprise?.rawValue as Any,
                "location": location != nil ? try Firestore.Encoder().encode(location) : NSNull()
            ])
    }
}
