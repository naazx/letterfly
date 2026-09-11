//
//  PairEvent.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import Foundation
import FirebaseFirestore

struct PairEvent: Codable, Identifiable, Hashable, Equatable {
    @DocumentID var id: String?
    var title: String
    var date: Date
    var isRecurring: Bool
    var createdBy: String
}

extension PairEvent {
    private func nextOccurrence(of date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.month, .day], from: date)
        components.year = calendar.component(.year, from: Date())
        
        let thisYearDate = calendar.date(from: components)!
        if thisYearDate < Date() {
            components.year! += 1
            return calendar.date(from: components)!
        }
        return thisYearDate
    }
    var nextOccurrence: Date {
        if isRecurring {
            return nextOccurrence(of: date)
        } else {
            return date
        }
    }
}
