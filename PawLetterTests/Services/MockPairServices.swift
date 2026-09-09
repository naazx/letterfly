//
//  MockPairServices.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 09.09.2026.
//

@testable import PawLetter
import Foundation

class MockPairServices: PairServiceProtocol {
    var partnerID: String?
    var pair: Pair?
    var user: String?
    var joinPairCalled: Bool = false
    
    func joinPair(myUID: String, partnerCode: String) async throws {
        joinPairCalled = true
    }
    func findUser(_ invitationCode: String) async throws -> String? {
        return user
    }
    func fetchPartnerID(pairID: String, myUID: String) async throws -> String? {
        return partnerID
    }
    func fetchPair(pairID: String) async throws -> Pair? {
        return pair
    }
}
