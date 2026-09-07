//
//  PairEventServices.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 19.08.2026.
//

import Foundation
import FirebaseFirestore

protocol PairEventServiceProtocol {
    func newEventReference(pairID: String) -> DocumentReference
    func createEvent(reference: DocumentReference, title: String, date: Date, isRecurring: Bool, createdBy: String) async throws
    func updateEvent(pairID: String, eventID: String, title: String, date: Date, isRecurring: Bool) async throws
    func deleteEvent(pairID: String, eventID: String) async throws
}

class PairEventServices: PairEventServiceProtocol {
    let db = Firestore.firestore()
    
    func newEventReference(pairID: String) -> DocumentReference {
        db.collection("pairs").document(pairID).collection("events").document()
    }
    
    func createEvent(reference: DocumentReference, title: String, date: Date, isRecurring: Bool, createdBy: String) async throws {
        let event = PairEvent(title: title, date: date, isRecurring: isRecurring, createdBy: createdBy)
        let encodedEvent = try Firestore.Encoder().encode(event)
        
        try await reference.setData(encodedEvent)
    }
    
    func updateEvent(pairID: String, eventID: String, title: String, date: Date, isRecurring: Bool) async throws {
        try await db.collection("pairs").document(pairID).collection("events")
            .document(eventID)
            .updateData([
                "title": title,
                "date": date,
                "isRecurring": isRecurring
            ])
    }
    
    func deleteEvent(pairID: String, eventID: String) async throws {
        try await db.collection("pairs").document(pairID).collection("events").document(eventID).delete()
    }
}
