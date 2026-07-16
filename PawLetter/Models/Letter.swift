//
//  Letter.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.07.2026.
//
import FirebaseFirestore
import Foundation

struct Letter : Codable, Identifiable, Equatable, Hashable{
    @DocumentID var id: String?
    var authorID: String
    var subject: String
    var text: String
    var createdAt: Date
    var photoURL: String?
    var isRead: Bool = false
    var editedAt: Date? = nil
}
extension Letter {
    private func formatted(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return date.formatted(.dateTime.weekday(.wide))
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            return date.formatted(.dateTime.day().month(.wide))
        } else {
            return date.formatted(.dateTime.day().month(.wide).year())
        }
    }
    
    var formattedDate: String {
        formatted(createdAt)
    }
    
    var formattedEditedDate: String? {
        guard let editedAt else { return nil }
        return formatted(editedAt)
    }
}
