import Foundation
import Testing
@testable import Letterfly

@MainActor
struct HomeViewModelTests {
    @Test func displayedLetters_sortsNewestFirstByDefaultOption() {
        let older = letter("Older", daysAgo: 2)
        let newer = letter("Newer", daysAgo: 0)
        let viewModel = HomeViewModel()
        viewModel.letters = [older, newer]

        let result = viewModel.displayedLetters(searchText: "", sortOption: .dateSent, currentUserID: "reader")

        #expect(result.map(\.subject) == ["Newer", "Older"])
    }

    @Test func displayedLetters_sortsNamesWithoutCaseSensitivity() {
        let zulu = letter("zulu", daysAgo: 0)
        let alpha = letter("Alpha", daysAgo: 1)
        let viewModel = HomeViewModel()
        viewModel.letters = [zulu, alpha]

        let result = viewModel.displayedLetters(searchText: "", sortOption: .name, currentUserID: "reader")

        #expect(result.map(\.subject) == ["Alpha", "zulu"])
    }

    @Test func displayedLetters_searchesSubjectCaseInsensitively() {
        let first = letter("First Memory", daysAgo: 0)
        let second = letter("Another note", daysAgo: 1)
        let viewModel = HomeViewModel()
        viewModel.letters = [first, second]

        let result = viewModel.displayedLetters(searchText: "MEMORY", sortOption: .dateSent, currentUserID: "reader")

        #expect(result.map(\.subject) == ["First Memory"])
    }

    @Test func displayedLetters_emptySearchReturnsAllUnlockedLetters() {
        let viewModel = HomeViewModel()
        viewModel.letters = [letter("First", daysAgo: 0), letter("Second", daysAgo: 1)]

        #expect(viewModel.displayedLetters(searchText: "", sortOption: .dateSent, currentUserID: "reader").count == 2)
    }

    @Test func displayedLetters_excludesCapsulesLockedForCurrentReader() {
        let available = letter("Available", daysAgo: 0)
        var capsule = letter("Future", daysAgo: 0)
        capsule.unlockDate = .now.addingTimeInterval(86_400)
        let viewModel = HomeViewModel()
        viewModel.letters = [available, capsule]

        let result = viewModel.displayedLetters(searchText: "", sortOption: .dateSent, currentUserID: "reader")

        #expect(result.map(\.subject) == ["Available"])
    }

    @Test func lockedLetters_onlyContainsCapsulesForOtherAuthors() {
        let past = letter("Past", daysAgo: 0)
        var futureByPartner = letter("Partner", daysAgo: 0, authorID: "partner")
        futureByPartner.unlockDate = .now.addingTimeInterval(86_400)
        var futureByCurrentUser = letter("Mine", daysAgo: 0, authorID: "reader")
        futureByCurrentUser.unlockDate = .now.addingTimeInterval(86_400)
        let viewModel = HomeViewModel()
        viewModel.letters = [past, futureByPartner, futureByCurrentUser]

        #expect(viewModel.lockedLetters(for: "reader").map(\.subject) == ["Partner"])
    }

    @Test func unlockedLetters_includesCapsulesAuthoredByCurrentUser() {
        var mine = letter("Mine", daysAgo: 0, authorID: "reader")
        mine.unlockDate = .now.addingTimeInterval(86_400)
        let viewModel = HomeViewModel()
        viewModel.letters = [mine]

        #expect(viewModel.unlockedLetters(for: "reader").map(\.subject) == ["Mine"])
    }

    private func letter(_ subject: String, daysAgo: Int, authorID: String = "partner") -> Letter {
        Letter(
            authorID: authorID,
            subject: subject,
            createdAt: Calendar.current.date(byAdding: .day, value: -daysAgo, to: .now)!
        )
    }
}
