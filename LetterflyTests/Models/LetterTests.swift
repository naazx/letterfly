//
//  LetterTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 03.09.2026.
//

import Foundation
import FirebaseFirestore
import Testing

@testable import Letterfly

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

    @Test func formattedDate_todayUsesCurrentLocaleTimeStyle() {
        let date = Date.now
        let letter = Letter(authorID: "user1", subject: "Test", createdAt: date)

        #expect(letter.formattedDate == date.formatted(date: .omitted, time: .shortened))
    }

    @Test func formattedEditedAndReactionDatesAreNilWhenUnset() {
        let letter = Letter(authorID: "user1", subject: "Test", createdAt: .now)

        #expect(letter.formattedEditedDate == nil)
        #expect(letter.formattedReactedAt == nil)
        #expect(letter.formattedReactionEditedAt == nil)
    }

    @Test func formattedEditedAndReactionDatesUseTheSameFormatterAsCreatedDate() {
        let date = Date.now
        let letter = Letter(
            authorID: "user1",
            subject: "Test",
            createdAt: .now,
            editedAt: date,
            reactedAt: date,
            reactionEditedAt: date
        )
        let expected = date.formatted(date: .omitted, time: .shortened)

        #expect(letter.formattedEditedDate == expected)
        #expect(letter.formattedReactedAt == expected)
        #expect(letter.formattedReactionEditedAt == expected)
    }

    @Test func firestoreEncodingPreservesLetterContentAndOptionalMetadata() throws {
        let createdAt = Date(timeIntervalSince1970: 1_750_000_000)
        let location = Letter.LetterLocation(placeName: "Lviv", latitude: 49.8397, longitude: 24.0297)
        let original = Letter(
            authorID: "author",
            subject: "A memory",
            text: "Hello",
            createdAt: createdAt,
            photoURL: "https://example.com/photo.jpg",
            mood: .happy,
            surprise: .coffee,
            location: location,
            unlockDate: createdAt.addingTimeInterval(86_400),
            linkedEventID: "event-1"
        )

        let data = try Firestore.Encoder().encode(original)

        #expect(data["authorID"] as? String == "author")
        #expect(data["subject"] as? String == "A memory")
        #expect(data["text"] as? String == "Hello")
        #expect(data["createdAt"] != nil)
        #expect(data["photoURL"] as? String == "https://example.com/photo.jpg")
        #expect(data["mood"] as? String == MoodType.happy.rawValue)
        #expect(data["surprise"] as? String == SurpriseType.coffee.rawValue)
        #expect(data["location"] != nil)
        #expect(data["unlockDate"] != nil)
        #expect(data["linkedEventID"] as? String == "event-1")
        #expect(data["id"] == nil)
    }
}
