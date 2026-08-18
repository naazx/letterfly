//
//  SurpriseType.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 18.08.2026.
//

import Foundation

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
