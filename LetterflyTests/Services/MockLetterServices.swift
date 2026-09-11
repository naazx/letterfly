//
//  MockLetterServices.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 08.09.2026.
//

import FirebaseFirestore
import Foundation
@testable import PawLetter

class MockLetterServices: LetterServiceProtocol {
    var sendLetterCalled = false
    var updateLetterCalled = false
    var sendLetterSubject: String?
    var sendLetterText: String?
    var updateLetterSubject: String?
    
    var errorToThrow: Error?
    
    func sendLetter(authorID: String, subject: String, text: String?, photoURL: String?, audioURL: String?, reference: DocumentReference, mood: MoodType?, surprise: SurpriseType?, location: Letter.LetterLocation?, unlockDate: Date?, linkedEventID: String?) async throws {
        sendLetterCalled = true
        sendLetterSubject = subject
        sendLetterText = text
        
        if let errorToThrow {
            throw errorToThrow
        }
    }
    
    func newLetterReference(pairID: String) -> DocumentReference {
        Firestore.firestore().collection("pairs").document(pairID).collection("letters").document()
    }
    func markAsRead(pairID: String, letterID: String) async throws {
        
    }
    func setReaction(pairID: String, letterID: String, reaction: ReactionType?, previousReaction: ReactionType?) async throws {
        
    }
    func deleteLetter(pairID: String, letterID: String, photoURL: String?, audioURL: String?) async throws {
        
    }
    func updateLetter(pairID: String, letterID: String, subject: String, text: String?, photoURL: String?, audioURL: String?, mood: MoodType?, surprise: SurpriseType?, location: Letter.LetterLocation?, unlockDate: Date?, linkedEventID: String?) async throws {
        updateLetterCalled = true
        updateLetterSubject = subject
        
        if let errorToThrow {
            throw errorToThrow
        }
    }
}
