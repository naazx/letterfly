//
//  UserServices.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol UserServiceProtocol {
    func createUserDocument(uid: String, inviteCode: String) async throws
    func isCodeTaken(_ code: String) async throws -> Bool
    func reserveInviteCode(_ code: String, uid: String) async throws
    func generateUniqueInviteCode() async throws -> String
    func updateAvatarURL(uid: String, url: String) async throws
    func fetchUserProfile(uid: String) async throws -> (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?)
    func updateDisplayName(uid: String, name: String) async throws
    func updatePartnerNickname(uid: String, nickname: String) async throws
    func deleteUserDocument(uid: String, pairID: String?) async throws
}

class UserServices: UserServiceProtocol {
    let db = Firestore.firestore()
    
    func createUserDocument(uid: String, inviteCode: String) async throws {
        do {
            try await db.collection("users").document(uid).setData([
                "inviteCode": inviteCode,
                "pairID": NSNull()
            ])
        } catch {
            throw NSError(domain: "PawLetter", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "FAILED at users.setData: \(error.localizedDescription)"
            ])
        }
        
        do {
            try await reserveInviteCode(inviteCode, uid: uid)
        } catch {
            throw NSError(domain: "PawLetter", code: -2, userInfo: [
                NSLocalizedDescriptionKey: "FAILED at reserveInviteCode (inviteCodes): \(error.localizedDescription)"
            ])
        }
    }
    
    func isCodeTaken(_ code: String) async throws -> Bool {
        let doc = try await db.collection("inviteCodes").document(code).getDocument()
        return doc.exists
    }
    
    func reserveInviteCode(_ code: String, uid: String) async throws {
        try await db.collection("inviteCodes").document(code).setData(["uid": uid])
    }
    
    func generateRandomCode() -> String {
        let codeCharacters = "abcdefghijklmnopqrstuvwxyz0123456789"
        var code = ""
        
        for _ in 1...6 {
            if let character = codeCharacters.randomElement() {
                code.append(character)
            }
        }
        return code
    }
    
    func generateUniqueInviteCode() async throws -> String {
        while true {
            let code = generateRandomCode()
            let taken = try await isCodeTaken(code)
            
            if !taken {
                return code
            }
        }
    }
    
    func updateAvatarURL(uid: String, url: String) async throws {
        try await db.collection("users").document(uid).updateData(
            ["avatarURL": url]
        )
    }
    
    func fetchUserProfile(uid: String) async throws -> (inviteCode: String?, avatarURL: String?, displayName: String?, pairID: String?, partnerNickname: String?) {
        let data = try await db.collection("users").document(uid).getDocument().data()
        let inviteCode = data?["inviteCode"] as? String
        let avatarURL = data?["avatarURL"] as? String
        let displayName = data?["displayName"] as? String
        let pairID = data?["pairID"] as? String
        let partnerNickname = data?["partnerNickname"] as? String
        return (inviteCode, avatarURL, displayName, pairID, partnerNickname)
    }
    
    func updateDisplayName(uid: String, name: String) async throws {
        try await db.collection("users").document(uid).updateData(
            ["displayName": name]
        )
    }
    
    func updatePartnerNickname(uid: String, nickname: String) async throws {
        try await db.collection("users").document(uid).updateData(
            ["partnerNickname": nickname]
        )
    }
    
    func deleteUserDocument(uid: String, pairID: String?) async throws {
        if let pairID {
            let pairRef = db.collection("pairs").document(pairID)
            let snapshot = try await pairRef.getDocument()

            if let members = snapshot.data()?["members"] as? [String] {
                let partnerID = members.first(where: { $0 != uid })

                if let partnerID {
                    try await db.collection("users").document(partnerID).updateData([
                        "pairID": NSNull()
                    ])
                }
            }

            try await pairRef.updateData([
                "members": FieldValue.arrayRemove([uid])
            ])
        }
        try await db.collection("users").document(uid).delete()
    }
}
