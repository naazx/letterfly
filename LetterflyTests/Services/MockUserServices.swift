//
//  MockUserServices.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 09.09.2026.
//

import Foundation
@testable import PawLetter


class MockUserServices: UserServiceProtocol {
    var profilesByUID: [String: (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?)] = [:]
    var defaultProfile: (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?) = (nil, nil, nil, nil, nil)

    func fetchUserProfile(uid: String) async throws -> (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?) {
        profilesByUID[uid] ?? defaultProfile
    }
    
    func createUserDocument(uid: String, inviteCode: String) async throws {
        
    }
    func isCodeTaken(_ code: String) async throws -> Bool {
        false
    }
    func reserveInviteCode(_ code: String, uid: String) async throws {
        
    }
    func generateUniqueInviteCode() async throws -> String {
        "i love nastia"
    }
    func updateAvatarURL(uid: String, url: String) async throws {
        
    }
    func updateDisplayName(uid: String, name: String) async throws {
        
    }
    func updatePartnerNickname(uid: String, nickname: String) async throws {
        
    }
    
    func deleteUserDocument(uid: String, pairID: String?) async throws {
        
    }
    
    var blockedPairs: Set<String> = []
    
    func blockPartner(myUID: String, partnerUID: String, pairID: String) async throws {
        blockedPairs.insert("\(myUID)_\(partnerUID)")
    }
    
    func isBlocked(myUID: String, otherUID: String) async throws -> Bool {
        blockedPairs.contains("\(myUID)_\(otherUID)") || blockedPairs.contains("\(otherUID)_\(myUID)")
    }
}
