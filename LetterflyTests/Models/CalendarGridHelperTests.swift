import Foundation
import Testing
@testable import Letterfly

struct CalendarGridHelperTests {
    @Test func weekdaySymbols_startOnMonday() {
        #expect(CalendarGridHelper.weekdaySymbols == ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    }

    @Test func numberOfDays_returnsCorrectCountForLeapFebruary() {
        #expect(CalendarGridHelper.numberOfDays(in: date(2024, 2, 15)) == 29)
    }

    @Test func numberOfDays_returnsCorrectCountForCommonFebruary() {
        #expect(CalendarGridHelper.numberOfDays(in: date(2025, 2, 15)) == 28)
    }

    @Test func numberOfDays_handlesThirtyAndThirtyOneDayMonths() {
        #expect(CalendarGridHelper.numberOfDays(in: date(2026, 4, 1)) == 30)
        #expect(CalendarGridHelper.numberOfDays(in: date(2026, 7, 1)) == 31)
    }

    @Test func firstDayOfMonth_discardsTimeAndDay() {
        let result = CalendarGridHelper.firstDayOfMonth(containing: date(2026, 7, 24, hour: 18))
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: result)

        #expect(components.year == 2026)
        #expect(components.month == 7)
        #expect(components.day == 1)
        #expect(components.hour == 0)
    }

    @Test func leadingEmptyDays_mondayFirstMonthHasNoPadding() {
        #expect(CalendarGridHelper.leadingEmptyDays(for: date(2024, 4, 18)) == 0)
    }

    @Test func leadingEmptyDays_sundayFirstMonthHasSixSlots() {
        #expect(CalendarGridHelper.leadingEmptyDays(for: date(2024, 9, 18)) == 6)
    }

    @Test func leadingEmptyDays_isAlwaysWithinWeekWidth() {
        for month in 1...12 {
            let offset = CalendarGridHelper.leadingEmptyDays(for: date(2026, month, 15))
            #expect((0...6).contains(offset))
        }
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }
}
