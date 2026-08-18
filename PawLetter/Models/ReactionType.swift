//
//  ReactionType.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 18.08.2026.
//

import Foundation

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
