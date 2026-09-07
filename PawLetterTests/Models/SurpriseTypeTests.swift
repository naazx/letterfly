//
//  SurpriseTypeTests.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 07.09.2026.
//

import Testing

@testable import PawLetter

struct SurpriseTypeTests {

    @Test func allEmojis_areUnique() {
        let emojis = SurpriseType.allCases.map { $0.emoji }
        let uniqueEmojis = Set(emojis)
        
        #expect(emojis.count == uniqueEmojis.count)
    }

}
