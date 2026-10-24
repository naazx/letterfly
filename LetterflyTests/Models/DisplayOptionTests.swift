import Testing
@testable import Letterfly

struct DisplayOptionTests {
    @Test func moodCasesHaveNonemptyTitlesAndEmojis() {
        #expect(!MoodType.allCases.isEmpty)
        #expect(MoodType.allCases.allSatisfy { !$0.title.isEmpty && !$0.emoji.isEmpty })
        #expect(Set(MoodType.allCases.map(\.rawValue)).count == MoodType.allCases.count)
    }

    @Test func reactionCasesHaveNonemptyTitlesAndEmojis() {
        #expect(!ReactionType.allCases.isEmpty)
        #expect(ReactionType.allCases.allSatisfy { !$0.title.isEmpty && !$0.emoji.isEmpty })
        #expect(Set(ReactionType.allCases.map(\.rawValue)).count == ReactionType.allCases.count)
    }

    @Test func surpriseCasesHaveNonemptyTitlesAndEmojis() {
        #expect(!SurpriseType.allCases.isEmpty)
        #expect(SurpriseType.allCases.allSatisfy { !$0.title.isEmpty && !$0.emoji.isEmpty })
        #expect(Set(SurpriseType.allCases.map(\.rawValue)).count == SurpriseType.allCases.count)
    }

    @Test func mapFilterOptionsHaveTitles() {
        #expect(MapFilterOption.allCases.allSatisfy { !$0.title.isEmpty })
    }

    @Test func sortOptionsHaveTitles() {
        #expect(SortOption.allCases.allSatisfy { !$0.title.isEmpty })
    }

    @Test func userVisibleLabelsStayMappedToExpectedValues() {
        #expect(MoodType.missing.title == "Missing You")
        #expect(ReactionType.love.title == "Loved")
        #expect(MapFilterOption.withPhotos.title == "With Photos")
        #expect(SortOption.dateSent.title == "Date Sent")
    }
}
