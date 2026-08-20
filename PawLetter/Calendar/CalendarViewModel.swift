//
//  CalendarViewModel.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 11.07.2026.
//

import Foundation

@Observable
class CalendarViewModel {
    var selectedDate: Date?
    
    func groupedLetters(_ letters: [Letter]) -> [Date: [Letter]]{
        Dictionary(grouping: letters) { (letter) -> Date in
            return Calendar.current.startOfDay(for: letter.unlockDate ?? letter.createdAt) }
    }
}
