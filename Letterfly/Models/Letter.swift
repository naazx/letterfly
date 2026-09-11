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
    var text: String?
    var createdAt: Date
    var photoURL: String?
    var isRead: Bool = false
    var editedAt: Date? = nil
    
    var mood: MoodType?
    var surprise: SurpriseType?
    var reaction: ReactionType?
    
    var reactedAt: Date? = nil
    var reactionEditedAt: Date? = nil
    
    var audioURL: String?
    var location: LetterLocation?
    
    var unlockDate: Date?
    var linkedEventID: String?
    
    struct LetterLocation : Hashable, Codable{
        var placeName: String?
        var latitude: Double
        var longitude: Double
    }
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
    var formattedReactedAt: String? {
        guard let reactedAt else { return nil }
        return formatted(reactedAt)
    }
    var formattedReactionEditedAt: String? {
        guard let reactionEditedAt else { return nil }
        return formatted(reactionEditedAt)
    }
    
    func isLocked(for currentUserID: String?) -> Bool {
        guard let unlockDate else { return false }
        return !(authorID == currentUserID) && unlockDate > .now
    }
}
