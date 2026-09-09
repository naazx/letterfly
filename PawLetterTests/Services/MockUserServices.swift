//
//  MockUserServices.swift
//  PawLetterTests
//
//  Created by Nazar Dydyn on 09.09.2026.
//

import Foundation
@testable import PawLetter


class MockUserServices: UserServiceProtocol {
    var profileToReturn: (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?) = (nil, nil, nil, nil, nil)

    func createUserDocument(uid: String, inviteCode: String) async throws {
        
    }
    func isCodeTaken(_ code: String) async throws -> Bool {
        return false
    }
    func reserveInviteCode(_ code: String, uid: String) async throws {
        
    }
    func generateUniqueInviteCode() async throws -> String {
        return "i love nastia"
    }
    func updateAvatarURL(uid: String, url: String) async throws {
        
    }
    func fetchUserProfile(uid: String) async throws -> (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?) {
        return profileToReturn
    }
    func updateDisplayName(uid: String, name: String) async throws {
        
    }
    func updatePartnerNickname(uid: String, nickname: String) async throws {
        
    }

}
