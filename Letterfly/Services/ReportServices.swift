//
//  ReportServices.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.10.2026.
//

import Foundation
import FirebaseFirestore

protocol ReportServiceProtocol {
    func reportLetter(letterID: String, pairID: String, reportedUserID: String, reporterID: String, reason: String) async throws
}

class ReportServices: ReportServiceProtocol {
    let db = Firestore.firestore()

    func reportLetter(letterID: String, pairID: String, reportedUserID: String, reporterID: String, reason: String) async throws {
        try await db.collection("reports").document().setData([
            "letterID": letterID,
            "pairID": pairID,
            "reportedUserID": reportedUserID,
            "reporterID": reporterID,
            "reason": reason,
            "status": "pending",
            "createdAt": Timestamp(date: Date())
        ])
    }
}
