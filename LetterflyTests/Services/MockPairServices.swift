//
//  MockPairServices.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 09.09.2026.
//

@testable import Letterfly
import Foundation

class MockPairServices: PairServiceProtocol {
    var partnerID: String?
    var pair: Pair?
    var user: String?
    var joinPairCalled: Bool = false
    var fetchPairCalled: Bool = false
    private(set) var fetchPairIDs: [String] = []
    private(set) var fetchPartnerCalls: [(pairID: String, myUID: String)] = []
    var fetchPairError: Error?
    var fetchPartnerError: Error?
    
    func joinPair(myUID: String, partnerCode: String) async throws {
        joinPairCalled = true
    }
    func findUser(_ invitationCode: String) async throws -> String? {
        return user
    }
    func fetchPartnerID(pairID: String, myUID: String) async throws -> String? {
        fetchPartnerCalls.append((pairID, myUID))
        if let fetchPartnerError { throw fetchPartnerError }
        return partnerID
    }
    func fetchPair(pairID: String) async throws -> Pair? {
        fetchPairCalled = true
        fetchPairIDs.append(pairID)
        if let fetchPairError { throw fetchPairError }
        return pair
    }
}
