import Foundation
import Testing
@testable import Letterfly

struct AppleSignInCryptoTests {
    @Test func sha256_matchesKnownDigest() {
        #expect(sha256("hello") == "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }

    @Test func sha256_isDeterministic() {
        #expect(sha256("letterfly") == sha256("letterfly"))
    }

    @Test func sha256_changesWhenInputChanges() {
        #expect(sha256("nazar") != sha256("Nazar"))
    }

    @Test func randomNonce_usesRequestedLength() {
        #expect(randomNonceString(length: 1).count == 1)
        #expect(randomNonceString(length: 32).count == 32)
        #expect(randomNonceString(length: 64).count == 64)
    }

    @Test func randomNonce_usesOnlyAllowedCharacters() {
        let allowed = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        for _ in 0..<20 {
            #expect(randomNonceString(length: 32).allSatisfy { allowed.contains($0) })
        }
    }
}
