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
    
    @Test func formattedDate_showsTimeOnly_whenToday() {
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: .now
        )
        
        #expect(letter.formattedDate.contains(":"))
    }
    
    @Test func formattedDate_showsDayOnly_whenThisWeek() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let thursday = calendar.date(byAdding: .day, value: -(weekday - 5), to: today)!
        
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: thursday
        )
        
        #expect(letter.formattedDate.allSatisfy { !$0.isNumber })
    }
    
    @Test func formattedDate_showsThisYear_butNotThisWeek() {
        let calendar = Calendar.current
        let today = Date()
        
        let pastMonth = calendar.date(byAdding: .month, value: -2, to: today)
        
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: pastMonth!
        )
        
        #expect(letter.formattedDate.contains { $0.isNumber } && letter.formattedDate.contains { $0.isLetter })
    }
    
    @Test func formattedDate_showsLastYear() {
        let calendar = Calendar.current
        let today = Date()
        
        let pastYear = calendar.date(byAdding: .year, value: -1, to: today)
        
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: pastYear!
        )
        
        #expect(letter.formattedDate.filter { $0.isNumber }.count >= 5)
    }
}
