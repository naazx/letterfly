import Testing
@testable import Letterfly

struct ContentModerationServiceTests {
    private let service = ContentModerationService()

    @Test func detectsBlockedWord_caseInsensitively() {
        #expect(service.containsObjectionableContent("That is SHIT"))
    }

    @Test func detectsBlockedPhrase_caseInsensitively() {
        #expect(service.containsObjectionableContent("KILL YOURSELF"))
    }

    @Test func detectsBlockedWordNextToPunctuation() {
        #expect(service.containsObjectionableContent("You are a bitch!"))
    }

    @Test func detectsBlockedWordAtEitherEdge() {
        #expect(service.containsObjectionableContent("fuck you"))
        #expect(service.containsObjectionableContent("You are a whore"))
    }

    @Test func allowsHarmlessText() {
        #expect(!service.containsObjectionableContent("I miss you and hope you are well."))
    }

    @Test func allowsEmptyAndWhitespaceOnlyText() {
        #expect(!service.containsObjectionableContent(""))
        #expect(!service.containsObjectionableContent("   \n  "))
    }

    @Test func doesNotRejectHarmlessWordContainingBlockedSubstring() {
        #expect(!service.containsObjectionableContent("We ordered shitake mushrooms."))
    }
}
