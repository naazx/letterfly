//
//  MockLetterServices.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 08.09.2026.
//

import FirebaseFirestore
import Foundation
@testable import Letterfly

class MockLetterServices: LetterServiceProtocol {
    var sendLetterCalled = false
    var updateLetterCalled = false
    private(set) var sendLetterCallCount = 0
    private(set) var updateLetterCallCount = 0
    var sendLetterSubject: String?
    var sendLetterText: String?
    var sendLetterPhotoURL: String?
    var sendLetterAudioURL: String?
    var sendLetterMood: MoodType?
    var sendLetterSurprise: SurpriseType?
    var sendLetterLocation: Letter.LetterLocation?
    var sendLetterUnlockDate: Date?
    var sendLetterLinkedEventID: String?
    var updateLetterSubject: String?
    var updateLetterText: String?
    var updateLetterPhotoURL: String?
    var updateLetterAudioURL: String?
    var updateLetterMood: MoodType?
    var updateLetterSurprise: SurpriseType?
    var updateLetterLocation: Letter.LetterLocation?
    var updateLetterUnlockDate: Date?
    var updateLetterLinkedEventID: String?
    var updatedLetterID: String?
    
    var errorToThrow: Error?
    
    func sendLetter(authorID: String, subject: String, text: String?, photoURL: String?, audioURL: String?, reference: DocumentReference, mood: MoodType?, surprise: SurpriseType?, location: Letter.LetterLocation?, unlockDate: Date?, linkedEventID: String?) async throws {
        sendLetterCalled = true
        sendLetterCallCount += 1
        sendLetterSubject = subject
        sendLetterText = text
        sendLetterPhotoURL = photoURL
        sendLetterAudioURL = audioURL
        sendLetterMood = mood
        sendLetterSurprise = surprise
        sendLetterLocation = location
        sendLetterUnlockDate = unlockDate
        sendLetterLinkedEventID = linkedEventID
        
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
        updateLetterCallCount += 1
        updateLetterSubject = subject
        updateLetterText = text
        updateLetterPhotoURL = photoURL
        updateLetterAudioURL = audioURL
        updateLetterMood = mood
        updateLetterSurprise = surprise
        updateLetterLocation = location
        updateLetterUnlockDate = unlockDate
        updateLetterLinkedEventID = linkedEventID
        updatedLetterID = letterID
        
        if let errorToThrow {
            throw errorToThrow
        }
    }
}
