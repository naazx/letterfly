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
func myPow(_ x: Double, _ n: Int) -> Double {
    var y = 1.0
    for _ in 1...n {
        y = y * x
    }
    
    if n <= 0 {
        return 1/(y)
    } else {
        return y
    }
}
// nums = [1,3,5,6], target = 5
// Output: 2
