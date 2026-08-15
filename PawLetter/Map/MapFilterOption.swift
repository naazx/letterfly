//
//  MapFilterOption.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 15.08.2026.
//

import Foundation
enum MapFilterOption: String, CaseIterable {
    case all
    case withPhotos
    case withMood
    case withSurprise
    case thisYear
    case thisMonth
    
    var title: String {
        switch self {
            case .all:
                return "All"
            case .withPhotos:
                return "With Photos"
            case .withMood: 
                return "With Mood"
            case .withSurprise: 
                return "With Surprise"
            case .thisYear: 
                return "This Year"
            case .thisMonth:
                return "This Month"
        }
    }
}
