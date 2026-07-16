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
    var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(createdAt) {
            // Сьогодні - тільки час
            return createdAt.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDate(createdAt, equalTo: now, toGranularity: .weekOfYear) {
            // Цей тиждень - день тижня
            return createdAt.formatted(.dateTime.weekday(.wide))
        } else if calendar.isDate(createdAt, equalTo: now, toGranularity: .year) {
            // Цей рік - день і місяць, без року
            return createdAt.formatted(.dateTime.day().month(.wide))
        } else {
            // Більше року - повна дата з роком
            return createdAt.formatted(.dateTime.day().month(.wide).year())
        }
    }
}
