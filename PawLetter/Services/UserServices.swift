//
//  UserServices.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserServices {

    let db = Firestore.firestore()
    
    func createUserDocument(uid: String, inviteCode: String) async throws {
        try await db.collection("users").document(uid).setData([
            "inviteCode": inviteCode,
            "pairID": NSNull()
        ])
    }

    func isCodeTaken(_ code: String) async throws -> Bool {
        let snapshot = try await db.collection("users")
            .whereField("inviteCode", isEqualTo: code)
            .getDocuments()
        
        return !snapshot.documents.isEmpty
    }
    func generateRandomCode() -> String{
        let codeCharacters = "abcdefghijklmnopqrstuvwxyz0123456789"
        var code = ""
        
        for _ in 1...6{
            if let character = codeCharacters.randomElement(){
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
                return code   // одразу виходимо і повертаємо код
            }
            // інакше цикл повторюється
        }
    }
    func fetchPairID(uid: String) async throws -> String? {
        try await db.collection("users").document(uid).getDocument().data()?["pairID"] as? String
    }
    func fetchInviteCode(uid: String) async throws -> String? {
        try await db.collection("users").document(uid).getDocument().data()?["inviteCode"] as? String
    }
}
