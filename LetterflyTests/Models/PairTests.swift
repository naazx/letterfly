import Foundation
import FirebaseFirestore
import Testing
@testable import Letterfly

@MainActor
struct PairTests {
    @Test func firestoreEncodingPreservesMembersAndStartDate() throws {
        let original = Pair(members: ["nazar", "partner"], startDate: Date(timeIntervalSince1970: 1_750_000_000))

        let data = try Firestore.Encoder().encode(original)

        #expect(data["members"] as? [String] == original.members)
        #expect(data["startDate"] != nil)
        #expect(data["id"] == nil)
    }

    @Test func firestoreEncodingOmitsOptionalDocumentIDField() throws {
        let original = Pair(members: ["one", "two"], startDate: .now)

        let data = try Firestore.Encoder().encode(original)

        #expect(data["id"] == nil)
    }
}
