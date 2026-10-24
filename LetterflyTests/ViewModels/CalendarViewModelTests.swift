//
//  CalendarViewModelTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 10.09.2026.
//

import Foundation
import Testing
@testable import Letterfly

@MainActor
struct CalendarViewModelTests {

    @Test func groupedLetters_sameDayLetters_groupsIntoOneDate() {
        let letter1 = Letter(authorID: "nazar", subject: "nastia, do you love me?", createdAt: .now.addingTimeInterval(-2 * 3600))
        let letter2 = Letter(authorID: "nastia", subject: "yes, i do", createdAt: .now)

        let viewModel = CalendarViewModel()
        let result = viewModel.groupedLetters([letter1, letter2])
                
        #expect(result.count == 1)
        #expect(result.values.first?.count == 2)
    }
    
    @Test func groupedLetters_differentDayLetters_groupsIntoSeparateDates() {
        let today = Date.now
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        
        let letter1 = Letter(authorID: "nazar", subject: "today letter", createdAt: today)
        let letter2 = Letter(authorID: "nastia", subject: "old letter", createdAt: lastWeek)
        
        let viewModel = CalendarViewModel()
        let result = viewModel.groupedLetters([letter1, letter2])
        
        #expect(result.count == 2)
    }

    @Test func groupedLetters_emptyInputReturnsEmptyDictionary() {
        #expect(CalendarViewModel().groupedLetters([]).isEmpty)
    }

    @Test func groupedLetters_usesUnlockDateForCapsules() {
        let unlockDate = Calendar.current.date(byAdding: .day, value: 3, to: .now)!
        let letter = Letter(authorID: "partner", subject: "Future", createdAt: .now, unlockDate: unlockDate)

        let result = CalendarViewModel().groupedLetters([letter])
        let expectedKey = Calendar.current.startOfDay(for: unlockDate)

        #expect(result[expectedKey]?.map(\.subject) == ["Future"])
    }

    @Test func groupedLetters_groupsByCalendarDayAcrossDifferentTimes() {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let late = Calendar.current.date(byAdding: .hour, value: 23, to: startOfDay)!
        let first = Letter(authorID: "one", subject: "Morning", createdAt: startOfDay)
        let second = Letter(authorID: "two", subject: "Night", createdAt: late)

        let result = CalendarViewModel().groupedLetters([first, second])

        #expect(result.count == 1)
        #expect(result.values.first?.count == 2)
    }

}
