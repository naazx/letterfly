//
//  LetterTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 03.09.2026.
//

import Foundation
import Testing

@testable import PawLetter

struct LetterTests {
    @Test func isLocked_returnsFalse_whenNoUnlockDate() {
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: .now,
            unlockDate: nil
        )
        
        #expect(letter.isLocked(for: "user2") == false)
    }
    
    @Test func isLocked_returnsFalse_whenAuthorViewsOwnLetter() {
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: .now,
            unlockDate: Date().addingTimeInterval(3600)
        )
        
        #expect(letter.isLocked(for: "user1") == false)
    }
    
    @Test func isLocked_returnsTrue_whenNotAuthorViewsLetterInFuture() {
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: .now,
            unlockDate: Date().addingTimeInterval(3600)
        )
        
        #expect(letter.isLocked(for: "user2") == true)
    }
    
    @Test func isLocked_returnsFalse_whenNotAuthorViewsLetterInPast() {
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: .now,
            unlockDate: Date().addingTimeInterval(-3600)
        )
        
        #expect(letter.isLocked(for: "user2") == false)
    }
}
