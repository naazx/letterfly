//
//  CalendarGridHelper.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 11.07.2026.
//

import Foundation
struct CalendarGridHelper{
    
    static let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    static func numberOfDays(in date: Date) -> Int{
        let calendar = Calendar.current
        
        if let dayRange = calendar.range(of: .day, in: .month, for: date) {
            return dayRange.count
        }
        return 0
    }
    static func leadingEmptyDays(for date: Date) -> Int{
        // (weekday - 2 + 7) % 7, де weekday — від 1-го числа місяця)
        let calendar = Calendar.current
        let firstDay = firstDayOfMonth(containing: date)
        let weekday = calendar.component(.weekday, from: firstDay)
        
        return (weekday - 2 + 7) % 7
    }
    static func firstDayOfMonth(containing date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let firstDay = calendar.date(from: components) else {
            return date
        }
        return firstDay
    }
}
