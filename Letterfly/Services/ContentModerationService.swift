//
//  ContentModerationService.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.10.2026.
//

import Foundation

protocol ContentModerationServiceProtocol {
    func containsObjectionableContent(_ text: String) -> Bool
}

class ContentModerationService: ContentModerationServiceProtocol {
    // Basic starter list for Apple's Guideline 1.2 requirement. Extend as needed.
    private let blockedWords: [String] = [
        "fuck", "shit", "bitch", "asshole", "bastard", "whore", "slut",
        "cunt", "nigger", "faggot", "retard",
        "kill yourself", "kys"
    ]

    func containsObjectionableContent(_ text: String) -> Bool {
        let normalized = text.lowercased()
        return blockedWords.contains { normalized.contains($0) }
    }
}
