//
//  PairServices.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 09.07.2026.
//

import Foundation
import FirebaseFirestore

enum PairError: Error {
    case codeNotFound, selfSearch
}


class PairServices{
    let db = Firestore.firestore()
    let userServices = UserServices()
    
    func joinPair(myUID: String, partnerCode: String) async throws {
      guard let partnerID = try await findUser(partnerCode) else {
            throw PairError.codeNotFound
        }
         if partnerID == myUID{
            throw PairError.selfSearch
        }
        
        let pairID = try await createPairDocument(myUID: myUID, partnerID: partnerID)
        
        try await db.collection("users").document(myUID).updateData([
            "pairID": pairID
        ])
        
        try await db.collection("users").document(partnerID).updateData([
            "pairID": pairID
        ])
    }
    func findUser(_ invitationCode: String) async throws -> String?{
        let snapshot = try await db.collection("users")
            .whereField("inviteCode", isEqualTo: invitationCode)
            .getDocuments()
        
        return snapshot.documents.first?.documentID
    }
    func createPairDocument(myUID: String, partnerID: String) async throws -> String{
        let newPairRef = db.collection("pairs").document()
        
        try await newPairRef.setData([
            "members" : [myUID, partnerID],
            "startDate" : Timestamp(date: Date())
        ])
        return  newPairRef.documentID
    }
    func fetchPartnerID(pairID: String, myUID: String) async throws -> String? {
        let snapshot = try await db.collection("pairs").document(pairID).getDocument()
        
        guard let members = snapshot.data()?["members"] as? [String] else { return nil }
        
        return members.first(where: { $0 != myUID })
    }
    func fetchPair(pairID: String) async throws -> Pair? {
        let snapshot = try await db.collection("pairs").document(pairID).getDocument()
        
        return try snapshot.data(as: Pair.self)
    }
}
