//
//  MoodType.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 18.08.2026.
//

import Foundation

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
