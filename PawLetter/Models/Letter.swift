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
}
enum MoodType: String, CaseIterable, Codable, ChipDisplayable {
    case love
    case happy
    case thankful
    case missing

    var title: String {
        switch self {
        case .love:
            return "Love"
        case .happy:
            return "Happy"
        case .thankful:
            return "Thankful"
        case .missing:
            return "Missing You"
        }
    }

    var emoji: String {
        switch self {
        case .love:
            return "❤️"
        case .happy:
            return "😊"
        case .thankful:
            return "🤗"
        case .missing:
            return "🥹"
        }
    }
}

enum SurpriseType: String, CaseIterable, Codable, ChipDisplayable {
    case flower
    case chocolate
    case coffee
    case teddyBear

    var title: String {
        switch self {
        case .flower:
            return "Flower"
        case .chocolate:
            return "Chocolate"
        case .coffee:
            return "Coffee"
        case .teddyBear:
            return "Teddy Bear"
        }
    }

    var emoji: String {
        switch self {
        case .flower:
            return "🌹"
        case .chocolate:
            return "🍫"
        case .coffee:
            return "☕️"
        case .teddyBear:
            return "🧸"
        }
    }
}

enum ReactionType: String, CaseIterable, Codable, ChipDisplayable {
    case love
    case hug
    case touched
    case paw

    var title: String {
        switch self {
        case .love:
            return "Loved"
        case .hug:
            return "Hug"
        case .touched:
            return "Touched"
        case .paw:
            return "Paw"
        }
    }

    var emoji: String {
        switch self {
        case .love:
            return "❤️"
        case .hug:
            return "🤗"
        case .touched:
            return "🥹"
        case .paw:
            return "🐾"
        }
    }
}
protocol ChipDisplayable {
    var emoji: String { get }
    var title: String { get }
}
