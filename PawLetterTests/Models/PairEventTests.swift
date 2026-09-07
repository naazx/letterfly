//
//  PairEventTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 07.09.2026.
//

import Foundation
import Testing

@testable import PawLetter

struct PairEventTests {

    @Test func nextOccurrence_returnsSameDate_whenNotRecurring() {
        let date = DateComponents(calendar: .current, year: 2020, month: 1, day: 1).date!
        let event = PairEvent(
            title: "Test",
            date: date,
            isRecurring: false,
            createdBy: "user1"
        )
        
        #expect(event.nextOccurrence == date)
    }

    @Test func nextOccurrence_returnsSameDate_whenRecurring() {
        let date1 = DateComponents(calendar: .current, year: 2020, month: 2, day: 1).date!
        
        let currentYear = Calendar.current.component(.year, from: .now)
        let expectedDate = DateComponents(calendar: .current, year: currentYear + 1, month: 2, day: 1).date!
        
        let event = PairEvent(
            title: "Test",
            date: date1,
            isRecurring: true,
            createdBy: "user1"
        )
        
        #expect(event.nextOccurrence == expectedDate)
    }
    
    @Test func nextOccurrence_returnsSameYear_whenRecurringAndDateNotPassed() {
        let date1 = DateComponents(calendar: .current, year: 2020, month: 12, day: 25).date!
        
        let currentYear = Calendar.current.component(.year, from: .now)
        let expectedDate = DateComponents(calendar: .current, year: currentYear, month: 12, day: 25).date!
        
        let event = PairEvent(
            title: "Test",
            date: date1,
            isRecurring: true,
            createdBy: "user1"
        )
        
        #expect(event.nextOccurrence == expectedDate)
    }
}
